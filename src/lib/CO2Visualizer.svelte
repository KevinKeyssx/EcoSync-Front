<script lang="ts">
  interface Props {
    co2SavedGrams: number;
  }

  let { co2SavedGrams }: Props = $props();

  let equivalencies = $derived([
    {
      name: 'Smartphone charges',
      value: co2SavedGrams / 8.22,
      icon: 'M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z'
    },
    {
      name: 'Trees planted',
      value: co2SavedGrams / 21772,
      icon: 'M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4'
    },
    {
      name: 'Miles driven',
      value: co2SavedGrams / 404,
      icon: 'M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z'
    }
  ]);
</script>

<div class="glass-effect rounded-2xl p-6 overflow-hidden relative">
  <div class="absolute top-0 right-0 w-64 h-64 bg-emerald-700/10 dark:bg-emerald-500/10 rounded-full blur-3xl"></div>

  <h2 class="text-2xl font-bold text-emerald-700 dark:text-emerald-400 mb-6 relative z-10">
    Environmental Impact
  </h2>

  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 relative z-10">
    {#each equivalencies as eq}
      <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-4 border border-emerald-400/20 hover:border-emerald-400/40 transition-all duration-300">
        <div class="flex items-center gap-3 mb-3">
          <div class="w-10 h-10 rounded-lg bg-emerald-700/20 dark:bg-emerald-500/20 flex items-center justify-center">
            <svg class="w-5 h-5 text-emerald-700 dark:text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={eq.icon}></path>
            </svg>
          </div>
          <h3 class="text-sm text-emerald-700/70 dark:text-emerald-400/70">{eq.name}</h3>
        </div>
        <p class="text-3xl font-bold text-slate-900 dark:text-white">
          {eq.value.toFixed(eq.value < 1 ? 3 : 1)}
        </p>
      </div>
    {/each}
  </div>

  <div class="mt-6 relative z-10">
    <div class="flex items-center justify-between text-sm mb-2">
      <span class="text-emerald-700/70 dark:text-emerald-400/70">Carbon Footprint Reduction</span>
      <span class="text-emerald-700 dark:text-emerald-400 font-semibold">{(co2SavedGrams / 1000).toFixed(3)} kg CO₂</span>
    </div>
    <div class="h-3 bg-slate-900/5 dark:bg-white/5 rounded-full overflow-hidden">
      <div
        class="h-full bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full transition-all duration-1000 ease-out"
        style="width: {Math.min((co2SavedGrams / 10000) * 100, 100)}%"
      ></div>
    </div>
  </div>
</div>
