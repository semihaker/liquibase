# 🗄️ Liquibase Veritabanı Migration Projesi

Bu proje, veritabanı değişikliklerini (tablo oluşturma, veri ekleme, vs.) güvenli bir şekilde yönetmek için kullanılır. Docker ile PostgreSQL ve MySQL veritabanlarını çalıştırır, Liquibase ile değişiklikleri uygular.

## 🤔 Bu Proje Ne Yapar?

**Basitçe:** Veritabanındaki tabloları, verileri ve yapıları otomatik olarak günceller. Manuel SQL yazmak yerine, değişiklikleri dosyalara yazarsın, proje bunları otomatik uygular.

**Kimler Kullanır:** Yazılım geliştiricileri, veritabanı yöneticileri, DevOps mühendisleri

## 📁 Dosyalar ve Ne İşe Yarar (Mala Anlatır Gibi)

### 🐳 Docker Dosyaları (Konteyner Yöneticileri)
- **`docker-compose.yml`** 
  - **Ne yapar:** PostgreSQL veritabanını Docker konteynerinde çalıştırır
  - **Kiminle konuşur:** Docker Engine ile
  - **Nasıl çalışır:** PostgreSQL'i localhost:5432'de ayağa kaldırır
  - **Neden var:** Veritabanını her yerde aynı şekilde çalıştırmak için

- **`docker-compose.mysql.yml`**
  - **Ne yapar:** MySQL veritabanını Docker konteynerinde çalıştırır  
  - **Kiminle konuşur:** Docker Engine ile
  - **Nasıl çalışır:** MySQL'i localhost:3307'de ayağa kaldırır
  - **Neden var:** MySQL kullanmak isteyenler için alternatif

### ⚙️ Liquibase Ayar Dosyaları (Bağlantı Bilgileri)
- **`liquibase.properties`**
  - **Ne yapar:** PostgreSQL'e nasıl bağlanacağını söyler
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** Veritabanı adresi, kullanıcı adı, şifre
  - **Neden var:** Liquibase'in PostgreSQL'i bulabilmesi için

- **`liquibase-mysql.properties`**
  - **Ne yapar:** MySQL'e nasıl bağlanacağını söyler
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** MySQL bağlantı bilgileri
  - **Neden var:** Liquibase'in MySQL'i bulabilmesi için

### 📊 Migration Dosyaları (Veritabanı Değişiklikleri)
- **`changelog/changelog.sql`**
  - **Ne yapar:** PostgreSQL için tüm veritabanı değişikliklerini içerir
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** Tablo oluşturma, veri ekleme komutları
  - **Neden var:** Ana migration dosyası, tüm değişiklikler burada

- **`changelog/mysql/changelog.sql`**
  - **Ne yapar:** MySQL için uyumlu değişiklikleri içerir
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** MySQL'e özel SQL komutları
  - **Neden var:** MySQL farklı SQL sözdizimi kullanır

- **`changelog/advanced-migrations.sql`**
  - **Ne yapar:** Karmaşık migration örnekleri içerir
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** Fonksiyonlar, view'lar, trigger'lar
  - **Neden var:** Gelişmiş özellikler öğrenmek için

- **`changelog/seed-data.sql`**
  - **Ne yapar:** Test verilerini veritabanına ekler
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** INSERT komutları ile örnek veriler
  - **Neden var:** Veritabanında test edilecek veri olması için

- **`changelog/test-database.sql`**
  - **Ne yapar:** Test için özel tablolar ve veriler oluşturur
  - **Kiminle konuşur:** Liquibase ile
  - **İçinde ne var:** Test tabloları, test verileri
  - **Neden var:** Test ortamında çalışmak için

### 🚀 Jenkins Pipeline Dosyaları (Otomatik Çalıştırıcılar)
- **`Jenkinsfile`**
  - **Ne yapar:** PostgreSQL migration'larını otomatik çalıştırır
  - **Kiminle konuşur:** Jenkins ile, Docker ile, Liquibase ile
  - **Nasıl çalışır:** Jenkins job'u tetiklendiğinde PostgreSQL'i başlatır, migration'ları uygular
  - **Neden var:** Manuel işlem yapmadan otomatik deployment için

- **`jenkins/Jenkinsfile-mysql`**
  - **Ne yapar:** MySQL migration'larını otomatik çalıştırır
  - **Kiminle konuşur:** Jenkins ile, Docker ile, Liquibase ile
  - **Nasıl çalışır:** Jenkins job'u tetiklendiğinde MySQL'i başlatır, migration'ları uygular
  - **Neden var:** MySQL için ayrı otomatik süreç

