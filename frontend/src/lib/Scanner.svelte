<script lang="ts">
  import { createEventDispatcher } from 'svelte'

  const dispatch = createEventDispatcher()

  let scanning = false
  let progress = 0
  let currentFile = ''
  let sourceType = 'local'
  let scanResults = {
    totalFiles: 0,
    totalSizeGB: 0,
    wasteFiles: 0,
    wasteSizeGB: 0,
    co2Estimate: 0
  }

  const wasteCategories = [
    'duplicates',
    'temp_files',
    'old_installers',
    'node_modules',
    'cache',
    'logs'
  ]

  async function startScan() {
    scanning = true
    progress = 0
    scanResults = {
      totalFiles: 0,
      totalSizeGB: 0,
      wasteFiles: 0,
      wasteSizeGB: 0,
      co2Estimate: 0
    }

    let mockFiles: any[] = []

    if (sourceType === 'github') {
      try {
        currentFile = "Conectando a GitHub API..."
        const res = await fetch('http://localhost:8000/repos', {credentials: 'include'})
        if (res.status === 401) {
            alert("No autenticado. Inicia sesión en http://localhost:8000 primero.")
            scanning = false;
            return;
        }
        if (!res.ok) throw new Error("Error en la petición de GitHub")
        const data = await res.json()
        const repos = data.repos || []

        for (let i = 0; i < repos.length; i++) {
          const repo = repos[i]
          currentFile = `Analizando repositorio: ${repo.name}`
          progress = ((i + 1) / repos.length) * 100

          scanResults.totalFiles++
          const isWaste = repo.days_inactive > 180
          // "Peso virtual" en MB basado en la popularidad y tamaño teórico (para impacto CO2)
          const fakeMB = Math.max(15, Math.random() * 80 + ((repo.stars || 0) * 5))

          scanResults.totalSizeGB += fakeMB / 1024
          if (isWaste) {
            scanResults.wasteFiles++
            scanResults.wasteSizeGB += fakeMB / 1024
          }

          mockFiles.push({
            name: repo.name,
            path: repo.url,
            sizeMB: fakeMB,
            isWaste: isWaste,
            category: 'inactive_repo',
            lastModified: repo.last_commit_date || new Date().toISOString()
          })

          await new Promise(resolve => setTimeout(resolve, 20))
        }

      } catch(e) {
        console.error(e)
        alert('Error: ' + e)
        scanning = false
        return
      }
    } else {
      mockFiles = generateMockFiles(150)
      for (let i = 0; i < mockFiles.length; i++) {
        currentFile = mockFiles[i].name
        progress = ((i + 1) / mockFiles.length) * 100
  
        scanResults.totalFiles++
        scanResults.totalSizeGB += mockFiles[i].sizeMB / 1024
  
        if (mockFiles[i].isWaste) {
          scanResults.wasteFiles++
          scanResults.wasteSizeGB += mockFiles[i].sizeMB / 1024
        }
  
        await new Promise(resolve => setTimeout(resolve, 30))
      }
    }

    scanResults.co2Estimate = calculateCO2(scanResults.wasteSizeGB)
    await saveScanResults(mockFiles)

    scanning = false
  }

  function generateMockFiles(count: number) {
    const fileTypes = [
      { ext: 'tmp', isWaste: true, category: 'temp_files' },
      { ext: 'log', isWaste: true, category: 'logs' },
      { ext: 'cache', isWaste: true, category: 'cache' },
      { ext: 'exe', isWaste: true, category: 'old_installers' },
      { ext: 'dmg', isWaste: true, category: 'old_installers' },
      { ext: 'jpg', isWaste: false, category: 'media' },
      { ext: 'pdf', isWaste: false, category: 'documents' },
      { ext: 'mp4', isWaste: false, category: 'media' },
    ]

    const files = []
    for (let i = 0; i < count; i++) {
      const type = fileTypes[Math.floor(Math.random() * fileTypes.length)]
      const isDuplicate = Math.random() > 0.7
      const isOld = Math.random() > 0.6

      files.push({
        name: `file_${i}.${type.ext}`,
        path: `/path/to/file_${i}.${type.ext}`,
        sizeMB: Math.random() * 500 + 1,
        isWaste: type.isWaste || isDuplicate,
        category: isDuplicate ? 'duplicates' : type.category,
        lastModified: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000).toISOString()
      })
    }

    return files
  }

  function calculateCO2(sizeGB: number) {
    return sizeGB * 0.5 * 365 * 0.475
  }

  async function saveScanResults(files: any[]) {
    try {
      const mockScanId = "scan-" + Date.now();
      const scanData = {
          id: mockScanId,
          user_id: "user-local",
          scan_date: new Date().toISOString(),
          total_files: scanResults.totalFiles,
          total_size_gb: scanResults.totalSizeGB,
          waste_files: scanResults.wasteFiles,
          waste_size_gb: scanResults.wasteSizeGB,
          co2_saved_estimate_g: scanResults.co2Estimate,
          source_type: sourceType,
          created_at: new Date().toISOString()
      };
      
      const history = JSON.parse(localStorage.getItem('ecoSyncScans') || '[]');
      history.unshift(scanData);
      localStorage.setItem('ecoSyncScans', JSON.stringify(history));

      dispatch('scanComplete', { scanId: mockScanId })
    } catch (err) {
      console.error('Error saving scan:', err)
    }
  }
