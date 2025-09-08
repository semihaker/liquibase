param(
    [switch]$Recreate
)

Write-Host "[MySQL] Docker Compose ile servisleri baslatiliyor..." -ForegroundColor Cyan

if ($Recreate) {
    docker compose -f ../docker-compose.mysql.yml down -v
}

docker compose -f ../docker-compose.mysql.yml up -d mysql

Write-Host "[MySQL] Hazirlik bekleniyor..." -ForegroundColor Yellow
docker compose -f ../docker-compose.mysql.yml exec -T mysql mysqladmin ping -h localhost -uadmin -padmin --silent | Out-Null

Write-Host "[Liquibase] validate" -ForegroundColor Green
docker compose -f ../docker-compose.mysql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mysql.properties validate

Write-Host "[Liquibase] update" -ForegroundColor Green
docker compose -f ../docker-compose.mysql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mysql.properties update

Write-Host "[Liquibase] status" -ForegroundColor Green
docker compose -f ../docker-compose.mysql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mysql.properties status

Write-Host "[SmokeTest] Tablolar dogrulaniyor..." -ForegroundColor Green
docker compose -f ../docker-compose.mysql.yml exec -T mysql sh -lc "mysql -uadmin -padmin -D testdb -e \"SHOW TABLES; SELECT COUNT(*) AS user_count FROM users; SELECT COUNT(*) AS product_count FROM products;\""

Write-Host "[Done]" -ForegroundColor Cyan

