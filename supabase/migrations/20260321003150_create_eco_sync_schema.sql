/*
  # Eco-Sync Database Schema
  
  ## Overview
  This migration creates the database schema for the Eco-Sync application,
  which helps users optimize their digital footprint by identifying and
  removing unnecessary files.
  
  ## New Tables
  
  ### `scans`
  Stores information about each scan performed by the user
  - `id` (uuid, primary key) - Unique identifier for the scan
  - `user_id` (uuid) - Reference to the user who performed the scan
  - `scan_date` (timestamptz) - When the scan was performed
  - `total_files` (integer) - Total number of files scanned
  - `total_size_gb` (decimal) - Total size of scanned files in GB
  - `waste_files` (integer) - Number of waste files detected
  - `waste_size_gb` (decimal) - Total size of waste files in GB
  - `co2_saved_estimate_g` (decimal) - Estimated CO2 savings in grams
  - `source_type` (text) - Type of source scanned (drive, dropbox, local)
  - `created_at` (timestamptz) - Record creation timestamp
  
  ### `detected_files`
  Stores information about individual files detected as waste
  - `id` (uuid, primary key) - Unique identifier for the file
  - `scan_id` (uuid, foreign key) - Reference to the scan
  - `file_name` (text) - Name of the file
  - `file_path` (text) - Full path of the file
  - `file_size_mb` (decimal) - Size of the file in MB
  - `file_type` (text) - Type/category of the file
  - `waste_category` (text) - Category of waste (duplicate, temp, old, etc)
  - `last_modified` (timestamptz) - Last modification date of the file
  - `is_deleted` (boolean) - Whether the file has been deleted
  - `created_at` (timestamptz) - Record creation timestamp
  
  ## Security
  - Enable RLS on all tables
  - Add policies for authenticated users to manage their own data
*/

CREATE TABLE IF NOT EXISTS scans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  scan_date timestamptz DEFAULT now(),
  total_files integer DEFAULT 0,
  total_size_gb decimal(10, 3) DEFAULT 0,
  waste_files integer DEFAULT 0,
  waste_size_gb decimal(10, 3) DEFAULT 0,
  co2_saved_estimate_g decimal(10, 2) DEFAULT 0,
  source_type text DEFAULT 'local',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS detected_files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id uuid NOT NULL REFERENCES scans(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_path text NOT NULL,
  file_size_mb decimal(10, 3) DEFAULT 0,
  file_type text DEFAULT 'unknown',
  waste_category text NOT NULL,
  last_modified timestamptz,
  is_deleted boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_scans_user_id ON scans(user_id);
CREATE INDEX IF NOT EXISTS idx_detected_files_scan_id ON detected_files(scan_id);

ALTER TABLE scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE detected_files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own scans"
  ON scans FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own scans"
  ON scans FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own scans"
  ON scans FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own scans"
  ON scans FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view files from own scans"
  ON detected_files FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM scans
      WHERE scans.id = detected_files.scan_id
      AND scans.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert files to own scans"
  ON detected_files FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM scans
      WHERE scans.id = detected_files.scan_id
      AND scans.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update files from own scans"
  ON detected_files FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM scans
      WHERE scans.id = detected_files.scan_id
      AND scans.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM scans
      WHERE scans.id = detected_files.scan_id
      AND scans.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete files from own scans"
  ON detected_files FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM scans
      WHERE scans.id = detected_files.scan_id
      AND scans.user_id = auth.uid()
    )
  );
