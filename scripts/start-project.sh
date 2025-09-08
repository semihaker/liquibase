#!/bin/bash

# Liquibase PostgreSQL Projesi Başlatma Script'i

echo "🚀 Liquibase PostgreSQL Projesi Başlatılıyor..."

# Docker servislerini başlat
echo "📦 Docker servisleri başlatılıyor..."
docker-compose up -d

# PostgreSQL'in hazır olmasını bekle
echo "⏳ PostgreSQL'in hazır olması bekleniyor..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "Deneme $attempt/$max_attempts..."
    
    if docker-compose exec -T postgres pg_isready -U admin -d testdb >/dev/null 2>&1; then
        echo "✅ PostgreSQL hazır!"
        break
    fi
    
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ PostgreSQL başlatılamadı!"
    exit 1
fi

# Liquibase migration'ları çalıştır
echo "🔄 Liquibase migration'ları çalıştırılıyor..."
docker-compose run --rm liquibase update

if [ $? -eq 0 ]; then
    echo "✅ Migration'lar başarıyla tamamlandı!"
    
    # Migration durumunu göster
    echo "📊 Migration durumu:"
    docker-compose run --rm liquibase status
    
    # Veritabanı bağlantı bilgilerini göster
    echo ""
    echo "🔗 Veritabanı Bağlantı Bilgileri:"
    echo "Host: localhost"
    echo "Port: 5432"
    echo "Database: testdb"
    echo "Username: admin"
    echo "Password: admin"
    
    echo ""
    echo "🌐 pgAdmin veya başka bir PostgreSQL client ile bağlanabilirsiniz."
else
    echo "❌ Migration'lar başarısız!"
    exit 1
fi

echo ""
echo "🎉 Proje başarıyla başlatıldı!"
echo "Servisleri durdurmak için: docker-compose down"
