<script lang="ts">
  import InternetLoader from '$lib/loaders/InternetLoader.svelte';
  import { fade } from 'svelte/transition';
  import { page } from '$app/state';
  import { onMount } from 'svelte';

  const API = 'http://localhost:8000';

  type GithubState = 'disconnected' | 'connecting' | 'scanning' | 'results';
  let ghState: GithubState = $state('disconnected');

  interface RepoResult {
    id: number;
    name: string;
    type: string;
    size: string;
    co2: string;
    url: string;
    days_inactive: number;
    size_kb: number;
    selected: boolean;
    isWaste: boolean;
  }

  let results: RepoResult[] = $state([]);
  let scanStats = $state({ totalRepos: 0, inactiveRepos: 0, totalSizeGB: 0, co2Saved: 0 });

  let allSelected = $derived(results.length > 0 && results.every(r => r.selected));
  let selectedCount = $derived(results.filter(r => r.selected).length);

  onMount(() => {
    // Si venimos del OAuth callback, iniciar escaneo automáticamente
    const params = new URLSearchParams(window.location.search);
    if (params.get('authenticated') === 'true') {
      // Limpiar el query param de la URL
      window.history.replaceState({}, '', '/scan/github');
      startGithubScan();
    }
  });

  function toggleSelectAll() {
    const newState = !allSelected;
    results = results.map(item => ({ ...item, selected: newState }));
  }

  function connectGithub() {
    // Redirigir al flujo OAuth real del backend
    window.location.href = `${API}/auth/login`;
  }

  async function startGithubScan() {
    ghState = 'connecting';

    try {
      // Verificar si estamos autenticados
      const checkRes = await fetch(`${API}/repos`, { credentials: 'include' });
      if (checkRes.status === 401) {
        // No autenticado, redirigir a OAuth
        connectGithub();
        return;
      }

      ghState = 'scanning';

      const data = await checkRes.json();
      const repos = data.repos || [];

      // También traer dead forks
      let deadForkNames: string[] = [];
      try {
        const forksRes = await fetch(`${API}/dead-forks`, { credentials: 'include' });
        if (forksRes.ok) {
          const forksData = await forksRes.json();
          deadForkNames = (forksData.forks || []).map((f: any) => f.name);
        }
      } catch (e) {
        console.warn('No se pudieron cargar dead forks:', e);
      }

      // Mapear repos a resultados
      let totalSizeKB = 0;
      const mapped: RepoResult[] = repos.map((repo: any, i: number) => {
        const isInactive = repo.days_inactive > 180;
        const isDeadFork = deadForkNames.includes(repo.name);
        const sizeKB = repo.size_kb || 0;
        totalSizeKB += sizeKB;

        let type = 'Activo';
        let isWaste = false;
        if (isDeadFork) { type = 'Fork no sincronizado'; isWaste = true; }
        else if (isInactive && repo.is_fork) { type = 'Fork inactivo'; isWaste = true; }
        else if (isInactive) { type = 'Repo inactivo'; isWaste = true; }
        else if (repo.is_archived) { type = 'Archivado'; isWaste = true; }
        else if (repo.is_fork) { type = 'Fork'; }

        const sizeMB = sizeKB / 1024;
        const co2g = sizeMB * 0.5 * 0.475;

        return {
          id: i,
          name: repo.name,
          type,
          size: sizeMB >= 1024 ? `${(sizeMB / 1024).toFixed(2)} GB` : `${sizeMB.toFixed(1)} MB`,
          co2: co2g >= 1000 ? `${(co2g / 1000).toFixed(2)}kg` : `${co2g.toFixed(1)}g`,
          url: repo.url,
          days_inactive: repo.days_inactive,
          size_kb: sizeKB,
          selected: false,
          isWaste,
        };
      });

      results = mapped;

      const totalSizeGB = totalSizeKB / 1024 / 1024;
      const wasteItems = mapped.filter(r => r.isWaste);
      const inactiveCount = wasteItems.length;
      const co2Total = mapped.reduce((sum, r) => sum + (r.size_kb / 1024 * 0.5 * 0.475), 0);

      scanStats = {
        totalRepos: repos.length,
        inactiveRepos: inactiveCount,
        totalSizeGB,
        co2Saved: co2Total
      };

      // Guardar en localStorage para el Dashboard
      const scanData = {
        id: 'scan-' + Date.now(),
        user_id: data.user?.login || 'github-user',
        scan_date: new Date().toISOString(),
        total_files: repos.length,
        total_size_gb: totalSizeGB,
        waste_files: inactiveCount,
        waste_size_gb: mapped.reduce((s, r) => s + r.size_kb / 1024 / 1024, 0),
        co2_saved_estimate_g: co2Total,
        source_type: 'github',
        created_at: new Date().toISOString()
      };
      const history = JSON.parse(localStorage.getItem('ecoSyncScans') || '[]');
      history.unshift(scanData);
      localStorage.setItem('ecoSyncScans', JSON.stringify(history));

      ghState = 'results';

    } catch (e) {
      console.error('Error en el escaneo GitHub:', e);
      alert('Error conectando con el backend: ' + e);
      ghState = 'disconnected';
    }
  }

  async function deleteSelected() {
    if (selectedCount === 0) return;
    const toDelete = results.filter(r => r.selected);
    const confirmMsg = `⚠️ ACCIÓN IRREVERSIBLE\n\nVas a BORRAR permanentemente ${toDelete.length} repositorio(s) de tu cuenta de GitHub:\n\n${toDelete.map(r => '• ' + r.name).join('\n')}\n\n¿Estás completamente seguro?`;
    if (!confirm(confirmMsg)) return;

    let deleted = 0;
    let failed = 0;

    for (const repo of toDelete) {
      try {
        const res = await fetch(`${API}/manage-repo?action=delete`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'include',
          body: JSON.stringify({ repo_name: repo.name, confirm: true })
        });
        if (!res.ok) {
          const err = await res.json();
          throw new Error(err.detail || 'Error');
        }
        deleted++;
      } catch (e) {
        console.error(`Error borrando ${repo.name}:`, e);
        failed++;
      }
    }

    results = results.filter(r => !r.selected);
    alert(`✅ Eliminados: ${deleted}\n❌ Fallidos: ${failed}`);
  }

  async function deleteAll() {
    if (results.length === 0) return;
    const confirmMsg = `🔴 BORRADO MASIVO IRREVERSIBLE\n\nVas a eliminar TODOS los ${results.length} repositorios inactivos listados.\n\nEscribe "ELIMINAR" para confirmar:`;
    const input = prompt(confirmMsg);
    if (input !== 'ELIMINAR') {
      alert('Borrado cancelado.');
      return;
    }

    try {
      const repoNames = results.map(r => r.name);
      const res = await fetch(`${API}/bulk-delete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ repo_names: repoNames, delete_all_candidates: false, confirm: true })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || 'Error en bulk delete');

      alert(`✅ Eliminados: ${data.deleted_count}\n❌ Fallidos: ${data.failed_count}`);
      
      const deletedNames = data.results.filter((r: any) => r.status === 'deleted').map((r: any) => r.repo_name);
      results = results.filter(r => !deletedNames.includes(r.name));
    } catch (e) {
      alert('Error: ' + e);
    }
  }
</script>

<div class="w-full" transition:fade>
    <!-- Tarjeta Principal del Scanner usando Glass-effect -->
    <div class="glass-effect rounded-2xl p-6 md:p-10 relative overflow-hidden">
        
        {#if ghState === 'disconnected'}
            <div class="text-center py-12 px-4" transition:fade>
                <div class="w-24 h-24 mx-auto bg-white/5 border border-white/10 rounded-full flex items-center justify-center mb-6 glow-effect">
                    <svg class="w-12 h-12 text-emerald-400" fill="currentColor" viewBox="0 0 24 24"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.166 6.839 9.489.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.603-3.369-1.34-3.369-1.34-.454-1.156-1.11-1.463-1.11-1.463-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.831.092-.646.35-1.086.636-1.336-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.161 22 16.418 22 12c0-5.523-4.477-10-10-10z"/></svg>
                </div>
                <h2 class="text-3xl font-bold text-white mb-4">Autenticación Requerida</h2>
                <p class="text-emerald-400/70 mb-10 max-w-md mx-auto">
                    EcoSync necesita conectarse a tu cuenta de GitHub de forma segura para analizar tus repositorios en busca de elementos inactivos y medir su impacto residual.
                </p>
                <button onclick={connectGithub} class="px-8 py-4 bg-linear-to-r from-emerald-500 to-teal-600 text-white rounded-xl font-bold hover:scale-105 active:scale-95 transition-all duration-300 glow-effect flex items-center justify-center gap-3 mx-auto shadow-xl">
                    Verificar mi GitHub
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                </button>
            </div>

        {:else if ghState === 'connecting' || ghState === 'scanning'}
            <div class="text-center py-20" transition:fade>
                <div class="flex justify-center mx-auto mb-5">
                    <InternetLoader />
                </div>

                <h3 class="text-2xl font-bold text-white mb-2">
                    {ghState === 'connecting' ? 'Estableciendo conexión segura...' : 'Escaneando repositorios inactivos y forks muertos...'}
                </h3>

                <p class="text-emerald-400/70">Consultando la API de GitHub en tiempo real.</p>
            </div>

        {:else if ghState === 'results'}
            <div transition:fade>
                <div class="flex flex-col md:flex-row items-center justify-between mb-8 pb-8 border-b border-white/10 gap-6">
                    <div>
                        <h2 class="text-2xl font-bold text-white mb-1 flex items-center gap-3">
                            Resultados del Escaneo
                            <span class="px-3 py-1 bg-emerald-500/20 text-emerald-400 text-sm rounded-lg border border-emerald-500/30">Completado</span>
                        </h2>
                        <p class="text-emerald-400/70">
                            Se analizaron <strong class="text-white">{scanStats.totalRepos} repositorios</strong> en tu cuenta de GitHub.
                        </p>
                    </div>
                    
                    <div class="flex gap-3 w-full md:w-auto">
                        <button onclick={deleteAll} disabled={results.length === 0} class="w-full md:w-auto px-6 py-3 bg-red-500/10 hover:bg-red-500/20 text-red-500 font-bold rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed border border-red-500/30">
                            Eliminar Todo (Auto)
                        </button>
                    </div>
                </div>

                <!-- Panel de Impacto CO₂ -->
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                    <div class="bg-white/5 rounded-xl p-5 border border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-emerald-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-white">{scanStats.totalRepos}</p>
                        <p class="text-xs text-emerald-400/70 mt-1">Repos Totales</p>
                    </div>
                    <div class="bg-white/5 rounded-xl p-5 border border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-yellow-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-yellow-400">{scanStats.inactiveRepos}</p>
                        <p class="text-xs text-emerald-400/70 mt-1">Obsoletos</p>
                    </div>
                    <div class="bg-white/5 rounded-xl p-5 border border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-blue-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2 1 3 3 3h10c2 0 3-1 3-3V7c0-2-1-3-3-3H7C5 4 4 5 4 7z"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-blue-400">{scanStats.totalSizeGB >= 1 ? scanStats.totalSizeGB.toFixed(2) + ' GB' : (scanStats.totalSizeGB * 1024).toFixed(1) + ' MB'}</p>
                        <p class="text-xs text-emerald-400/70 mt-1">Almacenamiento</p>
                    </div>
                    <div class="bg-white/5 rounded-xl p-5 border border-emerald-500/20 text-center relative overflow-hidden">
                        <div class="absolute inset-0 bg-emerald-500/5"></div>
                        <div class="relative">
                            <div class="w-10 h-10 mx-auto rounded-lg bg-emerald-500/20 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                            </div>
                            <p class="text-2xl font-bold text-emerald-400">{scanStats.co2Saved >= 1000 ? (scanStats.co2Saved / 1000).toFixed(2) + ' kg' : scanStats.co2Saved.toFixed(1) + ' g'}</p>
                            <p class="text-xs text-emerald-400/70 mt-1">CO₂ al año</p>
                        </div>
                    </div>
                </div>

                <!-- Equivalencias del Mundo Real -->
                <div class="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-5 mb-8">
                    <h3 class="text-sm font-semibold text-emerald-400 mb-3 flex items-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        Impacto Ambiental — Equivalencias
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                        <div class="flex items-center gap-3">
                            <span class="text-xl">💡</span>
                            <div>
                                <p class="text-white font-medium">{(scanStats.co2Saved / 36).toFixed(1)} horas</p>
                                <p class="text-emerald-400/60 text-xs">de bombilla LED encendida</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="text-xl">🚗</span>
                            <div>
                                <p class="text-white font-medium">{(scanStats.co2Saved / 120).toFixed(2)} km</p>
                                <p class="text-emerald-400/60 text-xs">recorridos en automóvil</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="text-xl">🌳</span>
                            <div>
                                <p class="text-white font-medium">{(scanStats.co2Saved / 22000).toFixed(4)} árboles</p>
                                <p class="text-emerald-400/60 text-xs">necesarios para absorberlo al año</p>
                            </div>
                        </div>
                    </div>
                </div>

                {#if results.length > 0}
                    <div class="bg-white/5 rounded-2xl border border-white/10 overflow-hidden mb-8">
                        <div class="grid grid-cols-12 gap-4 px-6 py-4 border-b border-white/10 bg-white/5 font-semibold text-sm text-emerald-400/70">
                            <div class="col-span-1 flex items-center">
                                <input type="checkbox" checked={allSelected} onchange={toggleSelectAll} class="w-4 h-4 rounded border-white/20 bg-white/5 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-slate-900 cursor-pointer" />
                            </div>
                            <div class="col-span-5">Nombre / Repositorio</div>
                            <div class="col-span-3">Categoría</div>
                            <div class="col-span-3 text-right">Impacto (Tamaño / CO₂)</div>
                        </div>

                        <div class="divide-y divide-white/10">
                            {#each results as result (result.id)}
                                <label class="grid grid-cols-12 gap-4 px-6 py-4 items-center hover:bg-white/5 transition-colors cursor-pointer group {result.isWaste ? 'border-l-2 border-l-red-500/50' : 'border-l-2 border-l-emerald-500/30'}">
                                    <div class="col-span-1">
                                        <input type="checkbox" bind:checked={result.selected} class="w-4 h-4 rounded border-white/20 bg-white/5 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-slate-900 cursor-pointer" />
                                    </div>
                                    <div class="col-span-5 font-medium text-white flex items-center gap-2">
                                        <svg class="w-5 h-5 {result.isWaste ? 'text-red-400/50' : 'text-emerald-400/50'}" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path></svg>
                                        <a href={result.url} target="_blank" class="hover:text-emerald-400 transition-colors">{result.name}</a>
                                    </div>
                                    <div class="col-span-3 text-sm text-emerald-400/70">
                                        <span class="px-2 py-1 rounded-md text-xs {result.isWaste ? 'bg-red-500/10 border border-red-500/30 text-red-400' : 'bg-emerald-500/10 border border-emerald-500/30 text-emerald-400'}">{result.type}</span>
                                        {#if result.days_inactive > 0}
                                            <span class="ml-2 text-xs text-white/40">{result.days_inactive}d</span>
                                        {/if}
                                    </div>
                                    <div class="col-span-3 text-right flex flex-col items-end">
                                        <span class="font-bold text-white">{result.size}</span>
                                        <span class="text-xs text-emerald-400">{result.co2}/año</span>
                                    </div>
                                </label>
                            {/each}
                        </div>
                    </div>

                    <div class="flex justify-end">
                        <button onclick={deleteSelected} disabled={selectedCount === 0} class="px-8 py-4 bg-linear-to-r from-emerald-500 to-teal-600 text-white font-bold rounded-xl hover:scale-105 active:scale-95 transition-all duration-300 glow-effect disabled:opacity-50 disabled:hover:scale-100 disabled:cursor-not-allowed shadow-xl">
                            Eliminar Selección ({selectedCount})
                        </button>
                    </div>
                {:else}
                    <div class="text-center py-16 bg-white/5 rounded-2xl border border-dashed border-white/20">
                        <div class="w-16 h-16 mx-auto bg-emerald-500/20 rounded-full flex items-center justify-center mb-4 text-emerald-400 glow-effect">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        </div>
                        <h3 class="text-xl font-bold text-white mb-2">¡Todo limpio!</h3>
                        <p class="text-emerald-400/70">No se encontraron repositorios o ramas residuales. Tu GitHub está optimizado.</p>
                    </div>
                {/if}
            </div>
        {/if}
    </div>
</div>
