<script lang="ts">
  import { onMount } from 'svelte'
  import type { DetectedFile, Scan } from './types'

  interface Props {
    scanId: string;
  }
  let { scanId }: Props = $props();

  let files: DetectedFile[] = $state([]);
  let scan: Scan | null = $state(null);
  let loading = $state(true);
  let selectedCategory = $state('all');
  let searchQuery = $state('');

  const categoryColors: Record<string, string> = {
    duplicates: 'bg-yellow-700/20 dark:bg-yellow-500/20 text-yellow-700 dark:text-yellow-400 border-yellow-400/30',
    temp_files: 'bg-blue-700/20 dark:bg-blue-500/20 text-blue-700 dark:text-blue-400 border-blue-400/30',
    old_installers: 'bg-red-700/20 dark:bg-red-500/20 text-red-700 dark:text-red-400 border-red-400/30',
    node_modules: 'bg-purple-500/20 text-purple-400 border-purple-400/30',
    cache: 'bg-orange-500/20 text-orange-400 border-orange-400/30',
    logs: 'bg-pink-500/20 text-pink-400 border-pink-400/30',
  }

  const categoryIcons: Record<string, string> = {
    duplicates: 'M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z',
    temp_files: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
    old_installers: 'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4',
    node_modules: 'M4 7v10c0 2 1 3 3 3h10c2 0 3-1 3-3V7c0-2-1-3-3-3H7C5 4 4 5 4 7z',
    cache: 'M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4',
    logs: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
  }

  onMount(async () => {
    await loadData()
  })

  async function loadData() {
    loading = true
    try {
      // Simula el tiempo de carga/fetch local
      await new Promise(resolve => setTimeout(resolve, 500))

      scan = {
        id: scanId,
        user_id: 'local-user',
        scan_date: new Date().toISOString(),
        total_files: 300,
        total_size_gb: 1.5,
        waste_files: 50,
        waste_size_gb: 0.8,
        co2_saved_estimate_g: 100,
        source_type: 'local',
        created_at: new Date().toISOString()
      }
      
      files = [] // Simula que no hay archivos detectados todavía
    } catch (err) {
      console.error('Error loading data:', err)
    } finally {
      loading = false
    }
  }

  let filteredFiles = $derived(
    files.filter(file => {
      const matchesCategory = selectedCategory === 'all' || file.waste_category === selectedCategory
      const matchesSearch = file.file_name.toLowerCase().includes(searchQuery.toLowerCase())
      return matchesCategory && matchesSearch && !file.is_deleted
    })
  );

  let categories = $derived([...new Set(files.map(f => f.waste_category))]);

  async function deleteFile(fileId: string) {
    try {
      // Simula el borrado y la actualización en local del frontend
      files = files.map(f => f.id === fileId ? { ...f, is_deleted: true } : f)
    } catch (err) {
      console.error('Error deleting file:', err)
    }
  }

  function formatFileSize(sizeMB: number): string {
    if (sizeMB < 1) {
      return `${(sizeMB * 1024).toFixed(1)} KB`
    } else if (sizeMB > 1024) {
      return `${(sizeMB / 1024).toFixed(2)} GB`
    }
    return `${sizeMB.toFixed(1)} MB`
  }

  function formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }
</script>