</script>

<div class="glass-effect rounded-2xl p-8">
  <h2 class="text-3xl font-bold text-emerald-400 mb-6">Start a New Scan</h2>

  {#if !scanning}
    <div class="space-y-6">
      <div>
        <label class="block text-sm font-medium text-emerald-400/70 mb-2">
          Select Source Type
        </label>
        <select
          bind:value={sourceType}
          class="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
        >
          <option value="local">Local Storage</option>
          <option value="drive">Google Drive</option>
          <option value="dropbox">Dropbox</option>
          <option value="onedrive">OneDrive</option>
          <option value="github">GitHub Repositories</option>
        </select>
      </div>

      <div class="bg-emerald-500/10 border border-emerald-400/30 rounded-xl p-4">
        <div class="flex items-start gap-3">
          <svg class="w-5 h-5 text-emerald-400 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <div class="text-sm text-emerald-400/90">
            <p class="font-semibold mb-1">What we'll scan:</p>
            <ul class="space-y-1 list-disc list-inside">
              <li>Duplicate files</li>
              <li>Temporary files and cache</li>
              <li>Old installer packages</li>
              <li>Forgotten node_modules folders</li>
              <li>Outdated log files</li>
            </ul>
          </div>
        </div>
      </div>

      <button
        on:click={startScan}
        class="w-full py-4 bg-gradient-to-r from-emerald-500 to-teal-600 text-white text-lg font-semibold rounded-xl hover:shadow-xl hover:scale-105 transition-all duration-300 glow-effect"
      >
        Start Scanning
      </button>
    </div>
  {:else}
    <div class="space-y-6">
      <div class="text-center">
        <div class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-emerald-500/20 mb-4 animate-pulse-slow">
          <svg class="w-10 h-10 text-emerald-400 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
        <h3 class="text-2xl font-bold text-white mb-2">Scanning Files...</h3>
        <p class="text-emerald-400/70 text-sm truncate max-w-md mx-auto">{currentFile}</p>
      </div>

      <div>
        <div class="flex items-center justify-between text-sm mb-2">
          <span class="text-emerald-400/70">Progress</span>
          <span class="text-emerald-400 font-semibold">{progress.toFixed(0)}%</span>
        </div>
        <div class="h-4 bg-white/5 rounded-full overflow-hidden">
          <div
            class="h-full bg-gradient-to-r from-emerald-400 via-teal-500 to-emerald-400 rounded-full transition-all duration-300 relative overflow-hidden"
            style="width: {progress}%"
          >
            <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent animate-pulse"></div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-4 mt-8">
        <div class="bg-white/5 rounded-xl p-4 border border-white/10">
          <p class="text-sm text-emerald-400/70 mb-1">Files Scanned</p>
          <p class="text-2xl font-bold text-white">{scanResults.totalFiles}</p>
        </div>
        <div class="bg-white/5 rounded-xl p-4 border border-white/10">
          <p class="text-sm text-emerald-400/70 mb-1">Waste Found</p>
          <p class="text-2xl font-bold text-emerald-400">{scanResults.wasteFiles}</p>
        </div>
      </div>
    </div>
  {/if}
</div>
