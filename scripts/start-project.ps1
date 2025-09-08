# Liquibase PostgreSQL Projesi Başlatma Script'i
# PowerShell 7+ gereklidir

Write-Host "🚀 Liquibase PostgreSQL Projesi Başlatılıyor..." -ForegroundColor Green

# Docker servislerini başlat
Write-Host "📦 Docker servisleri başlatılıyor..." -ForegroundColor Yellow
docker-compose up -d

# PostgreSQL'in hazır olmasını bekle
Write-Host "⏳ PostgreSQL'in hazır olması bekleniyor..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "Deneme $attempt/$maxAttempts..." -ForegroundColor Cyan
    
    try {
        $result = docker-compose exec -T postgres pg_isready -U admin -d testdb 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PostgreSQL hazır!" -ForegroundColor Green
            break
        }
    }
    catch {
        # Hata durumunda devam et
    }
    
    Start-Sleep -Seconds 2
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "❌ PostgreSQL başlatılamadı!" -ForegroundColor Red
    exit 1
}

# Liquibase migration'ları çalıştır
Write-Host "🔄 Liquibase migration'ları çalıştırılıyor..." -ForegroundColor Yellow
docker-compose run --rm liquibase update

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Migration'lar başarıyla tamamlandı!" -ForegroundColor Green
    
    # Migration durumunu göster
    Write-Host "📊 Migration durumu:" -ForegroundColor Cyan
    docker-compose run --rm liquibase status
    
    # Veritabanı bağlantı bilgilerini göster
    Write-Host "`n🔗 Veritabanı Bağlantı Bilgileri:" -ForegroundColor Cyan
    Write-Host "Host: localhost" -ForegroundColor White
    Write-Host "Port: 5432" -ForegroundColor White
    Write-Host "Database: testdb" -ForegroundColor White
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: admin" -ForegroundColor White
    
    Write-Host "`n🌐 pgAdmin veya başka bir PostgreSQL client ile bağlanabilirsiniz." -ForegroundColor Green
} else {
    Write-Host "❌ Migration'lar başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎉 Proje başarıyla başlatıldı!" -ForegroundColor Green
Write-Host "Servisleri durdurmak için: docker-compose down" -ForegroundColor Yellow
