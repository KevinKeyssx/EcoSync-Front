<div class="flex flex-col items-center justify-center min-h-[80vh] w-full text-center px-4 sm:px-6 relative z-10">
    <!-- Hero Section centralizada -->
    <div class="max-w-4xl mx-auto space-y-8 animate-slide-up">
        
        <!-- Hero Logo Flotante -->
        <div class="w-full flex justify-center mb-2">
            <div class="relative group">
                <div class="absolute inset-0 bg-emerald-400 blur-2xl opacity-20 group-hover:opacity-50 transition-opacity duration-700 rounded-full"></div>
                <img 
                    src="/logo.avif" 
                    alt="EcoSync" 
                    class="w-32 h-32 md:w-40 md:h-40 object-contain relative z-10 drop-shadow-[0_0_20px_rgba(52,211,153,0.3)] hover:scale-105 transition-transform duration-500"
                />
            </div>
        </div>

        <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-600 dark:text-emerald-400 text-sm font-medium shadow-[0_0_15px_rgba(16,185,129,0.15)] backdrop-blur-md">
            <span class="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></span>
            EcoSync v1.0 disponible
        </div>

        <h1 class="text-5xl md:text-7xl font-extrabold tracking-tight text-slate-900 dark:text-white leading-tight">
            Optimiza tu Huella de <br class="hidden sm:block" />
            <span class="text-transparent bg-clip-text bg-linear-to-r from-emerald-400 via-teal-400 to-emerald-300">
                Carbono Digital
            </span>
        </h1>

        <p class="text-lg md:text-xl text-slate-600 dark:text-slate-400 max-w-2xl mx-auto leading-relaxed">
            Detecta, analiza y limpia archivos inútiles dispersos en tu entorno para recuperar espacio vital y reducir las emisiones de CO₂ generadas por el almacenamiento innecesario en servidores.
        </p>

        <!-- CTA Botones -->
        <div class="pt-6 flex flex-col sm:flex-row items-center justify-center gap-4">
            <a href="/dashboard" class="px-8 py-4 w-full sm:w-auto rounded-2xl bg-linear-to-r from-emerald-500 to-teal-500 text-white font-semibold text-lg hover:shadow-[0_0_20px_rgba(16,185,129,0.4)] hover:scale-105 active:scale-95 transition-all duration-300">
                Lanzar Optimizador
            </a>
            <a href="#caracteristicas" class="px-8 py-4 w-full sm:w-auto rounded-2xl bg-white/50 dark:bg-white/5 border border-slate-200 dark:border-white/10 text-slate-700 dark:text-slate-300 font-semibold text-lg hover:bg-slate-50 dark:hover:bg-white/10 transition-all duration-300 backdrop-blur-sm">
                Saber más
            </a>
        </div>
    </div>

    <!-- Cards de Características (Features) - Glassmorphism -->
    <div id="caracteristicas" class="mt-32 grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-6xl animate-slide-up" style="animation-delay: 0.2s;">
        
        <!-- Tarjeta 1 -->
        <div class="rounded-2xl p-8 text-left hover:-translate-y-2 transition-transform duration-300 border border-slate-200 dark:border-white/10 bg-white/40 dark:bg-slate-900/40 backdrop-blur-xl shadow-lg">
            <div class="w-12 h-12 rounded-xl bg-emerald-100 dark:bg-emerald-500/20 text-emerald-600 dark:text-emerald-400 flex items-center justify-center mb-6">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
            </div>
            <h3 class="text-xl font-bold text-slate-900 dark:text-white mb-3">Escaneo Inteligente</h3>
            <p class="text-slate-600 dark:text-slate-400 text-sm leading-relaxed">
                Nuestros rastreadores detectan rápidamente elementos pesados y duplicados ocultos, presentándote un resumen detallado y visual en segundos sin consumir recursos extra.
            </p>
        </div>

        <!-- Tarjeta 2 -->
        <div class="rounded-2xl p-8 text-left hover:-translate-y-2 transition-transform duration-300 border border-slate-200 dark:border-white/10 bg-white/40 dark:bg-slate-900/40 backdrop-blur-xl shadow-lg">
            <div class="w-12 h-12 rounded-xl bg-teal-100 dark:bg-teal-500/20 text-teal-600 dark:text-teal-400 flex items-center justify-center mb-6">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
            </div>
            <h3 class="text-xl font-bold text-slate-900 dark:text-white mb-3">Limpieza Segura</h3>
            <p class="text-slate-600 dark:text-slate-400 text-sm leading-relaxed">
                Elimina archivos residuales con un clic de forma totalmente segura. Tú tienes la decisión final sobre la categorización y qué elementos específicos deseas depurar.
            </p>
        </div>

        <!-- Tarjeta 3 -->
        <div class="rounded-2xl p-8 text-left hover:-translate-y-2 transition-transform duration-300 border border-slate-200 dark:border-white/10 bg-white/40 dark:bg-slate-900/40 backdrop-blur-xl shadow-lg">
            <div class="w-12 h-12 rounded-xl bg-emerald-100 dark:bg-emerald-500/20 text-emerald-600 dark:text-emerald-400 flex items-center justify-center mb-6">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
                </svg>
            </div>
            <h3 class="text-xl font-bold text-slate-900 dark:text-white mb-3">Impacto Real</h3>
            <p class="text-slate-600 dark:text-slate-400 text-sm leading-relaxed">
                Visualiza matemáticamente cuántos gramos de monóxido de carbono (CO₂) estás ahorrándole al planeta al reducir tu necesidad de refrigeración de datos inútiles diarios.
            </p>
        </div>

    </div>
</div>