### 🔧 PowerShell Script'leri (Windows Otomasyon)
- **`scripts/start-project.ps1`**
  - **Ne yapar:** PostgreSQL projesini tek komutla başlatır
  - **Kiminle konuşur:** Docker ile, PostgreSQL ile
  - **Nasıl çalışır:** Docker'ı başlatır, veritabanının hazır olmasını bekler, migration'ları çalıştırır
  - **Neden var:** Windows'ta kolay kullanım için

- **`scripts/run-mysql-migrations.ps1`**
  - **Ne yapar:** MySQL migration'larını tek komutla çalıştırır
  - **Kiminle konuşur:** Docker ile, MySQL ile, Liquibase ile
  - **Nasıl çalışır:** MySQL'i başlatır, migration'ları uygular, test eder
  - **Neden var:** MySQL'i kolayca çalıştırmak için

- **`scripts/test-database.ps1`**
  - **Ne yapar:** Test veritabanını oluşturur ve test eder
  - **Kiminle konuşur:** Docker ile, PostgreSQL ile, Liquibase ile
  - **Nasıl çalışır:** Test migration'larını çalıştırır, sonuçları kontrol eder
  - **Neden var:** Test ortamını hızlıca kurmak için

- **`scripts/clean-test-database.ps1`**
  - **Ne yapar:** Test veritabanını temizler
  - **Kiminle konuşur:** Docker ile, Liquibase ile
  - **Nasıl çalışır:** Test tablolarını siler, migration'ları geri alır
  - **Neden var:** Test ortamını sıfırlamak için

- **`scripts/query-test-database.ps1`**
  - **Ne yapar:** Test veritabanındaki verileri sorgular ve gösterir
  - **Kiminle konuşur:** PostgreSQL ile
  - **Nasıl çalışır:** SQL sorguları çalıştırır, sonuçları ekrana yazdırır
  - **Neden var:** Test verilerini kontrol etmek için


### 🗃️ JDBC Driver'ları (Veritabanı Bağlantı Kütüphaneleri)
- **`drivers/postgresql-42.7.1.jar`**
  - **Ne yapar:** Java'nın PostgreSQL ile konuşmasını sağlar
  - **Kiminle konuşur:** Liquibase ile, PostgreSQL ile
  - **Nasıl çalışır:** Java kütüphanesi olarak çalışır
  - **Neden var:** Liquibase'in PostgreSQL'e bağlanabilmesi için

- **`drivers/mysql-connector-j-8.4.0.jar`**
  - **Ne yapar:** Java'nın MySQL ile konuşmasını sağlar
  - **Kiminle konuşur:** Liquibase ile, MySQL ile
  - **Nasıl çalışır:** Java kütüphanesi olarak çalışır
  - **Neden var:** Liquibase'in MySQL'e bağlanabilmesi için

### 🔐 Jenkins Konfigürasyonu
- **`01-create-admin.groovy`**
  - **Ne yapar:** Jenkins'te admin kullanıcısı oluşturur
  - **Kiminle konuşur:** Jenkins ile
  - **Nasıl çalışır:** Jenkins başlatıldığında otomatik çalışır
  - **Neden var:** Jenkins'e giriş yapabilmek için admin hesabı gerekli

## 🔄 Dosyalar Arası İletişim Akışı

### 🎯 Normal Çalışma Akışı (PostgreSQL)
1. **`scripts/start-project.ps1`** → **`docker-compose.yml`** → **Docker Engine**
2. **Docker Engine** → **PostgreSQL Container** (localhost:5432)
3. **`liquibase.properties`** → **Liquibase** (bağlantı bilgileri)
4. **`changelog/changelog.sql`** → **Liquibase** (migration komutları)
5. **Liquibase** → **PostgreSQL** (SQL komutlarını uygular)
6. **`drivers/postgresql-42.7.1.jar`** → **Liquibase** (bağlantı için)

### 🎯 Normal Çalışma Akışı (MySQL)
1. **`scripts/run-mysql-migrations.ps1`** → **`docker-compose.mysql.yml`** → **Docker Engine**
2. **Docker Engine** → **MySQL Container** (localhost:3307)
3. **`liquibase-mysql.properties`** → **Liquibase** (bağlantı bilgileri)
4. **`changelog/mysql/changelog.sql`** → **Liquibase** (migration komutları)
5. **Liquibase** → **MySQL** (SQL komutlarını uygular)
6. **`drivers/mysql-connector-j-8.4.0.jar`** → **Liquibase** (bağlantı için)

