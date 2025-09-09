param(
    [switch]$Recreate
)

# Compose dosyasi yolunu script konumuna gore sabitle
$ScriptRoot = $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptRoot
$ComposeFile = Join-Path $RepoRoot 'docker-compose.mssql.yml'

Write-Host "[MSSQL] Docker Compose ile servisleri baslatiliyor..." -ForegroundColor Cyan

if ($Recreate) {
    docker compose -f "$ComposeFile" down -v
}

docker compose -f "$ComposeFile" up -d mssql

Write-Host "[MSSQL] Hazirlik bekleniyor..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "Deneme $attempt/$maxAttempts..." -ForegroundColor Cyan
    
    try {
        $result = docker compose -f "$ComposeFile" exec -T mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "Your_strong_password123" -Q "SELECT 1" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ MSSQL hazır!" -ForegroundColor Green
            break
        }
    }
    catch {
        # Hata durumunda devam et
    }
    
    Start-Sleep -Seconds 2
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ MSSQL başlatılamadı!" -ForegroundColor Red
    exit 1
}

Write-Host "[Liquibase] validate" -ForegroundColor Green
docker run --rm --network liquibase_default `
  -v "$RepoRoot/changelog/mssql:/liquibase/changelog/mssql" `
  -v "$RepoRoot/drivers:/liquibase/lib" `
  -v "$RepoRoot/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" `
  liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties validate

Write-Host "[Liquibase] update" -ForegroundColor Green
docker run --rm --network liquibase_default `
  -v "$RepoRoot/changelog/mssql:/liquibase/changelog/mssql" `
  -v "$RepoRoot/drivers:/liquibase/lib" `
  -v "$RepoRoot/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" `
  liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties update

Write-Host "[Liquibase] status" -ForegroundColor Green
docker run --rm --network liquibase_default `
  -v "$RepoRoot/changelog/mssql:/liquibase/changelog/mssql" `
  -v "$RepoRoot/drivers:/liquibase/lib" `
  -v "$RepoRoot/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" `
  liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties status

Write-Host "[SmokeTest] Tablolar dogrulaniyor..." -ForegroundColor Green
docker compose -f "$ComposeFile" exec -T mssql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "Your_strong_password123" -d testdb -Q "SELECT name FROM sys.tables; SELECT COUNT(*) AS user_count FROM app.users; SELECT COUNT(*) AS product_count FROM app.products;"

Write-Host "[Done]" -ForegroundColor Cyan
