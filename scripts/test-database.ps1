# Test Veritabanı Çalıştırma Script'i
# Bu script test veritabanı migration'larını çalıştırır

Write-Host "🚀 Test Veritabanı Migration'ları Başlatılıyor..." -ForegroundColor Green

# .env dosyasını yükle
. "$PSScriptRoot\load-env.ps1"

# PostgreSQL'in hazır olduğunu kontrol et
Write-Host "📊 PostgreSQL durumu kontrol ediliyor..." -ForegroundColor Yellow
docker-compose ps postgres

# Liquibase ile test veritabanı migration'larını çalıştır
Write-Host "🔄 Test veritabanı migration'ları uygulanıyor..." -ForegroundColor Yellow
docker-compose run --rm liquibase update

# Migration durumunu kontrol et
Write-Host "📋 Migration durumu kontrol ediliyor..." -ForegroundColor Yellow
docker-compose run --rm liquibase status

# Test veritabanına bağlan ve tabloları listele
Write-Host "🔍 Test veritabanı tabloları listeleniyor..." -ForegroundColor Yellow
docker exec -it postgres-testdb psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "\dt"

# Test verilerini görüntüle
Write-Host "📊 Test verileri görüntüleniyor..." -ForegroundColor Yellow
docker exec -it postgres-testdb psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "SELECT COUNT(*) as customer_count FROM test_customers;"
docker exec -it postgres-testdb psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "SELECT COUNT(*) as order_count FROM test_orders;"
docker exec -it postgres-testdb psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "SELECT COUNT(*) as address_count FROM test_addresses;"

Write-Host "✅ Test veritabanı başarıyla oluşturuldu!" -ForegroundColor Green
Write-Host "💡 Test veritabanına bağlanmak için: docker exec -it postgres-testdb psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB" -ForegroundColor Cyan