### 🎯 Jenkins Otomatik Akışı
1. **Jenkins** → **`Jenkinsfile`** (PostgreSQL için)
2. **Jenkins** → **`jenkins/Jenkinsfile-mysql`** (MySQL için)
3. **Jenkinsfile** → **Docker** → **PostgreSQL** → **Liquibase**
4. **Jenkinsfile-mysql** → **Docker** → **MySQL** → **Liquibase**

### 🎯 Test Akışı
1. **`scripts/test-database.ps1`** → **Docker** → **PostgreSQL**
2. **`changelog/test-database.sql`** → **Liquibase** → **PostgreSQL**
3. **`scripts/query-test-database.ps1`** → **PostgreSQL** (sonuçları gösterir)
4. **`scripts/clean-test-database.ps1`** → **Liquibase** → **PostgreSQL** (temizler)

## 🤝 Kim Kiminle Konuşur?

### Docker Dosyaları
- **`docker-compose.yml`** ↔ **Docker Engine** ↔ **PostgreSQL Container**
- **`docker-compose.mysql.yml`** ↔ **Docker Engine** ↔ **MySQL Container**

### Liquibase Dosyaları
- **`liquibase.properties`** → **Liquibase** (PostgreSQL bağlantısı)
- **`liquibase-mysql.properties`** → **Liquibase** (MySQL bağlantısı)
- **`changelog/*.sql`** → **Liquibase** (migration komutları)
- **`drivers/*.jar`** → **Liquibase** (veritabanı bağlantısı)

### Script'ler
- **PowerShell Script'ler** ↔ **Docker** ↔ **Veritabanları** ↔ **Liquibase**

### Jenkins
- **Jenkins** ↔ **Docker** ↔ **Veritabanları** ↔ **Liquibase**
- **`01-create-admin.groovy`** → **Jenkins** (admin kullanıcısı)

## 🚀 Hızlı Başlangıç (Mala Anlatır Gibi)

### 🎯 Senaryo 1: "PostgreSQL ile çalışmak istiyorum"
```bash
# Windows'ta tek komutla başlat
.\scripts\start-project.ps1

# Ne olur?
# 1. Docker PostgreSQL'i başlatır
# 2. Veritabanının hazır olmasını bekler
# 3. Liquibase migration'ları uygular
# 4. "Başarılı!" der
```

### 🎯 Senaryo 2: "MySQL ile çalışmak istiyorum"
```bash
# Windows'ta tek komutla başlat
    .\scripts\run-mysql-migrations.ps1

# Ne olur?
# 1. Docker MySQL'i başlatır
# 2. Veritabanının hazır olmasını bekler
# 3. Liquibase migration'ları uygular
# 4. Test eder ve "Başarılı!" der
```

### 🎯 Senaryo 3: "Test veritabanı oluşturmak istiyorum"
```bash
# Test veritabanını oluştur
    .\scripts\test-database.ps1

# Test verilerini görüntüle
.\scripts\query-test-database.ps1

# Test veritabanını temizle
.\scripts\clean-test-database.ps1
```

### 🎯 Senaryo 4: "Manuel olarak yapmak istiyorum"
```powershell
# PostgreSQL için
docker-compose up -d                    # Veritabanını başlat
docker-compose run --rm liquibase update # Migration'ları uygula

# MySQL için
docker compose -f docker-compose.mysql.yml up -d
docker compose -f docker-compose.mysql.yml run --rm liquibase update
```

## 📊 Veritabanı Bağlantı Bilgileri

### PostgreSQL
- **Host:** localhost
- **Port:** 5432
- **Database:** testdb
- **Username:** admin
- **Password:** admin

### MySQL
- **Host:** localhost
- **Port:** 3307
- **Database:** testdb
- **Username:** admin
- **Password:** admin

## 🔄 Migration Yönetimi

### Temel Komutlar
```bash
# Migration durumunu kontrol et
docker-compose run --rm liquibase status

# Yeni migration'ları uygula
docker-compose run --rm liquibase update

# Changelog'u doğrula
docker-compose run --rm liquibase validate

# Rollback yap
docker-compose run --rm liquibase rollback --changesetId=semih:001:create-users-table
```

### Context Kullanımı
    ```bash
# Sadece DDL (şema) değişikliklerini çalıştır
docker-compose run --rm liquibase update --contexts=ddl

# Sadece DML (veri) değişikliklerini çalıştır
docker-compose run --rm liquibase update --contexts=dml
```

## 🧪 Test Veritabanı

