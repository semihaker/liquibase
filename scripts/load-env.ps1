# .env dosyasını yükleyen helper script
# Kullanım: . .\scripts\load-env.ps1

function Load-EnvFile {
    param(
        [string]$EnvFilePath = ".env"
    )

    if (-not (Test-Path $EnvFilePath)) {
        Write-Host ".env dosyası bulunamadı! .env.example dosyasından kopyalayıp düzenleyin." -ForegroundColor Red
        Write-Host "Örnek: Copy-Item .env.example .env" -ForegroundColor Yellow
        exit 1
    }

    Write-Host ".env dosyası yükleniyor..." -ForegroundColor Cyan
    
    Get-Content $EnvFilePath | ForEach-Object {
        $line = $_.Trim()
        
        # Boş satırları ve yorum satırlarını atla
        if ($line -eq "" -or $line.StartsWith("#")) {
            return
        }
        
        # KEY=VALUE formatını ayrıştır
        if ($line -match "^([^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Tırnak işaretlerini kaldır
            $value = $value -replace '^["'']|["'']$', ''
            
            # Environment variable olarak ayarla
            [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
            
            Write-Host "  ✓ $key yüklendi" -ForegroundColor Gray
        }
    }
    
    Write-Host "✓ Environment variables yüklendi" -ForegroundColor Green
}

# Script çağrıldığında otomatik olarak yükle
Load-EnvFile
