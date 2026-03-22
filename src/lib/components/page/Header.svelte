<script lang="ts">
	import DarkModeToggle from '$lib/components/page/DarkModeToggle.svelte';

	interface Props {
		darkMode	: boolean;
		onToggle	: ( ) => void;
	}

	let { darkMode, onToggle } : Props = $props( );
</script>

<header class="fixed top-0 w-full h-18 bg-white/70 dark:bg-slate-950/70 backdrop-blur-xl flex justify-between items-center z-50 border-b border-gray-200 dark:border-white/10 transition-colors pointer-events-none px-6">
	<div class="h-full flex items-center pointer-events-auto shrink-0 relative gap-3 p-1">
		<a href="/" class="flex h-full items-center no-underline relative group transition-transform hover:scale-105 active:scale-95 duration-300">
            <!-- EcoSync Logo (Anti-aliasing fix) -->
            <div class="relative flex items-center justify-center w-11 h-11 shrink-0">
                <div class="absolute inset-0 bg-emerald-500 blur-md opacity-20 group-hover:opacity-40 transition-opacity duration-300 rounded-full"></div>
                <img 
                    src="/logoSmall.avif" 
                    alt="EcoSync Logo" 
                    class="w-9 h-9 object-contain relative z-10 transition-transform duration-300 group-hover:scale-105"
                    style="image-rendering: high-quality;"
                />
            </div>
			<div class="ml-3 flex flex-col justify-center">
				<span class="font-bold text-slate-800 dark:text-emerald-400 tracking-wide text-xl leading-none">EcoSync</span>
				<span class="text-xs text-emerald-600/80 dark:text-slate-400 uppercase tracking-widest font-medium mt-0.5">Optimizer</span>
			</div>
		</a>
	</div>

	<!-- Selector de idioma y DarkModeToggle a la derecha -->
	<div class="flex items-center gap-4 pointer-events-auto shrink-0">
		<DarkModeToggle darkMode={ darkMode } onToggle={ onToggle } />
	</div>
</header>
