<script lang="ts">
  import InternetLoader from '$lib/loaders/InternetLoader.svelte';
  import { fade, slide } from 'svelte/transition';
  import { toast } from 'svelte-sonner';

  import { PUBLIC_URL_API } from '$env/static/public';

  const API = PUBLIC_URL_API;

  type OsintState = 'idle' | 'scanning' | 'results';
  let scanState: OsintState = $state('idle');
  let username = $state('');

  interface AccountFound {
    platform: string;
    profile_url: string;
    delete_url: string;
    estimated_co2_grams: number;
    status: string;
  }

  let results: AccountFound[] = $state([]);
  let scanStats = $state({ totalAccounts: 0, totalCo2: 0 });

  async function startOsintScan() {
    const cleanUser = username.trim();
    if ( !cleanUser || cleanUser.length < 3 ) {
      toast.warning( "Por favor ingresa un nombre de usuario de al menos 3 caracteres." );
      return;
    }

    scanState = 'scanning';
    results = [];

    try {
      const res = await fetch(`${API}/osint/scan?username=${encodeURIComponent(cleanUser)}`);
      if (!res.ok) throw new Error('Failed to scan OSINT');
      
      const data = await res.json();
      results = data.platforms || [];
      
      scanStats = {
        totalAccounts: data.accounts_found,
        totalCo2: data.total_co2_grams
      };

      // Guardar en localStorage para Dashboard
      const scanData = {
        id: 'scan-' + Date.now(),
        user_id: cleanUser,
        scan_date: new Date().toISOString(),
        total_files: 0,
        total_size_gb: 0,
        waste_files: data.accounts_found,
        waste_size_gb: 0,
        co2_saved_estimate_g: data.total_co2_grams,
        source_type: 'osint',
        created_at: new Date().toISOString()
      };
      const history = JSON.parse(localStorage.getItem('ecoSyncScans') || '[]');
      history.unshift(scanData);
      localStorage.setItem('ecoSyncScans', JSON.stringify(history));

      scanState = 'results';
    } catch ( e ) {
      console.error( e );
      toast.error( 'Hubo un error contactando al servidor.' );
      scanState = 'idle';
    }
  }

  function getPlatformIcon(platform: string) {
    const p = platform.toLowerCase();
    if (p.includes('github') || p.includes('gitlab') || p.includes('bitbucket')) return '💻';
    if (p.includes('reddit') || p.includes('hackernews') || p.includes('dev.to')) return '💬';
    if (p.includes('twitter') || p.includes('instagram') || p.includes('pinterest') || p.includes('flickr') || p.includes('deviantart')) return '📸';
    if (p.includes('spotify') || p.includes('soundcloud') || p.includes('vimeo')) return '🎵';
    if (p.includes('blogger') || p.includes('medium') || p.includes('wattpad')) return '✍️';
    if (p.includes('patreon')) return '💳';
    return '🌐';
  }
</script>

