# Liquibase Oracle Projesi Başlatma Script'i
# PowerShell 7+ gereklidir

Write-Host "Liquibase Oracle Projesi Başlatılıyor..." -ForegroundColor Green

# .env dosyasını yükle
. "$PSScriptRoot\load-env.ps1"

# Docker servislerini başlat
Write-Host "Docker servisleri başlatılıyor..." -ForegroundColor Yellow
docker compose -f docker-compose.oracle.yml up -d

# Oracle'ın hazır olmasını bekle
Write-Host "Oracle'ın hazır olması bekleniyor..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "Deneme $attempt/$maxAttempts..." -ForegroundColor Cyan

    try {
        $result = docker compose -f docker-compose.oracle.yml exec -T oracle sqlplus -L $env:ORACLE_USER/$env:ORACLE_PASSWORD@localhost:$env:ORACLE_PORT/$env:ORACLE_SERVICE -S -c "SELECT 1 FROM DUAL;" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Oracle hazır!" -ForegroundColor Green
            break
        }
    }
    catch {
        # Hata durumunda devam et
    }

    Start-Sleep -Seconds 2
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "Oracle başlatılamadı!" -ForegroundColor Red
    exit 1
}

# Liquibase migration'larını çalıştır
Write-Host "Liquibase migration'ları çalıştırılıyor..." -ForegroundColor Yellow
docker compose -f docker-compose.oracle.yml up liquibase

if ($LASTEXITCODE -eq 0) {
    Write-Host "Migration'lar başarıyla tamamlandı!" -ForegroundColor Green

    # Migration durumunu göster
    Write-Host "Migration durumu:" -ForegroundColor Cyan
    docker compose -f docker-compose.oracle.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-oracle.properties status

    # Veritabanı bağlantı bilgilerini göster
    Write-Host "`nVeritabanı Bağlantı Bilgileri:" -ForegroundColor Cyan
    Write-Host "Host: localhost" -ForegroundColor White
    Write-Host "Port: $env:ORACLE_PORT" -ForegroundColor White
    Write-Host "Database: $env:ORACLE_SERVICE" -ForegroundColor White
    Write-Host "Username: $env:ORACLE_USER" -ForegroundColor White
    Write-Host "Password: ********" -ForegroundColor White

    Write-Host "`nOracle SQL Developer veya başka bir Oracle client ile bağlanabilirsiniz." -ForegroundColor Green
} else {
    Write-Host "Migration'lar başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "`nProje başarıyla başlatıldı!" -ForegroundColor Green
Write-Host "Servisleri durdurmak için: docker compose -f docker-compose.oracle.yml down" -ForegroundColor Yellow