<div class="space-y-6">
  {#if scan}
    <div class="glass-effect rounded-2xl p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-2xl font-bold text-emerald-700 dark:text-emerald-400">Scan Results</h2>
        <span class="text-sm text-emerald-700/70 dark:text-emerald-400/70">{formatDate(scan.scan_date)}</span>
      </div>

      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-4">
          <p class="text-sm text-emerald-700/70 dark:text-emerald-400/70 mb-1">Total Files</p>
          <p class="text-2xl font-bold text-slate-900 dark:text-white">{scan.total_files}</p>
        </div>
        <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-4">
          <p class="text-sm text-emerald-700/70 dark:text-emerald-400/70 mb-1">Waste Files</p>
          <p class="text-2xl font-bold text-yellow-700 dark:text-yellow-400">{scan.waste_files}</p>
        </div>
        <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-4">
          <p class="text-sm text-emerald-700/70 dark:text-emerald-400/70 mb-1">Space Wasted</p>
          <p class="text-2xl font-bold text-red-700 dark:text-red-400">{Number(scan.waste_size_gb).toFixed(2)} GB</p>
        </div>
        <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-4">
          <p class="text-sm text-emerald-700/70 dark:text-emerald-400/70 mb-1">CO₂ Impact</p>
          <p class="text-2xl font-bold text-emerald-700 dark:text-emerald-400">{Number(scan.co2_saved_estimate_g).toFixed(0)}g</p>
        </div>
      </div>
    </div>
  {/if}

  <div class="glass-effect rounded-2xl p-6">
    <div class="flex flex-col md:flex-row gap-4 mb-6">
      <div class="flex-1">
        <input
          type="text"
          bind:value={searchQuery}
          placeholder="Search files..."
          class="w-full px-4 py-3 bg-slate-900/5 dark:bg-white/5 border border-slate-900/10 dark:border-white/10 rounded-xl text-slate-900 dark:text-white placeholder-emerald-400/50 focus:outline-none focus:ring-2 focus:ring-emerald-500"
        />
      </div>

      <select
        bind:value={selectedCategory}
        class="px-4 py-3 bg-slate-900/5 dark:bg-white/5 border border-slate-900/10 dark:border-white/10 rounded-xl text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
      >
        <option value="all">All Categories</option>
        {#each categories as category}
          <option value={category}>{category.replace('_', ' ').toUpperCase()}</option>
        {/each}
      </select>
    </div>

    {#if loading}
      <div class="flex items-center justify-center py-12">
        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-emerald-400"></div>
      </div>
    {:else if filteredFiles.length === 0}
      <div class="text-center py-12">
        <svg class="w-16 h-16 mx-auto mb-4 text-emerald-400/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
        </svg>
        <p class="text-emerald-700/70 dark:text-emerald-400/70">No files found matching your criteria</p>
      </div>
    {:else}
      <div class="space-y-2 max-h-[600px] overflow-y-auto pr-2">
        {#each filteredFiles as file}
          <div class="bg-slate-900/5 dark:bg-white/5 rounded-xl p-4 border border-slate-900/10 dark:border-white/10 hover:bg-slate-900/10 dark:hover:bg-white/10 transition-all duration-300 group">
            <div class="flex items-start justify-between gap-4">
              <div class="flex items-start gap-3 flex-1 min-w-0">
                <div class="w-10 h-10 rounded-lg {categoryColors[file.waste_category] || 'bg-gray-500/20 text-gray-400 border-gray-400/30'} border flex items-center justify-center flex-shrink-0">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={categoryIcons[file.waste_category] || 'M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z'}></path>
                  </svg>
                </div>

                <div class="flex-1 min-w-0">
                  <h3 class="text-slate-900 dark:text-white font-medium truncate">{file.file_name}</h3>
                  <p class="text-sm text-emerald-700/70 dark:text-emerald-400/70 truncate">{file.file_path}</p>
                  <div class="flex items-center gap-3 mt-1">
                    <span class="text-xs px-2 py-1 rounded {categoryColors[file.waste_category] || 'bg-gray-500/20 text-gray-400'} border">
                      {file.waste_category.replace('_', ' ')}
                    </span>
                    <span class="text-xs text-emerald-700/70 dark:text-emerald-400/70">
                      Modified: {formatDate(file.last_modified)}
                    </span>
                  </div>
                </div>
              </div>

              <div class="flex items-center gap-3 flex-shrink-0">
                <div class="text-right">
                  <p class="text-slate-900 dark:text-white font-semibold">{formatFileSize(Number(file.file_size_mb))}</p>
                  <p class="text-xs text-emerald-700/70 dark:text-emerald-400/70">{Number(file.file_size_mb * 0.5 * 0.475).toFixed(1)}g CO₂/year</p>
                </div>

                <button
                  onclick={() => deleteFile(file.id)}
                  class="p-2 rounded-lg bg-red-700/20 dark:bg-red-500/20 text-red-700 dark:text-red-400 hover:bg-red-500/30 transition-all duration-300 opacity-0 group-hover:opacity-100"
                  title="Mark as deleted"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                  </svg>
                </button>
              </div>
            </div>
          </div>
        {/each}
      </div>

      <div class="mt-4 pt-4 border-t border-slate-900/10 dark:border-white/10">
        <div class="flex items-center justify-between text-sm">
          <span class="text-emerald-700/70 dark:text-emerald-400/70">
            Showing {filteredFiles.length} of {files.filter(f => !f.is_deleted).length} files
          </span>
          <span class="text-emerald-700 dark:text-emerald-400 font-semibold">
            Total: {formatFileSize(filteredFiles.reduce((sum, f) => sum + Number(f.file_size_mb), 0))}
          </span>
        </div>
      </div>
    {/if}
  </div>
</div>
