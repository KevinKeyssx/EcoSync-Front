<script lang="ts">
    import { fade } from 'svelte/transition';

    const tools = [
        { id: 'github', name: 'GitHub', desc: 'Identifica y limpia repositorios abandonados, forks no sincronizados y ramas muertas.', status: 'active' },
        { id: 'drive', name: 'Google Drive', desc: 'Encuentra archivos pesados, duplicados y cachés residuales ocultos.', status: 'dev' },
        { id: 'local', name: 'Almacenamiento Local', desc: 'Analiza tu disco duro para liberar espacio y reducir requerimientos energéticos.', status: 'dev' },
        { id: 'onedrive', name: 'Microsoft Cloud', desc: 'Depura tu OneDrive corporativo y bandejas de correo antiguas.', status: 'dev' },
        { id: 'accounts', name: 'Cuentas Fantasmas', desc: 'Rastrea y elimina cuentas web olvidadas para apagar tu rastro digital.', status: 'dev' }
    ];
</script>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" transition:fade>
    {#each tools as tool}
        <svelte:element 
            this={tool.status === 'active' ? 'a' : 'div'}
            href={tool.status === 'active' ? `/scan/${tool.id}` : undefined}
            class="text-left rounded-2xl p-6 transition-all duration-300 relative overflow-hidden flex flex-col h-full focus:outline-none focus:ring-2 focus:ring-emerald-500/50
                {tool.status === 'active' 
                    ? 'glass-effect hover:bg-white/10 hover:-translate-y-1 cursor-pointer group hover:shadow-[0_0_20px_rgba(52,211,153,0.1)] block' 
                    : 'bg-white/5 border border-white/5 opacity-50 cursor-not-allowed filter grayscale'}"
        >
            <div class="flex items-center justify-between mb-4 relative z-10 w-full">
                <div class="w-12 h-12 rounded-xl flex items-center justify-center transition-all duration-300
                    {tool.status === 'active' ? 'bg-emerald-500/20 text-emerald-400 group-hover:scale-110 glow-effect' : 'bg-white/10 text-white/50'}">
                    
                    {#if tool.id === 'github'}
                        <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.166 6.839 9.489.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.603-3.369-1.34-3.369-1.34-.454-1.156-1.11-1.463-1.11-1.463-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.831.092-.646.35-1.086.636-1.336-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.161 22 16.418 22 12c0-5.523-4.477-10-10-10z"/></svg>
                    {:else if tool.id === 'drive'}
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path></svg>
                    {:else if tool.id === 'local'}
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-2m3 2v-2m-9-2h12M5 8h14M3 21h18a2 2 0 002-2V5a2 2 0 00-2-2H3a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                    {:else if tool.id === 'onedrive'}
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"></path></svg>
                    {:else}
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                    {/if}
                </div>
                
                {#if tool.status === 'dev'}
                    <span class="px-2 py-1 rounded bg-white/10 text-white/50 text-xs font-medium tracking-wide">
                        En Desarrollo
                    </span>
                {:else}
                    <span class="px-2 py-1 rounded bg-emerald-500/20 text-emerald-400 border border-emerald-400/30 text-xs font-semibold tracking-wide shadow-[0_0_10px_rgba(16,185,129,0.1)] glow-effect">
                        Disponible
                    </span>
                {/if}
            </div>

            <h3 class="relative z-10 text-xl font-bold {tool.status === 'active' ? 'text-white' : 'text-white/70'} mb-2">{tool.name}</h3>
            <p class="relative z-10 {tool.status === 'active' ? 'text-emerald-400/70' : 'text-white/40'} text-sm leading-relaxed">{tool.desc}</p>
        </svelte:element>
    {/each}
</div>
