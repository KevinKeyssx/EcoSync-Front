<script lang="ts">
	import { fade, scale } from 'svelte/transition';
	import type { Snippet } from 'svelte';

	interface Props {
		open		: boolean;
		onClose?	: () => void;
		children	: Snippet;
	}

	let {
		open = $bindable( false ),
		onClose,
		children
	}: Props = $props();

	function closeDialog() {
		open = false;
		if ( onClose ) {
			onClose();
		}
	}

	function handleKeydown( event: KeyboardEvent ) {
		if ( event.key === 'Escape' && open ) {
			closeDialog();
		}
	}
</script>

<svelte:window onkeydown={ handleKeydown } />

{#if open}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div 
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 dark:bg-black/40 backdrop-blur-sm transition-all duration-300"
		transition:fade={ ({
			duration	: 200
		}) }
		onclick={ closeDialog }
	>
		<!-- svelte-ignore a11y_click_events_have_key_events -->
		<!-- svelte-ignore a11y_no_static_element_interactions -->
		<div 
			class="relative w-full max-w-xl mx-4 p-6 sm:p-8 rounded-2xl border border-slate-200/50 dark:border-white/10 shadow-2xl glass-effect"
			transition:scale={ ({
				start		: 0.95,
				duration	: 200
			}) }
			onclick={ ( e ) => e.stopPropagation() }
		>
			<button 
				class="absolute top-4 right-4 p-2 rounded-full text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-white hover:bg-slate-200/50 dark:hover:bg-white/10 transition-colors focus:outline-none focus:ring-2 focus:ring-emerald-500"
				onclick={ closeDialog }
				aria-label="Cerrar diálogo"
			>
				<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
				</svg>
			</button>

			<div class="mt-2 w-full text-slate-900 dark:text-white">
				{@render children() }
			</div>
		</div>
	</div>
{/if}
