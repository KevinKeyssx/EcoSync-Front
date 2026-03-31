<script lang="ts">
  import InternetLoader from '$lib/loaders/InternetLoader.svelte';
  import { fade } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { toast } from 'svelte-sonner';
  import ConfirmDelete from '$lib/components/shared/ConfirmDelete.svelte';

  import { PUBLIC_URL_API } from '$env/static/public';

  const API = PUBLIC_URL_API;

  type DriveState = 'disconnected' | 'connecting' | 'scanning' | 'results';
  let drvState: DriveState = $state( 'disconnected' );

  let showConfirmDialog	= $state( false );
  let confirmMessage	= $state( '' );

  interface DriveResult {
    id: string;
    name: string;
    type: string;
    size: string;
    co2: string;
    modified: string;
    size_mb: number;
    selected: boolean;
    isWaste: boolean;
    wasteReason: string;
  }

  let results: DriveResult[] = $state([]);
  let scanStats = $state({ totalFiles: 0, inactiveFiles: 0, totalSizeGB: 0, co2Saved: 0 });

  let allSelected = $derived(results.length > 0 && results.every(r => r.selected));
  let selectedCount = $derived(results.filter(r => r.selected).length);

  onMount(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('authenticated') === 'true') {
      window.history.replaceState({}, '', '/scan/drive');
      startDriveScan();
    }
  });

  function toggleSelectAll() {
    const newState = !allSelected;
    results = results.map(item => ({ ...item, selected: newState }));
  }

  function connectDrive() {
    window.location.href = `${API}/auth/google/login`;
  }

  async function startDriveScan() {
    drvState = 'connecting';

    try {
      const checkRes = await fetch(`${API}/drive/scan`, { credentials: 'include' });
      if (checkRes.status === 401) {
        connectDrive();
        return;
      }

      drvState = 'scanning';
      const data = await checkRes.json();
      const files = data.files || [];

      // Mapear archivos a resultados
      const mapped: DriveResult[] = files.map((f: any) => {
        const sizeMB = f.size_mb;
        const co2g = sizeMB * 0.5 * 0.475; // 0.5 kWh/GB/año

        return {
          id: f.id,
          name: f.name,
          type: f.waste_category,
          size: sizeMB >= 1024 ? `${(sizeMB / 1024).toFixed(2)} GB` : `${sizeMB.toFixed(1)} MB`,
          co2: co2g >= 1000 ? `${(co2g / 1000).toFixed(2)}kg` : `${co2g.toFixed(1)}g`,
          modified: f.modified_time ? new Date(f.modified_time).toLocaleDateString() : 'Desconocido',
          size_mb: sizeMB,
          selected: false,
          isWaste: f.is_waste,
          wasteReason: f.waste_reason,
        };
      });

      results = mapped;

      scanStats = {
        totalFiles: data.total_files,
        inactiveFiles: data.waste_files,
        totalSizeGB: data.total_size_gb,
        co2Saved: data.co2_grams_per_year
      };

      // Guardar en localStorage para el Dashboard
      const scanData = {
        id: 'scan-' + Date.now(),
        user_id: data.quota?.user_email || 'drive-user',
        scan_date: new Date().toISOString(),
        total_files: data.total_files,
        total_size_gb: data.total_size_gb,
        waste_files: data.waste_files,
        waste_size_gb: data.waste_size_gb,
        co2_saved_estimate_g: data.co2_grams_per_year,
        source_type: 'drive',
        created_at: new Date().toISOString()
      };
      const history = JSON.parse(localStorage.getItem('ecoSyncScans') || '[]');
      history.unshift(scanData);
      localStorage.setItem('ecoSyncScans', JSON.stringify(history));

      drvState = 'results';

    } catch ( e ) {
      console.error( 'Error en el escaneo de Drive:', e );
      toast.error( 'Ocurrió un error inesperado, inténtalo más tarde.' );
      drvState = 'disconnected';
    }
  }

  async function deleteSelected( confirmed: boolean | Event = false ) {
    if ( selectedCount === 0 ) return;
    const toDelete = results.filter( r => r.selected );
    
    if ( confirmed !== true ) {
      confirmMessage = `⚠️ Mover a la Papelera\n\nVas a enviar ${ toDelete.length } archivo(s) a la papelera de Google Drive (se eliminarán automáticamente en 30 días):\n\n${ toDelete.slice( 0, 5 ).map( r => '• ' + r.name ).join( '\n' ) }${ toDelete.length > 5 ? '\n... y más' : '' }\n\n¿Deseas continuar?`;
      showConfirmDialog = true;
      return;
    }

    try {
      const fileIds = toDelete.map(r => r.id);
      const res = await fetch(`${API}/drive/delete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(fileIds)
      });
      
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || 'Error en borrado masivo');

      results = results.filter( r => !r.selected || !fileIds.includes( r.id ) );
      if ( data.failed > 0 ) {
        toast.warning( `✅ Enviados a la papelera: ${ data.deleted }\n❌ Fallidos: ${ data.failed }` );
      } else {
        toast.success( `✅ Enviados a la papelera: ${ data.deleted }\n❌ Fallidos: ${ data.failed }` );
      }
    } catch ( e ) {
      toast.error( 'Ocurrió un error inesperado, inténtalo más tarde.' );
    }
  }

  async function deleteAllWaste() {
    const wasteFiles = results.filter(r => r.isWaste);
    if (wasteFiles.length === 0) return;
    const confirmMsg = `🔴 LIMPIEZA MASIVA\n\nVas a enviar TODOS los ${wasteFiles.length} archivos obsoletos a la papelera.\n\nEscribe "LIMPIAR" para confirmar:`;
    const input = prompt( confirmMsg );
    if ( input !== 'LIMPIAR' ) {
      toast.warning( 'Limpieza cancelada.' );
      return;
    }

    try {
      const fileIds = wasteFiles.map(r => r.id);
      const res = await fetch(`${API}/drive/delete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(fileIds)
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || 'Error en bulk delete');

      if ( data.failed > 0 ) {
        toast.warning( `✅ Enviados a la papelera: ${ data.deleted }\n❌ Fallidos: ${ data.failed }` );
      } else {
        toast.success( `✅ Enviados a la papelera: ${ data.deleted }\n❌ Fallidos: ${ data.failed }` );
      }
      results = results.filter( r => !fileIds.includes( r.id ) );
    } catch ( e ) {
      toast.error( 'Ocurrió un error inesperado, inténtalo más tarde.' );
    }
  }
