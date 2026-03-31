<script lang="ts">
  import InternetLoader from '$lib/loaders/InternetLoader.svelte';
  import { fade } from 'svelte/transition';
  import { onMount } from 'svelte';

  const API = 'http://localhost:8000';

  type LocalState = 'loading_dirs' | 'selecting' | 'scanning' | 'results';
  let lState: LocalState = $state('loading_dirs');

  // Directories state
  interface Directory {
    name: string;
    path: string;
    size_bytes: number;
    size_str: string;
    files_count: number;
    selected: boolean;
  }
  let directories: Directory[] = $state([]);

  // Results state
  interface LocalResult {
    id: string;
    name: string;
    path: string;
    size_mb: number;
    size_str: string;
    co2: string;
    modified_time: string;
    waste_category: string;
    waste_reason: string;
    selected: boolean;
  }
  let results: LocalResult[] = $state([]);
  let scanStats = $state({ totalFiles: 0, inactiveFiles: 0, totalSizeGB: 0, co2Saved: 0 });

  // Delete Options
  let deletePermanently = $state(false);

  // Opciones Avanzadas
  let showAdvanced = $state(false);
  let minSizeMB = $state(100);
  let minMonthsOld = $state(12);
  let includeInstallers = $state(true);
  let includeTemps = $state(true);
  let includeCache = $state(true);

  let allResultsSelected = $derived(results.length > 0 && results.every(r => r.selected));
  let resultSelectedCount = $derived(results.filter(r => r.selected).length);
  let selectedDirsCount = $derived(directories.filter(d => d.selected).length);

  onMount(() => {
    loadDirectories();
  });

  async function loadDirectories() {
    // Si ya los cargamos antes, no volvemos a hacer el escaneo lento
    if (directories.length > 0) {
      lState = 'selecting';
      return;
    }

    lState = 'loading_dirs';
    try {
      const res = await fetch(`${API}/local/directories`);
      if (!res.ok) throw new Error('Failed to load directories');
      const data = await res.json();
      directories = data.directories.map((d: any) => ({ ...d, selected: false }));
      lState = 'selecting';
    } catch (e) {
      console.error(e);
      alert('Error cargando directorios locales. El backend debe estar corriendo.');
    }
  }

  function toggleSelectAllResults() {
    const newState = !allResultsSelected;
    results = results.map(item => ({ ...item, selected: newState }));
  }

  async function startScan(fullScan: boolean) {
    lState = 'scanning';

    const reqData = {
      paths: fullScan ? [] : directories.filter(d => d.selected).map(d => d.path),
      full_scan: fullScan,
      min_size_mb: minSizeMB,
      min_months_old: minMonthsOld,
      include_installers: includeInstallers,
      include_temps: includeTemps,
      include_cache: includeCache
    };

    try {
      const res = await fetch(`${API}/local/scan`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(reqData)
      });
      if (!res.ok) throw new Error('Error al escanear');
      const data = await res.json();
      const files = data.files || [];

      // Map results
      results = files.map((f: any) => {
        const sizeMB = f.size_mb;
        const co2g = sizeMB * 0.5 * 0.475;

        return {
          id: f.id,
          name: f.name,
          path: f.path,
          size_mb: sizeMB,
          size_str: sizeMB >= 1024 ? `${(sizeMB / 1024).toFixed(2)} GB` : `${sizeMB.toFixed(1)} MB`,
          co2: co2g >= 1000 ? `${(co2g / 1000).toFixed(2)}kg` : `${co2g.toFixed(1)}g`,
          modified_time: f.modified_time ? new Date(f.modified_time).toLocaleDateString() : 'Desconocido',
          waste_category: f.waste_category || 'basura',
          waste_reason: f.waste_reason || '',
          selected: false
        };
      });

      scanStats = {
        totalFiles: data.total_files,
        inactiveFiles: data.waste_files,
        totalSizeGB: data.total_size_gb,
        co2Saved: data.co2_grams_per_year
      };

      // Guardar en localStorage para Dashboard
      const scanData = {
        id: 'scan-' + Date.now(),
        user_id: 'local-user',
        scan_date: new Date().toISOString(),
        total_files: data.total_files,
        total_size_gb: data.total_size_gb,
        waste_files: data.waste_files,
        waste_size_gb: data.waste_size_gb,
        co2_saved_estimate_g: data.co2_grams_per_year,
        source_type: 'local',
        created_at: new Date().toISOString()
      };
      const history = JSON.parse(localStorage.getItem('ecoSyncScans') || '[]');
      history.unshift(scanData);
      localStorage.setItem('ecoSyncScans', JSON.stringify(history));

      lState = 'results';

    } catch (e) {
      console.error(e);
      alert('Error en el escaneo local');
      lState = 'selecting';
    }
  }

  async function deleteSelected() {
    if (resultSelectedCount === 0) return;
    const toDelete = results.filter(r => r.selected);
    const modeStr = deletePermanently ? 'BORRARÁS PERMANENTEMENTE' : 'ENVIARÁS A LA PAPELERA';
    
    const confirmMsg = `⚠️ ${modeStr}\n\nVas a ${modeStr.toLowerCase()} ${toDelete.length} archivo(s) de tu disco duro:\n\n${toDelete.slice(0, 5).map(r => '• ' + r.name).join('\n')}${toDelete.length > 5 ? '\n... y más' : ''}\n\n¿Estás completamente seguro?`;
    if (!confirm(confirmMsg)) return;

    try {
      const filePaths = toDelete.map(r => r.path);
      const res = await fetch(`${API}/local/delete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ files: filePaths, permanent: deletePermanently })
      });
      
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || 'Error en borrado local');

      results = results.filter(r => !r.selected || !filePaths.includes(r.path));
      alert(`✅ Procesados con éxito: ${data.deleted}\n❌ Fallidos/Omitidos: ${data.failed}`);
    } catch (e) {
      alert('Error: ' + e);
    }
  }
</script>

<div class="w-full" transition:fade>
    <div class="glass-effect rounded-2xl p-6 md:p-10 relative overflow-hidden">
        
        {#if lState === 'loading_dirs'}
            <div class="text-center py-20" transition:fade>
                <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-teal-400 mx-auto mb-4"></div>
                <h3 class="text-xl font-bold text-white mb-2">Preparando Escáner Local...</h3>
                <p class="text-teal-400/70">Calculando el tamaño de tus directorios principales.</p>
            </div>

        {:else if lState === 'selecting'}
            <div class="text-center pb-8 border-b border-white/10" transition:fade>
                <div class="w-24 h-24 mx-auto bg-teal-500/10 border border-teal-500/20 rounded-full flex items-center justify-center mb-6 glow-effect shadow-[0_0_30px_rgba(20,184,166,0.3)]">
                    <svg class="w-12 h-12 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-2m3 2v-2m-9-2h12M5 8h14M3 21h18a2 2 0 002-2V5a2 2 0 00-2-2H3a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                </div>
                <h2 class="text-3xl font-bold text-white mb-4">Escáner de Disco Duro</h2>
                <p class="text-teal-400/70 max-w-lg mx-auto">
                    EcoSync analizará tus carpetas en busca de basura digital que ocupa espacio innecesario (archivos temporales, instaladores obsoletos, cachés residuales ocultos). Escoge qué carpetas quieres analizar.
                </p>
            </div>

            <div class="py-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4" transition:fade>
                {#each directories as dir}
                    <label class="bg-white/5 border {dir.selected ? 'border-teal-500 bg-teal-500/10' : 'border-white/10'} rounded-xl p-5 cursor-pointer hover:bg-white/10 transition-colors flex flex-col items-center text-center relative overflow-hidden group">
                        <input type="checkbox" bind:checked={dir.selected} class="absolute top-4 left-4 w-4 h-4 rounded border-white/20 bg-black/50 text-teal-500 focus:ring-teal-500" />
                        
                        <div class="w-12 h-12 bg-teal-500/20 rounded-lg flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                            <svg class="w-6 h-6 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path></svg>
                        </div>
                        <h4 class="text-lg font-bold text-white">{dir.name}</h4>
                        <p class="text-xs text-teal-400/70 break-all px-2 mt-1">{dir.path}</p>
                        
                        <div class="mt-4 pt-4 border-t border-white/10 w-full flex justify-between items-center text-sm">
                            <span class="text-white font-mono">{dir.size_str}</span>
                            <span class="text-white/40">{dir.files_count} arch</span>
                        </div>
                    </label>
                {/each}
            </div>

            <!-- Boton Toggle Panel Avanzado -->
            <div class="mt-4 mb-2 flex justify-center" transition:fade>
                <button onclick={() => showAdvanced = !showAdvanced} class="text-sm flex items-center gap-2 text-teal-400 hover:text-teal-300 transition-colors bg-white/5 hover:bg-white/10 px-4 py-2 rounded-lg border border-white/10">
                    <svg class="w-4 h-4 transition-transform duration-300 {showAdvanced ? 'rotate-180' : ''}" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                    Opciones Avanzadas de Escaneo
                </button>
            </div>

            <!-- Panel de Opciones Avanzadas -->
            {#if showAdvanced}
                <div class="bg-black/30 w-full max-w-3xl mx-auto rounded-xl p-5 border border-white/10 mb-6 grid grid-cols-1 md:grid-cols-2 gap-6" transition:fade>
                    <div class="space-y-4">
                        <h4 class="text-white font-semibold flex items-center gap-2 text-sm">
                            <svg class="w-4 h-4 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path></svg>
                            Sensibilidad del motor
                        </h4>
                        
                        <div>
                            <label class="block text-xs text-white/50 mb-1">Ignorar archivos menores a (Megabytes)</label>
                            <input type="number" bind:value={minSizeMB} min="1" class="w-full bg-black/50 border border-white/10 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-teal-500 text-sm" />
                        </div>
                        
                        <div>
                            <label class="block text-xs text-white/50 mb-1">Antigüedad mínima de inactividad (Meses)</label>
                            <input type="number" bind:value={minMonthsOld} min="0" class="w-full bg-black/50 border border-white/10 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-teal-500 text-sm" />
                        </div>
                    </div>

                    <div class="space-y-4">
                        <h4 class="text-white font-semibold flex items-center gap-2 text-sm">
                            <svg class="w-4 h-4 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                            Tipos de Basura a Detectar
                        </h4>
                        
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="checkbox" bind:checked={includeTemps} class="w-4 h-4 rounded border-white/20 bg-black/50 text-teal-500 focus:ring-teal-500" />
                            <span class="text-sm text-white/70 group-hover:text-white transition-colors">Archivos temporales (Logs, .tmp, .bak)</span>
                        </label>
                        
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="checkbox" bind:checked={includeInstallers} class="w-4 h-4 rounded border-white/20 bg-black/50 text-teal-500 focus:ring-teal-500" />
                            <span class="text-sm text-white/70 group-hover:text-white transition-colors">Instaladores y binarios obsoletos (.exe, .msi)</span>
                        </label>

                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="checkbox" bind:checked={includeCache} class="w-4 h-4 rounded border-white/20 bg-black/50 text-teal-500 focus:ring-teal-500" />
                            <span class="text-sm text-white/70 group-hover:text-white transition-colors">Cachés ocultas de aplicaciones perdidas</span>
                        </label>
                    </div>
                </div>
            {/if}

            <div class="flex flex-col sm:flex-row justify-center gap-4 pt-4">
                <button onclick={() => startScan(false)} disabled={selectedDirsCount === 0} class="px-8 py-4 bg-white/10 hover:bg-white/20 text-white rounded-xl font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed">
                    Escanear Selección ({selectedDirsCount})
                </button>
                <button onclick={() => startScan(true)} class="px-8 py-4 bg-linear-to-r from-teal-500 to-emerald-600 text-white rounded-xl font-bold hover:scale-105 active:scale-95 transition-transform glow-effect shadow-xl flex items-center justify-center gap-2">
                    Escanear Todo
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                </button>
            </div>

        {:else if lState === 'scanning'}
            <div class="text-center py-20" transition:fade>
                <div class="flex justify-center mx-auto mb-5">
                    <InternetLoader />
                </div>
                <h3 class="text-2xl font-bold text-white mb-2">Escaneo profundo en curso...</h3>
                <p class="text-teal-400/70">Buscando basura residual física y analizando pesos.</p>
            </div>

        {:else if lState === 'results'}
            <div transition:fade>
                <div class="flex flex-col md:flex-row items-center justify-between mb-8 pb-8 border-b border-white/10 gap-6">
                    <div>
                        <h2 class="text-2xl font-bold text-white mb-1 flex items-center gap-3">
                            Análisis Local
                            <span class="px-3 py-1 bg-teal-500/20 text-teal-400 text-sm rounded-lg border border-teal-500/30">Completado</span>
                        </h2>
                        <p class="text-teal-400/70">
                            Se analizaron <strong class="text-white">{scanStats.totalFiles} archivos</strong> físicos en tu disco duro.
                        </p>
                    </div>
                    
                    <button onclick={() => loadDirectories()} class="px-4 py-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-sm text-white">
                        Volver a escanear
                    </button>
                </div>

                <!-- Panel de Impacto CO₂ -->
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                    <div class="bg-white/5 rounded-xl p-5 border border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-teal-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-white">{scanStats.totalFiles}</p>
                        <p class="text-xs text-teal-400/70 mt-1">Archivos Escaneados</p>
                    </div>
                    <div class="bg-white/5 rounded-xl p-5 border border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-yellow-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-yellow-400">{scanStats.inactiveFiles}</p>
                        <p class="text-xs text-teal-400/70 mt-1">Archivos Basura</p>
                    </div>
                    <div class="bg-white/5 rounded-xl p-5 border border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-red-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2 1 3 3 3h10c2 0 3-1 3-3V7c0-2-1-3-3-3H7C5 4 4 5 4 7z"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-red-400">{scanStats.totalSizeGB >= 1 ? scanStats.totalSizeGB.toFixed(2) + ' GB' : (scanStats.totalSizeGB * 1024).toFixed(1) + ' MB'}</p>
                        <p class="text-xs text-teal-400/70 mt-1">Tamaño Total</p>
                    </div>
                    <div class="bg-teal-500/5 rounded-xl p-5 border border-teal-500/20 text-center relative overflow-hidden">
                        <div class="absolute inset-0 bg-teal-500/5"></div>
                        <div class="relative">
                            <div class="w-10 h-10 mx-auto rounded-lg bg-emerald-500/20 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                            </div>
                            <p class="text-2xl font-bold text-emerald-400">{scanStats.co2Saved >= 1000 ? (scanStats.co2Saved / 1000).toFixed(2) + ' kg' : scanStats.co2Saved.toFixed(1) + ' g'}</p>
                            <p class="text-xs text-teal-400/70 mt-1">CO₂ Ahorrado</p>
                        </div>
                    </div>
                </div>

                {#if results.length > 0}
                    <div class="bg-white/5 rounded-2xl border border-white/10 overflow-hidden mb-6">
                        <div class="grid grid-cols-12 gap-4 px-6 py-4 border-b border-white/10 bg-white/5 font-semibold text-sm text-teal-400/70">
                            <div class="col-span-1 flex items-center">
                                <input type="checkbox" checked={allResultsSelected} onchange={toggleSelectAllResults} class="w-4 h-4 rounded border-white/20 bg-white/5 text-teal-500 focus:ring-teal-500" />
                            </div>
                            <div class="col-span-5">Archivo Físico / Ruta</div>
                            <div class="col-span-3">Categoría</div>
                            <div class="col-span-3 text-right">Tamaño / CO₂</div>
                        </div>

                        <div class="divide-y divide-white/10 max-h-[500px] overflow-y-auto">
                            {#each results as result (result.id)}
                                <label class="grid grid-cols-12 gap-4 px-6 py-4 items-center hover:bg-white/5 transition-colors cursor-pointer group border-l-2 border-l-red-500/50">
                                    <div class="col-span-1">
                                        <input type="checkbox" bind:checked={result.selected} class="w-4 h-4 rounded border-white/20 bg-white/5 text-teal-500 focus:ring-teal-500" />
                                    </div>
                                    <div class="col-span-5 flex-col min-w-0 pr-2">
                                        <p class="font-medium text-white truncate" title={result.name}>{result.name}</p>
                                        <p class="text-[10px] text-white/40 truncate mt-1" title={result.path}>{result.path}</p>
                                    </div>
                                    <div class="col-span-3 text-sm text-teal-400/70">
                                        <span class="px-2 py-1 rounded-md text-xs inline-block capitalize mb-1 bg-red-500/10 border border-red-500/30 text-red-400">{result.waste_category}</span>
                                        {#if result.waste_reason}
                                            <p class="text-[10px] text-white/40 leading-tight">{result.waste_reason}</p>
                                        {/if}
                                    </div>
                                    <div class="col-span-3 text-right flex flex-col items-end shrink-0">
                                        <span class="font-bold text-red-300">{result.size_str}</span>
                                        <span class="text-xs text-emerald-400">{result.co2}/año</span>
                                    </div>
                                </label>
                            {/each}
                        </div>
                    </div>

                    <div class="flex flex-col md:flex-row justify-between items-center bg-black/20 rounded-xl p-4 border border-white/5 gap-4">
                        <div class="flex items-center gap-4 bg-white/5 px-4 py-3 rounded-lg border border-white/10">
                            <span class="text-sm font-medium text-white/70">Método de borrado:</span>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" bind:checked={deletePermanently} class="sr-only peer">
                                <div class="w-11 h-6 bg-white/10 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-red-500"></div>
                                <span class="ml-3 text-sm font-bold {deletePermanently ? 'text-red-400' : 'text-teal-400'}">
                                    {deletePermanently ? 'Destructivo (Bypass Papelera)' : 'Mover a Papelera de Reciclaje'}
                                </span>
                            </label>
                        </div>

                        <button onclick={deleteSelected} disabled={resultSelectedCount === 0} class="w-full md:w-auto px-8 py-4 {deletePermanently ? 'bg-red-500 hover:bg-red-600' : 'bg-teal-500 hover:bg-teal-600'} text-white font-bold rounded-xl active:scale-95 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed shadow-xl">
                            Ejecutar Borrado ({resultSelectedCount})
                        </button>
                    </div>
                {:else}
                    <div class="text-center py-16 bg-white/5 rounded-2xl border border-dashed border-white/20">
                        <div class="w-16 h-16 mx-auto bg-teal-500/20 rounded-full flex items-center justify-center mb-4 text-teal-400 glow-effect">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        </div>
                        <h3 class="text-xl font-bold text-white mb-2">¡Unidades Limpias!</h3>
                        <p class="text-teal-400/70">No se ha detectado basura digital en los directorios seleccionados.</p>
                    </div>
                {/if}
            </div>
        {/if}
    </div>
</div>
