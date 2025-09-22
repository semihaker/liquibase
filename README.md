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

| Veritabanı | Host | Port | Database | User | Password |
|------------|------|------|----------|------|----------|
| PostgreSQL | localhost | 5432 | testdb | admin | admin |
| MySQL | localhost | 3307 | testdb | admin | admin |
| MSSQL | localhost | 1433 | testdb | sa | Admin123! |
| Oracle | localhost | 1521 | XE | system | admin |

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