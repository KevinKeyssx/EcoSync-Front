<script lang="ts">
  interface Props {
    title: string;
    value: string;
    icon: 'leaf' | 'trash' | 'scan';
    color?: 'emerald' | 'blue' | 'teal';
    loading?: boolean;
  }

  let { 
    title, 
    value, 
    icon, 
    color = 'emerald', 
    loading = false 
  }: Props = $props();

  const icons: Record<'leaf' | 'trash' | 'scan', string> = {
    leaf: 'M5 3v7a5 5 0 0010 0V3M3 19h18',
    trash: 'M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16',
    scan: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'
  };

  const colorClasses: Record<'emerald' | 'blue' | 'teal', string> = {
    emerald: 'from-emerald-400 to-teal-600',
    blue: 'from-blue-400 to-cyan-600',
    teal: 'from-teal-400 to-emerald-600'
  };
</script>

<div class="glass-effect rounded-2xl p-6 hover:scale-105 transition-all duration-300">
  <div class="flex items-center justify-between mb-4">
    <div class="w-12 h-12 rounded-xl bg-gradient-to-br {colorClasses[color]} flex items-center justify-center animate-float">
      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={icons[icon]}></path>
      </svg>
    </div>
  </div>

  <h3 class="text-sm text-emerald-400/70 mb-2">{title}</h3>

  {#if loading}
    <div class="h-8 w-24 bg-white/10 rounded animate-pulse"></div>
  {:else}
    <p class="text-3xl font-bold text-white">{value}</p>
  {/if}
</div>
