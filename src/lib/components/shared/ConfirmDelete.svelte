<script lang="ts">
	import Dialog from './Dialog.svelte';

	interface Props {
		open		: boolean;
		title		: string;
		message		: string;
		onConfirm	: () => void;
		onCancel?	: () => void;
	}

	let {
		open		= $bindable( false ),
		title,
		message,
		onConfirm,
		onCancel
	}: Props = $props();

	function handleConfirm() {
		open = false;
		onConfirm();
	}

	function handleCancel() {
		open = false;
		if ( onCancel ) {
			onCancel();
		}
	}
</script>

<Dialog bind:open onClose={ handleCancel }>
	<div class="text-slate-900 dark:text-white">
		<div class="flex items-center gap-3 mb-4">
			<div class="w-10 h-10 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center shrink-0">
				<svg class="w-5 h-5 text-red-600 dark:text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
				</svg>
			</div>
			<h3 class="text-xl font-bold">{ title }</h3>
		</div>
		
		<p class="mb-6 whitespace-pre-wrap text-sm text-slate-700 dark:text-slate-300">{ message }</p>

		<div class="flex justify-end gap-3 mt-6">
			<button 
				class="px-5 py-2.5 rounded-xl font-medium text-slate-700 dark:text-slate-300 bg-slate-100/50 hover:bg-slate-200 dark:bg-slate-800/50 dark:hover:bg-slate-700 transition-colors focus:ring-2 focus:ring-slate-400 focus:outline-none"
				onclick={ handleCancel }
			>
				Cancelar
			</button>
			<button 
				class="px-5 py-2.5 rounded-xl font-bold text-white bg-red-600 hover:bg-red-700 dark:bg-red-500 dark:hover:bg-red-600 shadow-lg shadow-red-500/30 transition-all focus:ring-2 focus:ring-red-400 focus:outline-none hover:scale-105 active:scale-95"
				onclick={ handleConfirm }
			>
				Sí, Borrar
			</button>
		</div>
	</div>
</Dialog>
