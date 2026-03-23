<script lang="ts">
    import { goto }     from '$app/navigation';
    import { onMount }  from 'svelte';

    import type { Scan }    from '$lib/types';
    import StatCard         from '$lib/StatCard.svelte';
    import CO2Visualizer    from '$lib/CO2Visualizer.svelte';


    let scans: Scan[]   = $state( [] );
    let loading         = $state( true );
    let totalCO2Saved   = $state( 0 );
    let totalWasteGB    = $state( 0 );
    let totalScans      = $state( 0 );


    onMount(async () => {
        await loadScans();
    });


    async function loadScans() {
        loading = true;
        try {
            // Simula fetch
            await new Promise(resolve => setTimeout(resolve, 500));
            scans = []; // Datos simulados vacíos en local
            calculateTotals();
        } catch (err) {
            console.error('Error loading scans:', err);
        } finally {
            loading = false;
        }
    }


    function calculateTotals() {
        totalCO2Saved = scans.reduce((sum, scan) => sum + Number(scan.co2_saved_estimate_g), 0);
        totalWasteGB = scans.reduce((sum, scan) => sum + Number(scan.waste_size_gb), 0);
        totalScans = scans.length;
    }


    function formatDate(dateString: string) {
        return new Date(dateString).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
</script>

<main class=" p-4 md:p-8">
    <div class="max-w-7xl mx-auto">
        <header class="mb-8 animate-slide-up">
            <div class="flex items-center justify-between mb-6">
                <div class="flex items-center gap-3">
                    <div class="relative flex items-center justify-center w-12 h-12 shrink-0">
                        <div class="absolute inset-0 bg-emerald-500 blur-md opacity-20 rounded-full glow-effect"></div>
                        <img 
                            src="/logoSmall.avif" 
                            alt="EcoSync Logo" 
                            class="w-10 h-10 object-contain relative z-10"
                            style="image-rendering: high-quality;"
                        />
                    </div>

                    <div>
                        <h1 class="text-3xl md:text-4xl font-bold text-transparent bg-clip-text bg-linear-to-r from-emerald-400 to-teal-300">
                            Eco-Sync
                        </h1>

                        <p class="text-sm text-emerald-400/70">Digital Footprint Optimizer</p>
                    </div>
                </div>

                <nav class="flex gap-2">
                    <button
                        onclick={() => goto('/scan')}
                        class="px-4 py-2 rounded-xl transition-all duration-300 glass-effect text-emerald-400 hover:bg-white/10"
                    >
                        Scan
                    </button>
                </nav>
            </div>
        </header>

        <div class="animate-slide-up" style="animation-delay: 0.1s">
            <div class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <StatCard
                        title="Total CO₂ Saved"
                        value="{(totalCO2Saved / 1000).toFixed(2)} kg"
                        icon="leaf"
                        color="emerald"
                        loading={loading}
                    />
                    <StatCard
                        title="Waste Cleaned"
                        value="{totalWasteGB.toFixed(2)} GB"
                        icon="trash"
                        color="blue"
                        loading={loading}
                    />
                    <StatCard
                        title="Total Scans"
                        value={`${totalScans + 1}`}
                        icon="scan"
                        color="teal"
                        loading={loading}
                    />
                </div>

                <CO2Visualizer co2SavedGrams={totalCO2Saved} />

                <div class="glass-effect rounded-2xl p-6">
                    <div class="flex items-center justify-between mb-6">
                        <h2 class="text-2xl font-bold text-emerald-400">Recent Scans</h2>
                        <button
                            onclick={() => goto('/scan')}
                            class="px-6 py-3 bg-linear-to-r from-emerald-500 to-teal-600 text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all duration-300 glow-effect"
                        >
                            Start New Scan
                        </button>
                    </div>

                    {#if loading}
                        <div class="flex items-center justify-center py-12">
                            <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-emerald-400"></div>
                        </div>
                    {:else if scans.length === 0}
                        <div class="text-center py-12">
                            <svg class="w-16 h-16 mx-auto mb-4 text-emerald-400/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                            <p class="text-emerald-400/70 mb-4">No scans yet. Start your first scan to optimize your digital footprint!</p>
                            <button
                                onclick={() => goto('/scan')}
                                class="px-6 py-3 bg-emerald-500 text-white rounded-xl hover:bg-emerald-600 transition-colors"
                            >
                                Get Started
                            </button>
                        </div>
                    {:else}
                        <div class="space-y-3">
                            {#each scans as scan}
                                <div class="bg-white/5 rounded-xl p-4 hover:bg-white/10 transition-all duration-300 border border-white/10">
                                    <div class="flex items-center justify-between">
                                        <div class="flex-1">
                                            <div class="flex items-center gap-3">
                                                <div class="w-10 h-10 rounded-lg bg-emerald-500/20 flex items-center justify-center">
                                                    <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                                    </svg>
                                                </div>
                                                <div>
                                                    <h3 class="text-white font-semibold">{scan.source_type.charAt(0).toUpperCase() + scan.source_type.slice(1)} Scan</h3>
                                                    <p class="text-sm text-emerald-400/70">{formatDate(scan.scan_date)}</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="text-right space-y-1">
                                            <div class="text-sm text-emerald-400">
                                                <span class="font-semibold">{scan.waste_files}</span> waste files
                                            </div>
                                            <div class="text-sm text-emerald-400/70">
                                                {Number(scan.waste_size_gb).toFixed(2)} GB
                                            </div>
                                            <div class="text-xs text-emerald-400 font-semibold">
                                                {Number(scan.co2_saved_estimate_g).toFixed(0)}g CO₂ saved
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            {/each}
                        </div>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</main>
