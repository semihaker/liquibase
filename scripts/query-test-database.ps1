# Test Veritabanı Sorgulama Script'i
# Bu script test veritabanında çeşitli sorguları çalıştırır

Write-Host "🔍 Test Veritabanı Sorgulanıyor..." -ForegroundColor Green

# Test veritabanına bağlan
Write-Host "📊 Veritabanına bağlanılıyor..." -ForegroundColor Yellow

# 1. Tüm tabloları listele
Write-Host "`n📋 Tüm Tablolar:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "\dt"

# 2. Test müşterileri
Write-Host "`n👥 Test Müşterileri:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT customer_code, first_name, last_name, email, is_active FROM test_customers LIMIT 5;"

# 3. Test siparişleri
Write-Host "`n📦 Test Siparişleri:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT order_number, customer_id, order_date, status, final_amount FROM test_orders LIMIT 5;"

# 4. Test adresleri
Write-Host "`n🏠 Test Adresleri:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT customer_id, address_type, city, country FROM test_addresses LIMIT 5;"

# 5. Müşteri özeti (view)
Write-Host "`n📊 Müşteri Özeti (View):" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT customer_code, full_name, total_orders, total_spent FROM test_customer_summary LIMIT 5;"

# 6. Sipariş özeti (view)
Write-Host "`n📋 Sipariş Özeti (View):" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT order_number, customer_name, status, final_amount, item_count FROM test_order_summary LIMIT 5;"

# 7. Fonksiyon testi
Write-Host "`n🧮 Fonksiyon Testi:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT test_calculate_order_total(1) as order_1_total;"

# 8. Müşteri siparişleri (fonksiyon)
Write-Host "`n📋 Müşteri 1'in Siparişleri:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "SELECT * FROM test_get_customer_orders(1);"

# 9. İstatistikler
Write-Host "`n📈 Veritabanı İstatistikleri:" -ForegroundColor Cyan
docker exec -it postgres-testdb psql -U admin -d testdb -c "
SELECT 
    'Müşteriler' as table_name, COUNT(*) as record_count FROM test_customers
UNION ALL
SELECT 
    'Siparişler' as table_name, COUNT(*) as record_count FROM test_orders
UNION ALL
SELECT 
    'Sipariş Kalemleri' as table_name, COUNT(*) as record_count FROM test_order_items
UNION ALL
SELECT 
    'Adresler' as table_name, COUNT(*) as record_count FROM test_addresses;"

Write-Host "`n✅ Test veritabanı sorgulaması tamamlandı!" -ForegroundColor Green
Write-Host "💡 Manuel sorgu için: docker exec -it postgres-testdb psql -U admin -d testdb" -ForegroundColor Cyan
