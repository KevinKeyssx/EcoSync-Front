<script lang="ts">
    import { onMount } from 'svelte';

    import { Toaster } from 'svelte-sonner'

	import { initDarkMode, setDarkMode }    from '$lib/utils/darkMode';
    import Header                           from '$lib/components/page/Header.svelte';
    import Footer                           from '$lib/components/page/Footer.svelte';

    import './layout.css';


    let { children } = $props();


    let darkMode = $state( false );


    onMount( () => {
		darkMode = initDarkMode();
	});


    function handleToggle() {
		darkMode = !darkMode;
		setDarkMode( darkMode );
	}
</script>

<svelte:head><link rel="icon" href="/favicon.png" type="image/png" /></svelte:head>

<Toaster position="bottom-right" richColors />

<main class="relative flex flex-col min-h-screen bg-white dark:bg-slate-950 transition-colors duration-300 overflow-hidden">
    <!-- Efecto Glow de Fondo (Franja Diagonal Clara y Esquinas) -->
    <div class="fixed inset-0 pointer-events-none z-0">
        <!-- Franja brillante principal cruzando de abajo-izq a arriba-der -->
        <div class="absolute top-1/2 left-1/2 w-[150%] h-[30%] -translate-x-1/2 -translate-y-1/2 -rotate-45 bg-linear-to-r from-emerald-300/40 via-teal-200/50 to-emerald-300/40 dark:from-emerald-500/10 dark:via-teal-400/15 dark:to-emerald-500/10 blur-[100px]"></div>

        <!-- Foco adicional abajo a la izquierda -->
        <div class="absolute -bottom-1/4 -left-1/4 w-1/2 h-1/2 bg-emerald-400/40 dark:bg-emerald-700/20 dark:dark:bg-emerald-500/20 blur-[120px] rounded-full"></div>

        <!-- Foco adicional arriba a la derecha -->
        <div class="absolute -top-1/4 -right-1/4 w-1/2 h-1/2 bg-teal-300/40 dark:bg-teal-400/20 blur-[120px] rounded-full"></div>
    </div>

    <!-- Contenido de la Aplicación -->
    <section class="relative z-10 flex flex-col flex-1 w-full">
        <Header {darkMode} onToggle={handleToggle} />

        <div class="flex flex-col flex-1 w-full mx-auto px-4 sm:px-6 pt-24 pb-12">
            {@render children()}
        </div>

        <Footer />
    </section>
</main>
