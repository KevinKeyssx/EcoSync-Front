<script lang="ts">
    import { page } from '$app/state';
    let { children } = $props();
    
    let isSubpage = $derived(page.url.pathname !== '/scan');
</script>

<main class="w-full h-full p-4 md:p-8">
    <div class="max-w-7xl mx-auto">
        <header class="mb-4 md:mb-8 animate-slide-up">
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
                        <p class="text-sm text-emerald-700/70 dark:text-emerald-400/70">Módulos de Limpieza</p>
                    </div>
                </div>

                <nav class="flex gap-2">
                    <a href="/dashboard" class="px-4 py-2 rounded-xl transition-all duration-300 glass-effect text-emerald-700 dark:text-emerald-400 hover:bg-slate-900/10 dark:hover:bg-white/10">
                        Dashboard
                    </a>
                </nav>
            </div>

            {#if isSubpage}
                <a href="/scan" class="inline-flex items-center gap-2 text-emerald-700/70 dark:text-emerald-400/70 hover:text-emerald-700 dark:hover:text-emerald-400 transition-colors font-semibold group rounded-lg focus:outline-none mt-2">
                    <svg class="w-5 h-5 group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
                    Volver al Hub
                </a>
            {/if}
        </header>

        <div class="animate-slide-up" style="animation-delay: 0.1s">
            {@render children()}
        </div>
    </div>
</main>