### Test Veritabanını Oluştur
```bash
.\scripts\test-database.ps1
```

### Test Veritabanını Sorgula
```bash
.\scripts\query-test-database.ps1
```

### Test Veritabanını Temizle
    ```bash
.\scripts\clean-test-database.ps1
```

## 🤖 Jenkins Entegrasyonu

### Pipeline Özellikleri
- **Otomatik Health Check:** Veritabanının hazır olmasını bekler
- **Context Desteği:** DDL/DML ayrı çalıştırma
- **Dry Run:** Gerçek update yerine SQL çıktısı
- **Rollback:** Belirtilen sayıda changeset geri alma
- **Smoke Test:** Tabloların ve verilerin doğrulanması

### Jenkins Parametreleri
- **contexts:** Liquibase context'leri (örn: `ddl,dml`)
- **runOnlyDDL:** Sadece DDL çalıştır
- **runOnlyDML:** Sadece DML çalıştır
- **dryRunUpdate:** SQL çıktısı üret
- **rollbackCount:** Rollback sayısı

## 📋 Changeset Yapısı

### DDL (Data Definition Language) Örneği
    ```sql
--changeset semih:001:create-users-table context:ddl
    CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        email VARCHAR(100) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    --rollback DROP TABLE users;
    ```

### DML (Data Manipulation Language) Örneği
    ```sql
--changeset semih:010:seed-users context:dml
INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('user1', 'user1@example.com');
--rollback DELETE FROM users WHERE username IN ('admin', 'user1');
```

## 🔧 Gereksinimler

- Docker
- Docker Compose
- PowerShell 7+ (Windows için)
- Git (opsiyonel)

## 📚 Faydalı Komutlar

    ### PostgreSQL
    ```bash
    # PostgreSQL'e bağlan
    docker exec -it postgres-testdb psql -U admin -d testdb

    # Tabloları listele
    docker exec -it postgres-testdb psql -U admin -d testdb -c "\dt"

    # Logları gör
    docker-compose logs postgres
    ```

    ### MySQL
    ```bash
    # MySQL'e bağlan
    docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb

    # Tabloları listele
    docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb -e "SHOW TABLES;"
```

## 🧹 Temizlik

    ```bash
# Servisleri durdur
docker-compose down

# Servisleri durdur ve verileri sil
docker-compose down -v

# MySQL servislerini durdur
docker compose -f docker-compose.mysql.yml down -v
```

## 🎯 Proje Özellikleri

- ✅ **Multi-Database Support:** PostgreSQL ve MySQL desteği
- ✅ **Docker Orchestration:** Her veritabanı için ayrı container'lar
- ✅ **Jenkins CI/CD:** Gelişmiş pipeline'lar
- ✅ **PowerShell Scripts:** Windows ortamında otomatik script'ler
- ✅ **Context Management:** DDL ve DML ayrı yönetim
- ✅ **Comprehensive Testing:** Smoke test'ler ile otomatik doğrulama
- ✅ **Driver Management:** JDBC driver'ları otomatik yönetim

## 🎯 Özet (Mala Anlatır Gibi)

### 🤔 Bu Proje Ne İşe Yarar?
- **Veritabanı değişikliklerini** otomatik yapar
- **Tabloları oluşturur**, **veri ekler**, **günceller**
- **Manuel SQL yazmak** yerine **dosyalara yazarsın**
- **Docker** ile **her yerde aynı şekilde** çalışır

### 👥 Kimler Kullanır?
- **Yazılım geliştiricileri** (kod yazanlar)
- **Veritabanı yöneticileri** (DB yönetenler)
- **DevOps mühendisleri** (sistem yönetenler)

### 🚀 Nasıl Başlarım?
1. **Windows'ta:** `.\scripts\start-project.ps1` çalıştır
2. **Bitti!** Veritabanın hazır

### 📁 Hangi Dosya Ne Yapar?
- **`docker-compose.yml`** → PostgreSQL'i başlatır
- **`changelog/changelog.sql`** → Veritabanı değişikliklerini içerir
- **`scripts/start-project.ps1`** → Her şeyi otomatik yapar
- **`liquibase.properties`** → PostgreSQL'e nasıl bağlanacağını söyler

### 🔄 Nasıl Çalışır?
1. **Script çalıştır** → **Docker başlatır** → **Veritabanı hazır**
2. **Liquibase okur** → **SQL komutları uygular** → **Veritabanı güncellenir**
3. **Test eder** → **"Başarılı!" der**

    Bu proje, modern veritabanı migration yönetimi için kapsamlı bir çözüm sunmaktadır.