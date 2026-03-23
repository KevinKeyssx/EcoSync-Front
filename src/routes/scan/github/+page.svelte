<script lang="ts">
  import InternetLoader from '$lib/loaders/InternetLoader.svelte';
  import SearchLoader from '$lib/loaders/SearchLoader.svelte';
    import { fade } from 'svelte/transition';

    type GithubState = 'disconnected' | 'connecting' | 'scanning' | 'results';
    let ghState: GithubState = $state('disconnected');

    let mockResults = $state([
        { id: 1, name: 'EcoSync-old-prototype', type: 'Repo inactivo', size: '45 MB', co2: '12g', selected: false },
        { id: 2, name: 'react-tutorial-fork', type: 'Fork no sincronizado', size: '120 MB', co2: '32g', selected: false },
        { id: 3, name: 'feature/experimental-ui', type: 'Rama stale', size: '2 MB', co2: '0.5g', selected: false },
        { id: 4, name: 'test-api-bot', type: 'Repo vacío', size: '1 MB', co2: '0.2g', selected: false }
    ]);

    let allSelected = $derived(mockResults.length > 0 && mockResults.every(r => r.selected));
    let selectedCount = $derived(mockResults.filter(r => r.selected).length);

    function toggleSelectAll() {
        const newState = !allSelected;
        mockResults = mockResults.map(item => ({ ...item, selected: newState }));
    }

    function connectGithub() {
        ghState = 'connecting';
        setTimeout(() => {
            ghState = 'scanning';
            setTimeout(() => {
                ghState = 'results';
            }, 2500);
        }, 1500);
    }

    function deleteSelected() {
        if(selectedCount === 0) return;
        mockResults = mockResults.filter(item => !item.selected);
        alert(`Se han eliminado ${selectedCount} elementos correctamente.`);
    }

    function deleteAll() {
        const total = mockResults.length;
        if(total === 0) return;
        mockResults = [];
        alert(`Limpieza automática completada. Se eliminaron ${total} elementos.`);
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
                <!-- <div class="inline-flex items-center justify-center w-24 h-24 rounded-full bg-emerald-500/20 mb-8 animate-pulse-slow">
                    <SearchLoader />
                </div> -->

                <div class="flex justify-center mx-auto mb-5">
                    <InternetLoader />
                </div>

                <h3 class="text-2xl font-bold text-white mb-2">
                    {ghState === 'connecting' ? 'Estableciendo conexión segura...' : 'Escaneando ramas y repositorios inactivos...'}
                </h3>

                <p class="text-emerald-400/70">Este proceso puede tardar unos segundos.</p>
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
                            Se detectaron <strong class="text-white">{mockResults.length} elementos</strong> obsoletos que generan una huella constante.
                        </p>
                    </div>
                    
                    <div class="flex gap-3 w-full md:w-auto">
                        <button onclick={deleteAll} disabled={mockResults.length === 0} class="w-full md:w-auto px-6 py-3 bg-red-500/10 hover:bg-red-500/20 text-red-500 font-bold rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed border border-red-500/30">
                            Eliminar Todo (Auto)
                        </button>
                    </div>
                </div>

                {#if mockResults.length > 0}
                    <div class="bg-white/5 rounded-2xl border border-white/10 overflow-hidden mb-8">
                        <div class="grid grid-cols-12 gap-4 px-6 py-4 border-b border-white/10 bg-white/5 font-semibold text-sm text-emerald-400/70">
                            <div class="col-span-1 flex items-center">
                                <input type="checkbox" checked={allSelected} onchange={toggleSelectAll} class="w-4 h-4 rounded border-white/20 bg-white/5 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-slate-900 cursor-pointer" />
                            </div>
                            <div class="col-span-5">Nombre / Ruta</div>
                            <div class="col-span-3">Categoría</div>
                            <div class="col-span-3 text-right">Impacto (Tamaño / CO₂)</div>
                        </div>

                        <div class="divide-y divide-white/10">
                            {#each mockResults as result (result.id)}
                                <label class="grid grid-cols-12 gap-4 px-6 py-4 items-center hover:bg-white/5 transition-colors cursor-pointer group">
                                    <div class="col-span-1">
                                        <input type="checkbox" bind:checked={result.selected} class="w-4 h-4 rounded border-white/20 bg-white/5 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-slate-900 cursor-pointer" />
                                    </div>
                                    <div class="col-span-5 font-medium text-white flex items-center gap-2">
                                        <svg class="w-5 h-5 text-emerald-400/50" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path></svg>
                                        {result.name}
                                    </div>
                                    <div class="col-span-3 text-sm text-emerald-400/70">
                                        <span class="px-2 py-1 bg-white/5 border border-white/10 rounded-md text-xs">{result.type}</span>
                                    </div>
                                    <div class="col-span-3 text-right flex flex-col items-end">
                                        <span class="font-bold text-white">{result.size}</span>
                                        <span class="text-xs text-emerald-400 glow-effect">{result.co2}/año</span>
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
                        <p class="text-emerald-400/70">No se encontraron más repositorios o ramas residuales. Tu GitHub está optimizado.</p>
                    </div>
                {/if}
            </div>
        {/if}
    </div>
</div>
