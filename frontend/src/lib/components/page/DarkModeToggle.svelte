<script lang="ts">
    import MoonIcon from "$lib/icons/MoonIcon.svelte";
    import SunIcon  from "$lib/icons/SunIcon.svelte";


    interface Props {
		darkMode : boolean;
		onToggle : () => void;
	}


    let { darkMode, onToggle }: Props = $props();
</script>

<button
	onclick={onToggle}
	aria-label={darkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
	class="w-10 h-10 rounded-full flex items-center justify-center bg-white dark:bg-gray-800 shadow-md border border-gray-200 dark:border-gray-700 hover:scale-110 active:scale-95 transition-all duration-200"
>
    <span class="text-lds-navy dark:text-lds-gold">
        {#if darkMode}
            <!-- Sol -->
            <SunIcon />
        {:else}
            <!-- Luna -->
            <MoonIcon />
        {/if}
    </span>
</button>
