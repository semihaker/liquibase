# Test Veritabanı Temizleme Script'i
# Bu script test veritabanı migration'larını geri alır

Write-Host "🧹 Test Veritabanı Temizleniyor..." -ForegroundColor Yellow

# .env dosyasını yükle
. "$PSScriptRoot\load-env.ps1"

# Test veritabanı migration'larını geri al
Write-Host "🔄 Test veritabanı migration'ları geri alınıyor..." -ForegroundColor Yellow

# Son 13 changeset'i geri al (test-database.sql'deki tüm changeset'ler)
docker-compose run --rm liquibase rollback --changesetId=admin:113:create-test-triggers
docker-compose run --rm liquibase rollback --changesetId=admin:112:insert-test-order-items
docker-compose run --rm liquibase rollback --changesetId=admin:111:insert-test-orders
docker-compose run --rm liquibase rollback --changesetId=admin:110:insert-test-addresses
docker-compose run --rm liquibase rollback --changesetId=admin:109:insert-test-customers
docker-compose run --rm liquibase rollback --changesetId=admin:108:create-test-functions
docker-compose run --rm liquibase rollback --changesetId=admin:107:create-test-views
docker-compose run --rm liquibase rollback --changesetId=admin:106:add-test-constraints
docker-compose run --rm liquibase rollback --changesetId=admin:105:add-test-indexes
docker-compose run --rm liquibase rollback --changesetId=admin:104:create-test-addresses-table
docker-compose run --rm liquibase rollback --changesetId=admin:103:create-test-order-items-table
docker-compose run --rm liquibase rollback --changesetId=admin:102:create-test-orders-table
docker-compose run --rm liquibase rollback --changesetId=admin:101:create-test-customers-table

# Migration durumunu kontrol et
Write-Host "📋 Migration durumu kontrol ediliyor..." -ForegroundColor Yellow
docker-compose run --rm liquibase status

# Tabloları listele (test tabloları silinmiş olmalı)
Write-Host "🔍 Veritabanı tabloları listeleniyor..." -ForegroundColor Yellow
docker exec -it postgres-testdb psql -U $env:POSTGRES_USER -d $env:POSTGRES_DB -c "\dt"

Write-Host "✅ Test veritabanı başarıyla temizlendi!" -ForegroundColor Green
Write-Host "💡 Test veritabanını yeniden oluşturmak için: .\scripts\test-database.ps1" -ForegroundColor Cyan
