# Liquibase Migration Projesi (MySQL + Docker + Jenkins)

Bu proje, Liquibase kullanarak PostgreSQL ve MySQL veritabanı değişikliklerini Docker ortamında ve Jenkins pipeline üzerinden yönetmek için tasarlanmıştır.

## 🎯 Proje Amacı

- Veritabanı değişikliklerini güvenli ve otomatik bir şekilde yönetmek
- Manuel SQL çalıştırmak yerine, versiyonlanmış değişiklikleri (migrations) Liquibase ile uygulamak
- Docker ortamında bağımsız ve taşınabilir bir yapı kurmak
- CI/CD süreçlerini desteklemek

## 🏗️ Mimari

- **PostgreSQL 14** veya **MySQL 8**: Docker container'da çalışan veritabanı
- **Liquibase**: Veritabanı migration yönetimi (ayrı container)
- **Docker Compose**: Servisleri koordine eden orkestrasyon
- **Jenkins**: CI/CD pipeline ile otomatik migration ve raporlama

## 📋 Gereksinimler

- Docker
- Docker Compose
- Git (opsiyonel)
 - Jenkins (opsiyonel, CI/CD için)

## 🚀 Kurulum ve Çalıştırma

### 1. PostgreSQL ile Çalıştırma (Var olan yapı)
```bash
# PostgreSQL servisini başlat
docker-compose up -d postgres

# Liquibase ile migration'ları uygula
docker-compose run --rm liquibase validate
docker-compose run --rm liquibase update
```

### 2. MySQL ile Çalıştırma (Yeni)
```bash
# MySQL servisini başlat
docker compose -f docker-compose.mysql.yml up -d mysql

# Liquibase doğrulama ve migration
docker compose -f docker-compose.mysql.yml run --rm liquibase validate
docker compose -f docker-compose.mysql.yml run --rm liquibase update
```

### 3. Yeniden Başlatma
```bash
# Servisleri durdur
docker-compose down

# Servisleri yeniden başlat
docker-compose up -d

# Veya tek komutla
docker-compose restart
```

### 4. Veritabanı Bağlantısı
```bash
# PostgreSQL (localhost:5435)
docker exec -it postgres-testdb psql -U admin -d testdb

# MySQL (localhost:3307)
docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb -e "SHOW TABLES;"
```

### 5. Liquibase Migration'ları Çalıştır
```bash
# Tüm migration'ları uygula
docker-compose run --rm liquibase update

# Belirli bir migration'ı uygula
docker-compose run --rm liquibase update --changesetId=semih:001:create-users-table

# Migration durumunu kontrol et
docker-compose run --rm liquibase status

# Rollback yap
docker-compose run --rm liquibase rollback --changesetId=semih:001:create-users-table

# MySQL için eşdeğer komutlar
docker compose -f docker-compose.mysql.yml run --rm liquibase update
docker compose -f docker-compose.mysql.yml run --rm liquibase status
```

## 📁 Dosya Yapısı

```
.
├── docker-compose.yml          # Docker servisleri yapılandırması
├── docker-compose.mysql.yml    # MySQL için Docker servisleri
├── liquibase.properties       # Liquibase bağlantı ayarları (Postgres)
├── liquibase-mysql.properties # Liquibase bağlantı ayarları (MySQL)
├── changelog/
│   └── changelog.sql         # Ana migration dosyası
│   └── mysql/changelog.sql   # MySQL uyumlu changeset'ler
├── jenkins/
│   ├── Jenkinsfile            # PostgreSQL pipeline
│   └── Jenkinsfile-mysql      # MySQL pipeline
└── README.md                  # Bu dosya
```

## 🔧 Liquibase Komutları

### Temel Komutlar
- `update`: Yeni migration'ları uygula
- `status`: Migration durumunu göster
- `rollback`: Belirli bir migration'ı geri al
- `validate`: Changelog dosyasını doğrula
- `diff`: Veritabanı şemasındaki farkları göster

