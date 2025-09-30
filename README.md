# Liquibase Multi-Database Migration

Liquibase ile çoklu veritabanı migration sistemi. PostgreSQL, MySQL, MSSQL ve Oracle desteği.

## Ne Bu?

Veritabanı değişikliklerini otomatik yönetmek için Liquibase kullanıyorum. Docker ve Jenkins ile tam otomatik.

## Desteklenen Veritabanları

- **PostgreSQL** - Ana veritabanı
- **MySQL** - Alternatif veritabanı  
- **MSSQL** - Microsoft SQL Server
- **Oracle** - Enterprise veritabanı

## Hızlı Başlangıç

### 1. Ortam Değişkenlerini Ayarla

Güvenlik için credential'lar `.env` dosyasında tutuluyor:

```bash
# .env.example dosyasını kopyala
cp .env.example .env

# .env dosyasını düzenle ve kendi credential'larını gir
# Not: .env dosyası .gitignore'da olduğu için Git'e pushllanmayacak
```

### 2. Migration'ları Çalıştır

```bash
# PostgreSQL
docker-compose up -d
docker-compose run --rm liquibase update

# MySQL
docker compose -f docker-compose.mysql.yml up -d
docker compose -f docker-compose.mysql.yml run --rm liquibase update

# MSSQL
docker compose -f docker-compose.mssql.yml up -d
docker compose -f docker-compose.mssql.yml run --rm liquibase update

# Oracle
docker compose -f docker-compose.oracle.yml up -d
docker compose -f docker-compose.oracle.yml run --rm liquibase update
```

## Jenkins Pipeline

Otomatik migration çalıştırmak için Jenkins pipeline'ı var. Parametreler:

- **DATABASE_TYPE:** postgresql, mysql, mssql, oracle
- **DRY_RUN:** Sadece SQL oluştur, çalıştırma
- **CONTEXTS:** DDL/DML filtreleme

## Migration Komutları

```bash
# Durum kontrolü
docker-compose run --rm liquibase status

# Migration çalıştır
docker-compose run --rm liquibase update

# Sadece DDL çalıştır
docker-compose run --rm liquibase update --contexts=ddl

# Rollback yap
docker-compose run --rm liquibase rollback --changesetId=admin:001:create-users-table
```

## Veritabanı Bağlantıları

Tüm veritabanı credential'ları `.env` dosyasından okunur. Varsayılan değerler:

| Veritabanı | Host | Port | Database | User | Password |
|------------|------|------|----------|------|----------|
| PostgreSQL | localhost | 5432 | testdb | `.env`'den okunur | `.env`'den okunur |
| MySQL | localhost | 3307 | testdb | `.env`'den okunur | `.env`'den okunur |
| MSSQL | localhost | 1433 | testdb | `.env`'den okunur | `.env`'den okunur |
| Oracle | localhost | 1521 | XE | `.env`'den okunur | `.env`'den okunur |

**⚠️ Güvenlik Notu:** `.env` dosyası Git'e pushllanmaz. Lütfen kendi ortamınızda güvenli değerler kullanın.

## Temizlik

```bash
# Tüm servisleri durdur
docker-compose down -v
docker compose -f docker-compose.mysql.yml down -v
docker compose -f docker-compose.mssql.yml down -v
docker compose -f docker-compose.oracle.yml down -v
```

## Gereksinimler

- Docker
- Docker Compose
- PowerShell 7+ (Windows için)

## Güvenlik

### Credential Yönetimi

Bu proje environment variable'lar kullanarak credential'ları güvenli tutar:

1. **`.env` Dosyası**: Tüm hassas bilgiler burada
2. **`.env.example` Şablonu**: Genel repo için örnek şablon
3. **`.gitignore`**: `.env` dosyasının Git'e pushlanmasını engeller

### Environment Variables

`.env` dosyasında şu değişkenler kullanılıyor:

#### PostgreSQL
- `POSTGRES_HOST` - PostgreSQL host adresi
- `POSTGRES_PORT` - PostgreSQL port numarası
- `POSTGRES_DB` - Veritabanı adı
- `POSTGRES_USER` - Kullanıcı adı
- `POSTGRES_PASSWORD` - Şifre

#### MySQL
- `MYSQL_HOST` - MySQL host adresi
- `MYSQL_PORT` - MySQL port numarası
- `MYSQL_DB` - Veritabanı adı
- `MYSQL_USER` - Kullanıcı adı
- `MYSQL_PASSWORD` - Şifre

#### MS SQL Server
- `MSSQL_HOST` - MSSQL host adresi
- `MSSQL_PORT` - MSSQL port numarası
- `MSSQL_DB` - Veritabanı adı
- `MSSQL_USER` - Kullanıcı adı
- `MSSQL_PASSWORD` - Şifre

#### Oracle
- `ORACLE_HOST` - Oracle host adresi
- `ORACLE_PORT` - Oracle port numarası
- `ORACLE_SERVICE` - Oracle service adı
- `ORACLE_USER` - Kullanıcı adı
- `ORACLE_PASSWORD` - Şifre

### PowerShell Scriptleri

Tüm PowerShell scriptleri `.env` dosyasını otomatik yükler:

```powershell
# Script başlangıcında .env yükleniyor
. "$PSScriptRoot\load-env.ps1"
```

### İlk Kurulum

```bash
# 1. Repoyu klonla
git clone <repo-url>

# 2. .env dosyasını oluştur
cp .env.example .env

# 3. .env dosyasını düzenle - KENDİ ŞİFRELERİNİ GİR!
# Windows: notepad .env
# Linux/Mac: nano .env

# 4. Docker servisleri başlat
docker-compose up -d
```

**⚠️ ÖNEMLİ**: Asla gerçek production credential'larını `.env.example` dosyasına ekleme!