<div class="w-full" transition:fade>
    <!-- Tarjeta Principal del Scanner usando Glass-effect -->
    <div class="glass-effect rounded-2xl p-6 md:p-10 relative overflow-hidden">
        
        {#if scanState === 'idle'}
            <div class="text-center py-12 px-4 max-w-2xl mx-auto" transition:fade>
                <div class="w-24 h-24 mx-auto bg-purple-500/10 border border-purple-500/20 rounded-full flex items-center justify-center mb-6 glow-effect shadow-[0_0_30px_rgba(168,85,247,0.3)]">
                    <svg class="w-12 h-12 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 11c0 3.517-1.009 6.799-2.753 9.571m-3.44-2.04l.054-.09A13.916 13.916 0 008 11a4 4 0 118 0c0 1.017-.07 2.019-.203 3m-2.118 6.844A21.88 21.88 0 0015.171 17m3.839 1.132c.645-2.266.99-4.659.99-7.132A8 8 0 008 4.07M3 15.364c.64-1.319 1-2.8 1-4.364 0-1.457.39-2.823 1.07-4"></path></svg>
                </div>
                <h2 class="text-3xl font-bold text-slate-900 dark:text-white mb-4">Cazador de Cuentas Fantasmas</h2>
                <p class="text-purple-400/70 mb-8">
                    EcoSync usará inteligencia de fuentes abiertas (OSINT) para buscar tu apodo o nombre de usuario en decenas de plataformas. Encuentra perfiles olvidados y da el paso para borrarlos.
                </p>

                <div class="flex flex-col sm:flex-row gap-4 max-w-lg mx-auto mb-6">
                    <input 
                        type="text" 
                        bind:value={username} 
                        placeholder="Ej: midudev" 
                        onkeydown={(e) => e.key === 'Enter' && startOsintScan()}
                        class="flex-1 bg-black/40 border border-purple-500/30 rounded-xl px-6 py-4 text-slate-900 dark:text-white text-lg focus:outline-none focus:border-purple-500 transition-colors shadow-inner"
                    />
                    <button 
                        onclick={startOsintScan} 
                        disabled={!username.trim()}
                        class="px-8 py-4 bg-linear-to-r from-purple-500 to-fuchsia-600 text-white rounded-xl font-bold hover:scale-105 active:scale-95 transition-all duration-300 glow-effect disabled:opacity-50 disabled:cursor-not-allowed shadow-xl flex items-center justify-center gap-2"
                    >
                        <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                        Rastrear
                    </button>
                </div>
                
                <p class="text-xs text-white/30 italic">
                    Nota: Este sistema busca coincidencias globales. Es posible que encuentres cuentas creadas por otras personas que eligieron el mismo alias.
                </p>
            </div>

        {:else if scanState === 'scanning'}
            <div class="text-center py-20" transition:fade>
                <div class="flex justify-center mx-auto mb-8 relative w-32 h-32">
                    <div class="absolute inset-0 bg-purple-500/20 rounded-full animate-ping"></div>
                    <div class="absolute inset-4 border-2 border-purple-500/50 rounded-full"></div>
                    <div class="absolute inset-0 border-t-2 border-purple-500 rounded-full animate-spin"></div>
                    <div class="absolute inset-1/2 w-1 h-32 bg-linear-to-b from-purple-500/50 to-transparent -translate-x-1/2 -translate-y-1/2 origin-bottom animate-spin"></div>
                    <!-- Target icon center -->
                    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-purple-400">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                    </div>
                </div>

                <h3 class="text-2xl font-bold text-slate-900 dark:text-white mb-2">Pulsando servidores web...</h3>
                <p class="text-purple-400/70">Buscando el rastro digital de <span class="text-purple-300 font-bold">@{username}</span> en tiempo real.</p>
            </div>

        {:else if scanState === 'results'}
            <div transition:fade>
                <div class="flex flex-col md:flex-row items-center justify-between mb-8 pb-8 border-b border-slate-900/10 dark:border-white/10 gap-6">
                    <div>
                        <h2 class="text-2xl font-bold text-slate-900 dark:text-white mb-1 flex items-center gap-3">
                            Resultados OSINT para @{username}
                            <span class="px-3 py-1 bg-purple-500/20 text-purple-400 text-sm rounded-lg border border-purple-500/30">Escaneo Finalizado</span>
                        </h2>
                        <p class="text-purple-400/70">
                            Revisa las coincidencias, asegúrate de que sean tus perfiles, y elimínalos para dejar de almacenar datos inútiles.
                        </p>
                    </div>
                    
                    <button onclick={() => scanState = 'idle'} class="px-4 py-2 bg-slate-900/5 dark:bg-white/5 hover:bg-slate-900/10 dark:hover:bg-white/10 border border-slate-900/10 dark:border-white/10 rounded-lg text-sm text-slate-900 dark:text-white transition-colors">
                        Nueva Búsqueda
                    </button>
                </div>

                <!-- Panel de Impacto CO₂ -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
                    <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-5 border border-slate-900/10 dark:border-white/10 flex items-center gap-4">
                        <div class="w-12 h-12 rounded-lg bg-orange-500/20 flex flex-shrink-0 items-center justify-center">
                            <svg class="w-6 h-6 text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                        </div>
                        <div>
                            <p class="text-3xl font-bold text-orange-400">{scanStats.totalAccounts}</p>
                            <p class="text-sm text-purple-400/70">Cuentas que usan este alias</p>
                        </div>
                    </div>

                    <div class="bg-purple-500/5 rounded-xl p-5 border border-purple-500/20 flex items-center gap-4 relative overflow-hidden">
                        <div class="w-12 h-12 rounded-lg bg-emerald-700/20 dark:bg-emerald-500/20 flex flex-shrink-0 items-center justify-center relative z-10">
                            <svg class="w-6 h-6 text-emerald-700 dark:text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        </div>
                        <div class="relative z-10">
                            <p class="text-3xl font-bold text-emerald-700 dark:text-emerald-400">{scanStats.totalCo2 >= 1000 ? (scanStats.totalCo2 / 1000).toFixed(2) + ' kg' : scanStats.totalCo2 + ' g'}</p>
                            <p class="text-sm text-purple-400/70">Ahorro anual si borras todas</p>
                        </div>
                    </div>
                </div>

                {#if results.length > 0}
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        {#each results as account}
                            <div class="bg-slate-900/5 dark:bg-white/5 border border-slate-900/10 dark:border-white/10 rounded-xl p-5 hover:bg-slate-900/10 dark:hover:bg-white/10 transition-colors group flex flex-col justify-between h-full">
                                <div>
                                    <div class="flex items-center justify-between mb-3">
                                        <div class="flex items-center gap-2">
                                            <span class="text-2xl">{getPlatformIcon(account.platform)}</span>
                                            <h4 class="text-lg font-bold text-slate-900 dark:text-white">{account.platform}</h4>
                                        </div>
                                        <span class="text-xs font-mono px-2 py-1 bg-emerald-700/10 dark:bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 border border-emerald-600/30 dark:border-emerald-500/30 rounded">
                                            -{account.estimated_co2_grams}g CO₂
                                        </span>
                                    </div>
                                    <p class="text-sm text-white/50 mb-4 truncate" title={account.profile_url}>
                                        {account.profile_url}
                                    </p>
                                </div>
                                
                                <div class="flex gap-2 mt-auto">
                                    <a href={account.profile_url} target="_blank" rel="noopener noreferrer" class="flex-1 px-3 py-2 bg-slate-900/5 dark:bg-white/5 hover:bg-slate-900/10 dark:hover:bg-white/10 border border-slate-900/10 dark:border-white/10 text-slate-900/80 dark:text-white/80 text-center text-sm font-medium rounded-lg transition-colors">
                                        Ver Perfil
                                    </a>
                                    <a href={account.delete_url} target="_blank" rel="noopener noreferrer" class="flex-1 px-3 py-2 bg-red-700/10 dark:bg-red-500/10 hover:bg-red-700/20 dark:hover:bg-red-500/20 border border-red-700/30 dark:border-red-500/30 text-red-700 dark:text-red-400 text-center text-sm font-bold rounded-lg transition-colors">
                                        Ir a Borrar
                                    </a>
                                </div>
                            </div>
                        {/each}
                    </div>
                {:else}
                    <div class="text-center py-16 bg-slate-900/5 dark:bg-white/5 rounded-2xl border border-dashed border-slate-900/20 dark:border-white/20">
                        <div class="w-16 h-16 mx-auto bg-green-500/20 rounded-full flex items-center justify-center mb-4 text-green-400 glow-effect">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                        </div>
                        <h3 class="text-xl font-bold text-slate-900 dark:text-white mb-2">¡Rastro digital limpio!</h3>
                        <p class="text-purple-400/70">No encontramos registros evidentes bajo el alias "{username}".</p>
                    </div>
                {/if}
            </div>
        {/if}
    </div>
</div>