### Örnek Kullanım (Postgres)
```bash
# Migration durumunu kontrol et
docker-compose run --rm liquibase status

# Changelog'u doğrula
docker-compose run --rm liquibase validate

# Veritabanı şemasındaki değişiklikleri göster
docker-compose run --rm liquibase diff
```

### Örnek Kullanım (MySQL)
```bash
docker compose -f docker-compose.mysql.yml run --rm liquibase status
docker compose -f docker-compose.mysql.yml run --rm liquibase validate
```

## 🤖 Jenkins Entegrasyonu

Jenkins job tetiklendiğinde aşağıdaki adımlar otomatik çalışır:

- PostgreSQL için `jenkins/Jenkinsfile`, MySQL için `jenkins/Jenkinsfile-mysql` kullanılır.
- **Adımlar**:
  - **Start DB**: İlgili veritabanı container'ı ayağa kaldırılır.
  - **Validate**: Changelog doğrulanır.
  - **Update**: Changeset'ler uygulanır.
  - **Status**: Uygulama durumu raporlanır.
  - **Smoke Test**: Tabloların ve temel veri kayıtlarının varlığı sorgulanır.

Jenkins UI'da aşama bazlı loglar üzerinden başarı/başarısızlık raporu görüntülenir.

Pipeline örneği (MySQL):
```groovy
// jenkins/Jenkinsfile-mysql dosyasındaki aşamalar:
// - Start MySQL
// - Validate Changelog
// - Update Database
// - Smoke Test: Verify Tables
```

## Ne Yaptık? (Anlatır gibi)

1) Liquibase mantığıyla DDL ve DML değişikliklerini SQL formatlı changeset'lere böldük. Her changeset benzersiz ID'ye sahip ve tek seferlik uygulanıyor; rollback tanımları ile geri alınabilir kıldık.
2) Docker'da veritabanını (PostgreSQL veya MySQL) ayrı bir container'da, Liquibase'i ise bağımsız bir container'da koşturduk. Liquibase container, `liquibase.properties` (Postgres) veya `liquibase-mysql.properties` (MySQL) dosyalarındaki JDBC ayarları ile DB’ye bağlanıyor.
3) Jenkins pipeline ile CI/CD akışı kurduk. Job tetiklenince veritabanı ayağa kalkıyor, Liquibase `validate` ve `update` komutlarını çalıştırıyor, ardından `status` ve smoke test sorguları ile gerçekten tabloların oluştuğunu ve verinin eklendiğini raporluyor.
4) Böylece “MySQL’deki tabloyu gerçekten oluşturup rapor vermesi” ve “script çalışıyor mu çalışmıyor mu Jenkins üzerinden görünmesi” beklentilerini karşılamış olduk.

## 📊 Migration Takibi

Liquibase, `databasechangelog` tablosunda hangi migration'ların uygulandığını takip eder:

```sql
-- Migration geçmişini görüntüle
SELECT * FROM databasechangelog ORDER BY orderexecuted;

-- Belirli bir migration'ın durumunu kontrol et
SELECT * FROM databasechangelog WHERE id = 'semih:001:create-users-table';
```

## 🔄 Yeni Migration Ekleme

### 1. Changelog Dosyasına Yeni Changeset Ekleyin
```sql
--changeset semih:006:add-new-feature
CREATE TABLE new_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

--rollback DROP TABLE new_table;
```

### 2. Migration'ı Uygulayın
```bash
docker-compose run --rm liquibase update
```

## 🎯 Changeset, DDL ve DML Yönetimi

### 📝 Changeset Nedir?
Changeset, Liquibase'de veritabanı değişikliklerini tanımlayan temel birimdir. Her changeset:
- **Benzersiz ID** ile tanımlanır (örn: `semih:001:create-users-table`)
- **Tek seferlik** çalıştırılır
- **Rollback** işlemi tanımlanabilir
- **Atomic** olarak çalışır (başarısız olursa tüm değişiklik geri alınır)

### 🏗️ DDL (Data Definition Language) Yönetimi

