# Liquibase PostgreSQL Projesi Baslatma Script'i
# PowerShell 7+ gereklidir

Write-Host "Liquibase PostgreSQL Projesi Baslatiliyor..." -ForegroundColor Green

# Docker servislerini baslat
Write-Host "Docker servisleri baslatiliyor..." -ForegroundColor Yellow
docker-compose up -d

# PostgreSQL'in hazir olmasini bekle
Write-Host "PostgreSQL'in hazir olmasi bekleniyor..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "Deneme $attempt/$maxAttempts..." -ForegroundColor Cyan
    
    try {
        $result = docker-compose exec -T postgres pg_isready -U admin -d testdb 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PostgreSQL hazir!" -ForegroundColor Green
            break
        }
    }
    catch {
        # Hata durumunda devam et
    }
    
    Start-Sleep -Seconds 2
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "PostgreSQL baslatilamadi!" -ForegroundColor Red
    exit 1
}

# Liquibase migration'larini calistir
Write-Host "Liquibase migration'lari calistiriliyor..." -ForegroundColor Yellow
docker-compose up liquibase

if ($LASTEXITCODE -eq 0) {
    Write-Host "Migration'lar basariyla tamamlandi!" -ForegroundColor Green
    
    # Migration durumunu goster
    Write-Host "Migration durumu:" -ForegroundColor Cyan
    docker-compose run --rm liquibase --defaultsFile=/liquibase/liquibase.properties status
    
    # Veritabani baglanti bilgilerini goster
    Write-Host "`nVeritabani Baglanti Bilgileri:" -ForegroundColor Cyan
    Write-Host "Host: localhost" -ForegroundColor White
    Write-Host "Port: 5432" -ForegroundColor White
    Write-Host "Database: testdb" -ForegroundColor White
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: admin" -ForegroundColor White
    
    Write-Host "`npgAdmin veya baska bir PostgreSQL client ile baglanabilirsiniz." -ForegroundColor Green
} else {
    Write-Host "Migration'lar basarisiz!" -ForegroundColor Red
    exit 1
}

Write-Host "`nProje basariyla baslatildi!" -ForegroundColor Green
Write-Host "Servisleri durdurmak icin: docker-compose down" -ForegroundColor Yellow
