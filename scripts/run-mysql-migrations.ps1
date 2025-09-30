param(
    [switch]$Recreate
)

# .env dosyasını yükle
. "$PSScriptRoot\load-env.ps1"

# Compose dosyasi yolunu script konumuna gore sabitle
$ScriptRoot = $PSScriptRoot
$RepoRoot = Split-Path -Parent $ScriptRoot
$ComposeFile = Join-Path $RepoRoot 'docker-compose.mysql.yml'

Write-Host "[MySQL] Docker Compose ile servisleri baslatiliyor..." -ForegroundColor Cyan

if ($Recreate) {
    docker compose -f "$ComposeFile" down -v
}

docker compose -f "$ComposeFile" up -d mysql

Write-Host "[MySQL] Hazirlik bekleniyor..." -ForegroundColor Yellow
docker compose -f "$ComposeFile" exec -T mysql mysqladmin ping -h localhost -u$env:MYSQL_USER -p$env:MYSQL_PASSWORD --silent | Out-Null

Write-Host "[Liquibase] validate" -ForegroundColor Green
docker compose -f "$ComposeFile" run --rm liquibase --defaultsFile=/liquibase/liquibase-mysql.properties validate

Write-Host "[Liquibase] update" -ForegroundColor Green
docker compose -f "$ComposeFile" run --rm liquibase --defaultsFile=/liquibase/liquibase-mysql.properties update

Write-Host "[Liquibase] status" -ForegroundColor Green
docker compose -f "$ComposeFile" run --rm liquibase --defaultsFile=/liquibase/liquibase-mysql.properties status

Write-Host "[SmokeTest] Tablolar dogrulaniyor..." -ForegroundColor Green
# PowerShell alintilama sorunlarini onlemek icin tek tirnakli here-string kullan
$sql = @'
SHOW TABLES;
SELECT COUNT(*) AS user_count FROM users;
SELECT COUNT(*) AS product_count FROM products;
'@
docker compose -f "$ComposeFile" exec -T mysql sh -lc "mysql -u$env:MYSQL_USER -p$env:MYSQL_PASSWORD -D $env:MYSQL_DB -e \"$($sql -replace '"','\\"' -replace "`r?`n", ' ')\""

Write-Host "[Done]" -ForegroundColor Cyan