#### Tablo Oluşturma
```sql
--changeset semih:001:create-users-table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--rollback DROP TABLE users;
```

#### Tablo Değiştirme
```sql
--changeset semih:005:add-category-id-to-products
ALTER TABLE products ADD COLUMN category_id INTEGER REFERENCES categories(id);

--rollback ALTER TABLE products DROP COLUMN category_id;
```

#### İndeks Oluşturma
```sql
--changeset semih:003:add-indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(name);

--rollback DROP INDEX idx_users_email; DROP INDEX idx_products_name;
```

#### Kısıtlamalar Ekleme
```sql
--changeset semih:008:add-constraints
ALTER TABLE orders ADD CONSTRAINT chk_status 
CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'));

--rollback ALTER TABLE orders DROP CONSTRAINT chk_status;
```

#### View Oluşturma
```sql
--changeset semih:009:create-views
CREATE VIEW order_summary AS
SELECT 
    o.id as order_id,
    u.username,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
JOIN users u ON o.user_id = u.id;

--rollback DROP VIEW order_summary;
```

#### Fonksiyon Oluşturma
```sql
--changeset semih:010:create-functions
CREATE OR REPLACE FUNCTION update_order_total(order_id_param INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(total_price), 0) INTO total
    FROM order_items
    WHERE order_id = order_id_param;
    
    UPDATE orders SET total_amount = total WHERE id = order_id_param;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

--rollback DROP FUNCTION update_order_total(INTEGER);
```

### 📊 DML (Data Manipulation Language) Yönetimi

#### Veri Ekleme (INSERT)
```sql
--changeset semih:011:insert-sample-categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications');

--rollback DELETE FROM categories WHERE name IN ('Electronics', 'Clothing', 'Books');
```

#### Veri Güncelleme (UPDATE)
```sql
--changeset semih:014:update-product-prices
UPDATE products SET price = price * 1.1 WHERE category_id = 1;

--rollback UPDATE products SET price = price / 1.1 WHERE category_id = 1;
```

#### Veri Silme (DELETE)
```sql
--changeset ozan:015:remove-test-data
DELETE FROM users WHERE username LIKE 'test_%';

--rollback INSERT INTO users (username, email) VALUES 
--rollback ('test_user', 'test@example.com');
```

### 🔄 Rollback Stratejileri

#### Basit Rollback
```sql
--changeset :001:create-table
CREATE TABLE test_table (id INTEGER);

--rollback DROP TABLE test_table;
```

#### Koşullu Rollback
```sql
--changeset ozan:002:add-column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

--rollback ALTER TABLE users DROP COLUMN IF EXISTS phone;
```

#### Çoklu İşlem Rollback
```sql
--changeset ozan:003:multiple-operations
CREATE INDEX idx_name ON users(username);
CREATE INDEX idx_email ON users(email);

--rollback DROP INDEX IF EXISTS idx_name;
--rollback DROP INDEX IF EXISTS idx_email;
```

### 📁 Changelog Organizasyonu

#### Ana Changelog (changelog.sql)
```sql
--liquibase formatted sql

--changeset ozan:001:create-users-table
CREATE TABLE users (id SERIAL PRIMARY KEY, username VARCHAR(50));

--include advanced-migrations.sql
--include seed-data.sql
```

#### Alt Changelog'lar
```sql
-- advanced-migrations.sql
--changeset ozan:006:create-orders-table
CREATE TABLE orders (id SERIAL PRIMARY KEY);

-- seed-data.sql  
--changeset ozan:011:insert-data
INSERT INTO users (username) VALUES ('admin');
```

### ⚡ Best Practices

#### 1. Changeset ID'leri
- **Format**: `author:id:description`
- **Örnek**: `ozan:001:create-users-table`
- **Benzersiz**: Her ID sadece bir kez kullanılmalı

#### 2. Rollback Tanımlama
- Her DDL işlemi için rollback tanımlayın
- DML işlemleri için de rollback düşünün
- Test ortamında rollback'leri test edin