</script>

<div class="w-full" transition:fade>
    <!-- Tarjeta Principal del Scanner usando Glass-effect -->
    <div class="glass-effect rounded-2xl p-6 md:p-10 relative overflow-hidden">
        
        {#if drvState === 'disconnected'}
            <div class="text-center py-12 px-4" transition:fade>
                <div class="w-24 h-24 mx-auto bg-blue-500/10 border border-blue-500/20 rounded-full flex items-center justify-center mb-6 glow-effect shadow-[0_0_30px_rgba(59,130,246,0.3)]">
                    <svg class="w-12 h-12 text-blue-700 dark:text-blue-400" fill="currentColor" viewBox="0 0 24 24"><path d="M7 21a2 2 0 01-1.73-1.002l-3-5.2A2 2 0 012.27 14h6.002L15.27 21H7zM16.997 21l3-5.196L14.496 6.275 8.494 6.273l5.503 9.53zM15.498 5.4H8.498A2.003 2.003 0 006.77 6.4h-.001L3.77 11.603a1.996 1.996 0 000 1.996L6.77 18.8z" /></svg>
                </div>
                <h2 class="text-3xl font-bold text-slate-900 dark:text-white mb-4">Conecta tu Google Drive</h2>
                <p class="text-blue-400/70 mb-10 max-w-md mx-auto">
                    EcoSync requiere permisos temporales para escanear tu Drive en busca de archivos pesados, duplicados ocultos y cachés que consumen energía en la nube.
                </p>
                <button onclick={connectDrive} class="px-8 py-4 bg-linear-to-r from-blue-500 to-indigo-600 text-white rounded-xl font-bold hover:scale-105 active:scale-95 transition-all duration-300 glow-effect flex items-center justify-center gap-3 mx-auto shadow-xl">
                    Verificar mi Drive
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                </button>
            </div>

        {:else if drvState === 'connecting' || drvState === 'scanning'}
            <div class="text-center py-20" transition:fade>
                <div class="flex justify-center mx-auto mb-5">
                    <InternetLoader />
                </div>

                <h3 class="text-2xl font-bold text-slate-900 dark:text-white mb-2">
                    {drvState === 'connecting' ? 'Iniciando enlace seguro con Google...' : 'Analizando archivos obsoletos en Drive...'}
                </h3>

                <p class="text-blue-400/70">Calculando hashes (MD5) para detectar archivos duplicados.</p>
            </div>

        {:else if drvState === 'results'}
            <div transition:fade>
                <div class="flex flex-col md:flex-row items-center justify-between mb-8 pb-8 border-b border-slate-900/10 dark:border-white/10 gap-6">
                    <div>
                        <h2 class="text-2xl font-bold text-slate-900 dark:text-white mb-1 flex items-center gap-3">
                            Análisis de Google Drive
                            <span class="px-3 py-1 bg-blue-700/20 dark:bg-blue-500/20 text-blue-700 dark:text-blue-400 text-sm rounded-lg border border-blue-500/30">Completado</span>
                        </h2>
                        <p class="text-blue-400/70">
                            Se analizaron <strong class="text-slate-900 dark:text-white">{scanStats.totalFiles} archivos</strong> en tu cuenta.
                        </p>
                    </div>
                    
                    <div class="flex gap-3 w-full md:w-auto">
                        <button onclick={deleteAllWaste} disabled={results.filter(r=>r.isWaste).length === 0} class="w-full md:w-auto px-6 py-3 bg-red-700/10 dark:bg-red-500/10 hover:bg-red-700/20 dark:hover:bg-red-500/20 text-red-700 dark:text-red-500 font-bold rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed border border-red-700/30 dark:border-red-500/30">
                            Limpiar Todo (Papelera)
                        </button>
                    </div>
                </div>

                <!-- Panel de Impacto CO₂ -->
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                    <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-5 border border-slate-900/10 dark:border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-blue-700/20 dark:bg-blue-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-blue-700 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-slate-900 dark:text-white">{scanStats.totalFiles}</p>
                        <p class="text-xs text-blue-400/70 mt-1">Archivos Totales</p>
                    </div>
                    <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-5 border border-slate-900/10 dark:border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-yellow-700/20 dark:bg-yellow-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-yellow-700 dark:text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-yellow-700 dark:text-yellow-400">{scanStats.inactiveFiles}</p>
                        <p class="text-xs text-blue-400/70 mt-1">Duplicados/Pesados</p>
                    </div>
                    <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-5 border border-slate-900/10 dark:border-white/10 text-center">
                        <div class="w-10 h-10 mx-auto rounded-lg bg-orange-500/20 flex items-center justify-center mb-3">
                            <svg class="w-5 h-5 text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path></svg>
                        </div>
                        <p class="text-2xl font-bold text-orange-400">{scanStats.totalSizeGB >= 1 ? scanStats.totalSizeGB.toFixed(2) + ' GB' : (scanStats.totalSizeGB * 1024).toFixed(1) + ' MB'}</p>
                        <p class="text-xs text-blue-400/70 mt-1">Almacenamiento Total</p>
                    </div>
                    <div class="bg-blue-500/5 rounded-xl p-5 border border-blue-500/20 text-center relative overflow-hidden">
                        <div class="absolute inset-0 bg-blue-500/5"></div>
                        <div class="relative">
                            <div class="w-10 h-10 mx-auto rounded-lg bg-emerald-700/20 dark:bg-emerald-500/20 flex items-center justify-center mb-3">
                                <svg class="w-5 h-5 text-emerald-700 dark:text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                            </div>
                            <p class="text-2xl font-bold text-emerald-700 dark:text-emerald-400">{scanStats.co2Saved >= 1000 ? (scanStats.co2Saved / 1000).toFixed(2) + ' kg' : scanStats.co2Saved.toFixed(1) + ' g'}</p>
                            <p class="text-xs text-blue-400/70 mt-1">CO₂ Potencial al Año</p>
                        </div>
                    </div>
                </div>

                <!-- Equivalencias del Mundo Real -->
                <div class="bg-blue-500/5 border border-blue-500/20 rounded-xl p-5 mb-8">
                    <h3 class="text-sm font-semibold text-blue-700 dark:text-blue-400 mb-3 flex items-center gap-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        Impacto Ambiental — Equivalencias (Ahorro Potencial)
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                        <div class="flex items-center gap-3">
                            <span class="text-xl">💡</span>
                            <div>
                                <p class="text-slate-900 dark:text-white font-medium">{(scanStats.co2Saved / 36).toFixed(1)} horas</p>
                                <p class="text-blue-400/60 text-xs">de bombilla LED encendida</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="text-xl">🚗</span>
                            <div>
                                <p class="text-slate-900 dark:text-white font-medium">{(scanStats.co2Saved / 120).toFixed(2)} km</p>
                                <p class="text-blue-400/60 text-xs">recorridos en automóvil</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="text-xl">🌳</span>
                            <div>
                                <p class="text-slate-900 dark:text-white font-medium">{(scanStats.co2Saved / 22000).toFixed(4)} árboles</p>
                                <p class="text-blue-400/60 text-xs">necesarios para absorberlo al año</p>
                            </div>
                        </div>
                    </div>
                </div>

                {#if results.length > 0}
                    <div class="bg-slate-900/5 dark:bg-white/5 rounded-2xl border border-slate-900/10 dark:border-white/10 overflow-hidden mb-8">
                        <div class="grid grid-cols-12 gap-4 px-6 py-4 border-b border-slate-900/10 dark:border-white/10 bg-slate-900/5 dark:bg-white/5 font-semibold text-sm text-blue-400/70">
                            <div class="col-span-1 flex items-center">
                                <input type="checkbox" checked={allSelected} onchange={toggleSelectAll} class="w-4 h-4 rounded border-slate-900/20 dark:border-white/20 bg-slate-900/5 dark:bg-white/5 text-blue-500 focus:ring-blue-500 focus:ring-offset-slate-900 cursor-pointer" />
                            </div>
                            <div class="col-span-5">Nombre / Archivo</div>
                            <div class="col-span-3">Categoría / Razón</div>
                            <div class="col-span-3 text-right">Tamaño / CO₂</div>
                        </div>

                        <div class="divide-y divide-white/10 max-h-[500px] overflow-y-auto">
                            {#each results as result (result.id)}
                                <label class="grid grid-cols-12 gap-4 px-6 py-4 items-center hover:bg-slate-900/5 dark:hover:bg-white/5 transition-colors cursor-pointer group {result.isWaste ? 'border-l-2 border-l-red-700/50 dark:border-l-red-500/50' : 'border-l-2 border-l-blue-500/30'}">
                                    <div class="col-span-1">
                                        {#if result.isWaste}
                                            <input type="checkbox" bind:checked={result.selected} class="w-4 h-4 rounded border-slate-900/20 dark:border-white/20 bg-slate-900/5 dark:bg-white/5 text-blue-500 focus:ring-blue-500 focus:ring-offset-slate-900 cursor-pointer" />
                                        {:else}
                                            <div class="w-4 h-4"></div>
                                        {/if}
                                    </div>
                                    <div class="col-span-5 font-medium text-slate-900 dark:text-white flex items-center gap-2 truncate">
                                        <svg class="w-5 h-5 shrink-0 {result.isWaste ? 'text-red-700/50 dark:text-red-400/50' : 'text-blue-400/50'}" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                                        <span class="truncate" title={result.name}>{result.name}</span>
                                    </div>
                                    <div class="col-span-3 text-sm text-blue-400/70">
                                        <span class="px-2 py-1 rounded-md text-xs inline-block capitalize mb-1 {result.isWaste ? 'bg-red-700/10 dark:bg-red-500/10 border border-red-700/30 dark:border-red-500/30 text-red-700 dark:text-red-400' : 'bg-blue-500/10 border border-blue-500/30 text-blue-700 dark:text-blue-400'}">{result.type}</span>
                                        {#if result.isWaste && result.wasteReason}
                                            <p class="text-[10px] text-slate-900/40 dark:text-white/40 leading-tight">{result.wasteReason}</p>
                                        {/if}
                                    </div>
                                    <div class="col-span-3 text-right flex flex-col items-end">
                                        <span class="font-bold text-slate-900 dark:text-white">{result.size}</span>
                                        <span class="text-xs text-emerald-700 dark:text-emerald-400">{result.co2}/año</span>
                                    </div>
                                </label>
                            {/each}
                        </div>
                    </div>

                    <div class="flex justify-end">
                        <button onclick={deleteSelected} disabled={selectedCount === 0} class="px-8 py-4 bg-linear-to-r from-blue-500 to-indigo-600 text-white font-bold rounded-xl hover:scale-105 active:scale-95 transition-all duration-300 glow-effect disabled:opacity-50 disabled:hover:scale-100 disabled:cursor-not-allowed shadow-xl">
                            Mover a Papelera ({selectedCount})
                        </button>
                    </div>
                {:else}
                    <div class="text-center py-16 bg-slate-900/5 dark:bg-white/5 rounded-2xl border border-dashed border-slate-900/20 dark:border-white/20">
                        <div class="w-16 h-16 mx-auto bg-blue-700/20 dark:bg-blue-500/20 rounded-full flex items-center justify-center mb-4 text-blue-700 dark:text-blue-400 glow-effect">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        </div>
                        <h3 class="text-xl font-bold text-slate-900 dark:text-white mb-2">¡Tu Drive está optimizado!</h3>
                        <p class="text-blue-400/70">No se encontraron archivos duplicados o basura severa.</p>
                    </div>
                {/if}
            </div>
        {/if}
    </div>
</div>

<ConfirmDelete
    bind:open={ showConfirmDialog }
    title="Confirmar Borrado"
    message={ confirmMessage }
    onConfirm={ () => deleteSelected( true ) }
/>
