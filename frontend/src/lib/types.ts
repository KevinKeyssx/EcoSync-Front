export interface Scan {
  id: string
  user_id: string
  scan_date: string
  total_files: number
  total_size_gb: number
  waste_files: number
  waste_size_gb: number
  co2_saved_estimate_g: number
  source_type: string
  created_at: string
}

export interface DetectedFile {
  id: string
  scan_id: string
  file_name: string
  file_path: string
  file_size_mb: number
  file_type: string
  waste_category: string
  last_modified: string
  is_deleted: boolean
  created_at: string
}
