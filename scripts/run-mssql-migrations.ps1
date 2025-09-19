# Liquibase MSSQL Projesi Başlatma Script'i
# PowerShell 7+ gereklidir

Write-Host "Liquibase MSSQL Projesi Başlatılıyor..." -ForegroundColor Green

# Docker servislerini başlat
Write-Host "Docker servisleri başlatılıyor..." -ForegroundColor Yellow
docker compose -f docker-compose.mssql.yml up -d

# MSSQL'in hazır olmasını bekle
Write-Host "MSSQL'in hazır olması bekleniyor..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "Deneme $attempt/$maxAttempts..." -ForegroundColor Cyan

    try {
        $result = docker compose -f docker-compose.mssql.yml exec -T mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Admin123! -Q "SELECT 1" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "MSSQL hazır!" -ForegroundColor Green
            break
        }
    }
    catch {
        # Hata durumunda devam et
    }

    Start-Sleep -Seconds 2
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "MSSQL başlatılamadı!" -ForegroundColor Red
    exit 1
}

# Liquibase migration'larını çalıştır
Write-Host "Liquibase migration'ları çalıştırılıyor..." -ForegroundColor Yellow
docker compose -f docker-compose.mssql.yml up liquibase

if ($LASTEXITCODE -eq 0) {
    Write-Host "Migration'lar başarıyla tamamlandı!" -ForegroundColor Green

    # Migration durumunu göster
    Write-Host "Migration durumu:" -ForegroundColor Cyan
    docker compose -f docker-compose.mssql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mssql.properties status

    # Veritabanı bağlantı bilgilerini göster
    Write-Host "`nVeritabanı Bağlantı Bilgileri:" -ForegroundColor Cyan
    Write-Host "Host: localhost" -ForegroundColor White
    Write-Host "Port: 1433" -ForegroundColor White
    Write-Host "Database: testdb" -ForegroundColor White
    Write-Host "Username: sa" -ForegroundColor White
    Write-Host "Password: Admin123!" -ForegroundColor White

    Write-Host "`nSQL Server Management Studio veya başka bir MSSQL client ile bağlanabilirsiniz." -ForegroundColor Green
} else {
    Write-Host "Migration'lar başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "`nProje başarıyla başlatıldı!" -ForegroundColor Green
Write-Host "Servisleri durdurmak için: docker compose -f docker-compose.mssql.yml down" -ForegroundColor Yellow
