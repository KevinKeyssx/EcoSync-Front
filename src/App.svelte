<script lang="ts">
  import Dashboard from './lib/Dashboard.svelte'
  import Scanner from './lib/Scanner.svelte'
  import FileList from './lib/FileList.svelte'

  let currentView: 'dashboard' | 'scanner' | 'files' = 'dashboard'
  let currentScanId: string | null = null

  function handleScanComplete(event: CustomEvent<{ scanId: string }>) {
    currentScanId = event.detail.scanId
    currentView = 'files'
  }
</script>

<main class="min-h-screen p-4 md:p-8">
  <div class="max-w-7xl mx-auto">
    <header class="mb-8 animate-slide-up">
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-3">
          <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-emerald-400 to-teal-600 flex items-center justify-center glow-effect">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <div>
            <h1 class="text-3xl md:text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-teal-300">
              Eco-Sync
            </h1>
            <p class="text-sm text-emerald-400/70">Digital Footprint Optimizer</p>
          </div>
        </div>

        <nav class="flex gap-2">
          <button
            on:click={() => currentView = 'dashboard'}
            class="px-4 py-2 rounded-xl transition-all duration-300 {currentView === 'dashboard' ? 'bg-emerald-500 text-white glow-effect' : 'glass-effect text-emerald-400 hover:bg-white/10'}"
          >
            Dashboard
          </button>
          <button
            on:click={() => currentView = 'scanner'}
            class="px-4 py-2 rounded-xl transition-all duration-300 {currentView === 'scanner' ? 'bg-emerald-500 text-white glow-effect' : 'glass-effect text-emerald-400 hover:bg-white/10'}"
          >
            Scan
          </button>
        </nav>
      </div>
    </header>

    <div class="animate-slide-up" style="animation-delay: 0.1s">
      {#if currentView === 'dashboard'}
        <Dashboard on:startScan={() => currentView = 'scanner'} />
      {:else if currentView === 'scanner'}
        <Scanner on:scanComplete={handleScanComplete} />
      {:else if currentView === 'files' && currentScanId}
        <FileList scanId={currentScanId} />
      {/if}
    </div>
  </div>
</main>
