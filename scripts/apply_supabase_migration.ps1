<#
PowerShell helper to backup DB, apply a single migration SQL file, and verify results.
Usage:
  1. Open PowerShell in the repo root.
  2. Set your connection string (example shown below) OR pass as env var DB_CONN.
     $env:DB_CONN = 'postgresql://postgres:password@db.<ref>.supabase.co:5432/postgres'
  3. Run: .\scripts\apply_supabase_migration.ps1

This script WILL modify the target database. Run on staging/dev first. It uses `pg_dump`, `psql`, and `pg_restore` in rollback steps.
#>

param(
    [string]$MigrationFile = "backend/supabase/migrations/20260421021000_agency_and_bid_collab.sql",
    [string]$BackupDir = "backend/supabase/backups"
)

if (-not $env:DB_CONN) {
    Write-Host "ERROR: environment variable DB_CONN is not set. Set it and re-run. Example:" -ForegroundColor Red
    Write-Host "  $env:DB_CONN = 'postgresql://postgres:PASSWORD@HOST:5432/postgres'"
    exit 1
}

$timestamp = Get-Date -Format yyyyMMddHHmmss
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$dumpFile = Join-Path $BackupDir "pre_agency_migration_$timestamp.dump"

Write-Host "Creating backup to $dumpFile..."
$pgDumpCmd = "pg_dump `"$env:DB_CONN`" -Fc -f `"$dumpFile`""
Write-Host $pgDumpCmd
$pgDumpResult = cmd /c $pgDumpCmd
if ($LASTEXITCODE -ne 0) {
    Write-Host "pg_dump failed. Aborting." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "Backup created."

# Confirm file exists
if (-not (Test-Path $MigrationFile)) {
    Write-Host "Migration file not found at path: $MigrationFile" -ForegroundColor Red
    exit 1
}

Write-Host "About to apply migration: $MigrationFile" -ForegroundColor Yellow
$confirm = Read-Host "Type YES to continue"
if ($confirm -ne 'YES') { Write-Host 'Aborted by user.'; exit 0 }

Write-Host "Applying migration..."
$psqlCmd = "psql `"$env:DB_CONN`" -v ON_ERROR_STOP=1 -f `"$MigrationFile`""
Write-Host $psqlCmd
$psqlResult = cmd /c $psqlCmd
if ($LASTEXITCODE -ne 0) {
    Write-Host "psql failed. Migration may be partial. Consider restoring from backup." -ForegroundColor Red
    Write-Host "To restore, run: pg_restore --clean --if-exists -d <CONN> $dumpFile" -ForegroundColor Yellow
    exit $LASTEXITCODE
}

Write-Host "Migration applied successfully." -ForegroundColor Green

Write-Host "Running verification queries..."
$queries = @(
    "SELECT to_regclass('public.agency_profiles') AS agency_profiles_exists;",
    "SELECT to_regclass('public.agency_creators') AS agency_creators_exists;",
    "SELECT to_regclass('public.agency_pitches') AS agency_pitches_exists;",
    "SELECT column_name FROM information_schema.columns WHERE table_name='bids' AND column_name IN ('bidder_type','agency_id');",
    "SELECT column_name FROM information_schema.columns WHERE table_name='collabs' AND column_name='agency_id';",
    "SELECT table_name, 'view' as kind FROM information_schema.views WHERE table_name='creator_discovery_view';",
    "SELECT count(*) FROM agency_profiles;",
    "SELECT count(*) FROM agency_creators;"
)

foreach ($q in $queries) {
    Write-Host "-- $q --"
    $cmd = "psql `"$env:DB_CONN`" -c `"$q`""
    cmd /c $cmd
}

Write-Host "Done. If anything looks wrong, restore the backup with:" -ForegroundColor Yellow
Write-Host "pg_restore --clean --if-exists -d <CONN> $dumpFile"

Write-Host "Reminder: Update RLS/policies and verify application behavior on staging." -ForegroundColor Cyan