#### 3. Atomic İşlemler
- İlişkili değişiklikleri aynı changeset'te yapın
- Bağımsız değişiklikleri ayrı changeset'lere bölün

#### 4. Dokümantasyon
- Her changeset için açıklayıcı description kullanın
- Karmaşık işlemler için yorum ekleyin

### 🚀 Gelişmiş Özellikler

#### Koşullu Changeset'ler
```sql
--changeset ozan:016:conditional-update
--preconditions onFail:CONTINUE
--precondition-sql-check expectedResult:0
SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'new_feature_table'

CREATE TABLE new_feature_table (id INTEGER);

--rollback DROP TABLE new_feature_table;
```

#### Context Kullanımı
```sql
--changeset ozan:017:dev-only-feature context:dev
CREATE TABLE dev_table (id INTEGER);

--rollback DROP TABLE dev_table;
```

#### Labels
```sql
--changeset ozan:018:feature-flag labels:feature-flag
CREATE TABLE feature_table (id INTEGER);

--rollback DROP TABLE feature_table;
```

### 📊 Migration Durumu Takibi

```bash
# Tüm changeset'lerin durumunu görüntüle
docker-compose run --rm liquibase status

# Belirli bir changeset'i kontrol et
docker-compose run --rm liquibase status --changesetId=ozan:001:create-users-table

# Changelog'u doğrula
docker-compose run --rm liquibase validate
```

### 🔍 Veritabanında Changeset Takibi

```sql
-- Tüm uygulanan changeset'leri görüntüle
SELECT id, author, filename, orderexecuted, exectype, md5sum 
FROM databasechangelog 
ORDER BY orderexecuted;

-- Belirli bir changeset'in durumunu kontrol et
SELECT * FROM databasechangelog 
WHERE id = 'ozan:001:create-users-table';

-- Başarısız changeset'leri bul
SELECT * FROM databasechangelog 
WHERE exectype = 'FAILED';
```

## 🧹 Temizlik ve Yeniden Başlatma

```bash
# Servisleri durdur
docker-compose down

# Servisleri yeniden başlat
docker-compose up -d

# Tek komutla yeniden başlat
docker-compose restart

# Tüm servisleri durdur ve sil (veri silinir)
docker-compose down -v

# Sadece servisleri durdur (veri korunur)
docker-compose down
```

## ⚡ Hızlı Komutlar

```bash
# PostgreSQL'e bağlan
docker exec -it postgres-testdb psql -U admin -d testdb

# Tabloları listele
docker exec -it postgres-testdb psql -U admin -d testdb -c "\dt"

# Veritabanı durumu
docker-compose ps

# Logları gör
docker-compose logs postgres
```

## 🔍 Sorun Giderme

### PostgreSQL Bağlantı Hatası
```bash
# PostgreSQL'in hazır olduğunu kontrol et
docker-compose logs postgres

# Health check durumunu kontrol et
docker-compose ps
```

### Liquibase Hatası
```bash
# Liquibase loglarını kontrol et
docker-compose logs liquibase

# Liquibase'i yeniden çalıştır
docker-compose run --rm liquibase update
```



## 🖥️ pgAdmin Kurulum ve Bağlantı

### pgAdmin Kurulum
1. https://www.pgadmin.org/download/windows/ adresinden indir
2. pgAdmin 4 → Windows → Download
3. .exe dosyasını kur

### pgAdmin Bağlantı
1. pgAdmin'i aç
2. "Add New Server" tıkla
3. **General:** Name: Liquibase Test DB
4. **Connection:**
   - Host: localhost
   - Port: 5435
   - Database: testdb
   - Username: admin
   - Password: admin
5. Save tıkla

## 📚 Faydalı Linkler

- [Liquibase Dokümantasyonu](https://docs.liquibase.com/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Docker Compose Referansı](https://docs.docker.com/compose/)
- [pgAdmin Download](https://www.pgadmin.org/download/windows/)

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
