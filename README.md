    # Liquibase Migration Projesi (PostgreSQL + MySQL + MSSQL + Docker + Jenkins)

    Bu proje, Liquibase kullanarak PostgreSQL, MySQL ve MSSQL veritabanı değişikliklerini Docker ortamında ve Jenkins pipeline üzerinden yönetmek için tasarlanmıştır.

    ## 🎯 Proje Amacı

    - Veritabanı değişikliklerini güvenli ve otomatik bir şekilde yönetmek
    - Manuel SQL çalıştırmak yerine, versiyonlanmış değişiklikleri (migrations) Liquibase ile uygulamak
    - Docker ortamında bağımsız ve taşınabilir bir yapı kurmak
    - CI/CD süreçlerini desteklemek

    ## 🏗️ Mimari

    - **PostgreSQL 14**, **MySQL 8.0** veya **MSSQL Server 2022**: Docker container'da çalışan veritabanı
    - **Liquibase 4.25.1**: Veritabanı migration yönetimi (ayrı container)
    - **Docker Compose**: Servisleri koordine eden orkestrasyon
    - **Jenkins**: CI/CD pipeline ile otomatik migration ve raporlama
    - **PowerShell Scripts**: Windows ortamında kolay kullanım için otomatik script'ler

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

    ### 2. MySQL ile Çalıştırma
    ```bash
    # MySQL servisini başlat
    docker compose -f docker-compose.mysql.yml up -d mysql

    # Liquibase doğrulama ve migration
    docker compose -f docker-compose.mysql.yml run --rm liquibase validate
    docker compose -f docker-compose.mysql.yml run --rm liquibase update
    ```

    ### 3. MSSQL ile Çalıştırma
    ```bash
    # MSSQL servisini başlat
    docker compose -f docker-compose.mssql.yml up -d mssql

    # Liquibase doğrulama ve migration
    docker run --rm --network liquibase_default \
    -v "$(pwd)/changelog/mssql:/liquibase/changelog/mssql" \
    -v "$(pwd)/drivers:/liquibase/lib" \
    -v "$(pwd)/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" \
    liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties validate

    docker run --rm --network liquibase_default \
    -v "$(pwd)/changelog/mssql:/liquibase/changelog/mssql" \
    -v "$(pwd)/drivers:/liquibase/lib" \
    -v "$(pwd)/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" \
    liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties update
    ```

    ### 4. Yeniden Başlatma
    ```bash
    # Servisleri durdur
    docker-compose down

    # Servisleri yeniden başlat
    docker-compose up -d

    # Veya tek komutla
    docker-compose restart
    ```

    ### 5. Veritabanı Bağlantısı
    ```bash
    # PostgreSQL (localhost:5432)
    docker exec -it postgres-testdb psql -U admin -d testdb

    # MySQL (localhost:3307)
    docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb -e "SHOW TABLES;"

    # MSSQL (localhost:14333)
    docker exec -it mssql-testdb /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "Your_strong_password123" -d testdb -Q "SELECT name FROM sys.tables;"
    ```

    ### 6. Liquibase Migration'ları Çalıştır
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

    # MSSQL için eşdeğer komutlar
    docker run --rm --network liquibase_default \
    -v "$(pwd)/changelog/mssql:/liquibase/changelog/mssql" \
    -v "$(pwd)/drivers:/liquibase/lib" \
    -v "$(pwd)/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" \
    liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties update

    docker run --rm --network liquibase_default \
    -v "$(pwd)/changelog/mssql:/liquibase/changelog/mssql" \
    -v "$(pwd)/drivers:/liquibase/lib" \
    -v "$(pwd)/liquibase-mssql.properties:/liquibase/liquibase-mssql.properties" \
    liquibase/liquibase:4.25.1 --defaultsFile=/liquibase/liquibase-mssql.properties status
    ```

    ## 📁 Dosya Yapısı

    ```
    .
    ├── docker-compose.yml          # PostgreSQL Docker servisleri
    ├── docker-compose.mysql.yml    # MySQL Docker servisleri
    ├── docker-compose.mssql.yml    # MSSQL Docker servisleri
    ├── liquibase.properties       # Liquibase bağlantı ayarları (PostgreSQL)
    ├── liquibase-mysql.properties # Liquibase bağlantı ayarları (MySQL)
    ├── liquibase-mssql.properties # Liquibase bağlantı ayarları (MSSQL)
    ├── changelog/
    │   ├── changelog.sql         # Ana migration dosyası (PostgreSQL)
    │   ├── mysql/
    │   │   └── changelog.sql     # MySQL uyumlu changeset'ler
    │   └── mssql/
    │       ├── changelog.sql     # MSSQL uyumlu changeset'ler
    │       └── changelog.xml     # MSSQL XML format changelog
    ├── drivers/
    │   ├── mssql-jdbc-12.6.1.jre11.jar  # MSSQL JDBC driver
    │   └── mysql-connector-j-8.4.0.jar  # MySQL JDBC driver
    ├── jenkins/
    │   ├── Jenkinsfile-mssql      # MSSQL pipeline
    │   └── Jenkinsfile-mysql      # MySQL pipeline
    ├── scripts/
    │   ├── run-mysql-migrations.ps1  # MySQL migration script
    │   ├── start-project.ps1         # PostgreSQL başlatma script
    │   └── test-database.ps1         # Test veritabanı script
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

    ## 🖥️ PowerShell Scripts

    Windows ortamında kolay kullanım için hazırlanmış PowerShell script'leri:

    ### PostgreSQL Başlatma
    ```powershell
    # PostgreSQL servisini başlat ve migration'ları çalıştır
    .\scripts\start-project.ps1
    ```

    ### MySQL Migration
    ```powershell
    # MySQL migration'larını çalıştır
    .\scripts\run-mysql-migrations.ps1

    # Yeniden oluştur (verileri sil ve tekrar oluştur)
    .\scripts\run-mysql-migrations.ps1 -Recreate
    ```

    ### Test Veritabanı
    ```powershell
    # Test veritabanı migration'larını çalıştır
    .\scripts\test-database.ps1
    ```

    ### Script Özellikleri
    - **Otomatik Health Check**: Veritabanının hazır olmasını bekler
    - **Renkli Çıktı**: İşlem durumunu görsel olarak gösterir
    - **Hata Yönetimi**: Başarısız işlemlerde uygun hata mesajları
    - **Parametre Desteği**: `-Recreate` gibi parametrelerle esnek kullanım

    ## 🤖 Jenkins Entegrasyonu

    Jenkins job tetiklendiğinde aşağıdaki adımlar otomatik çalışır:

    - **PostgreSQL**: `jenkins/Jenkinsfile` (varsayılan docker-compose.yml)
    - **MySQL**: `jenkins/Jenkinsfile-mysql` 
    - **MSSQL**: `jenkins/Jenkinsfile-mssql`

    ### Pipeline Adımları
    - **Start DB**: İlgili veritabanı container'ı ayağa kaldırılır
    - **Validate**: Changelog doğrulanır
    - **Update**: Changeset'ler uygulanır (DDL/DML context desteği ile)
    - **Status**: Uygulama durumu raporlanır
    - **Smoke Test**: Tabloların ve temel veri kayıtlarının varlığı sorgulanır

    ### Jenkins Pipeline Parametreleri (MSSQL)
    - **packageZip**: ZIP dosyası yükleme
    - **packageUrl**: HTTP(S) URL ile paket indirme
    - **contexts**: Liquibase context'leri (örn: `ddl,dml`)
    - **runOnlyDDL**: Sadece DDL (şema) değişikliklerini çalıştır
    - **runOnlyDML**: Sadece DML (veri) değişikliklerini çalıştır
    - **dryRunUpdate**: Gerçek update yerine SQL çıktısı üret
    - **rollbackCount**: Belirtilen sayıda changeset'i geri al

    Jenkins UI'da aşama bazlı loglar üzerinden başarı/başarısızlık raporu görüntülenir.

    ### Pipeline Örnekleri
    ```groovy
    // jenkins/Jenkinsfile-mssql dosyasındaki aşamalar:
    // - Checkout Source
    // - Prepare Workspace (ZIP handling, driver download)
    // - Run Migrations Script (DDL/DML context support)
    // - Post: Cleanup

    // jenkins/Jenkinsfile-mysql dosyasındaki aşamalar:
    // - Start MySQL
    // - Validate Changelog
    // - Update Database
    // - Smoke Test: Verify Tables
    ```

    ## 🎯 DDL/DML Context Yönetimi

    Liquibase changeset'lerinde context kullanarak DDL (şema) ve DML (veri) değişikliklerini ayrı ayrı yönetebilirsiniz:

    ### Context Tanımlama
    ```sql
    -- DDL (Data Definition Language) - Şema değişiklikleri
    --changeset system:001:create-users-table context:ddl
    CREATE TABLE users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE
    );
    --rollback DROP TABLE users;

    -- DML (Data Manipulation Language) - Veri değişiklikleri  
    --changeset system:002:insert-admin-user context:dml
    INSERT INTO users (username) VALUES ('admin');
    --rollback DELETE FROM users WHERE username = 'admin';
    ```

    ### Jenkins ile Context Kullanımı
    ```bash
    # Sadece DDL değişikliklerini çalıştır
    --contexts=ddl

    # Sadece DML değişikliklerini çalıştır
    --contexts=dml

    # Hem DDL hem DML çalıştır
    --contexts=ddl,dml

    # Tüm değişiklikleri çalıştır (context belirtilmezse)
    # (hiçbir context parametresi kullanılmaz)
    ```

    ### Avantajları
    - **Ayrı Deployment**: Şema ve veri değişikliklerini ayrı ayrı deploy edebilirsiniz
    - **Güvenli Rollback**: Sadece veri veya sadece şema değişikliklerini geri alabilirsiniz
    - **Test Ortamı**: Test ortamında sadece DDL çalıştırıp DML'i atlayabilirsiniz
    - **Production Safety**: Production'da önce DDL, sonra DML çalıştırarak güvenli deployment

    ## Ne Yaptık? (Anlatır gibi)

    1) **Multi-Database Support**: Liquibase mantığıyla DDL ve DML değişikliklerini SQL formatlı changeset'lere böldük. Her changeset benzersiz ID'ye sahip ve tek seferlik uygulanıyor; rollback tanımları ile geri alınabilir kıldık. PostgreSQL, MySQL ve MSSQL desteği ekledik.

    2) **Docker Orchestration**: Docker'da veritabanlarını (PostgreSQL, MySQL, MSSQL) ayrı container'larda, Liquibase'i ise bağımsız bir container'da koşturduk. Her veritabanı için özel `liquibase-*.properties` dosyalarındaki JDBC ayarları ile DB'ye bağlanıyor.

    3) **Jenkins CI/CD**: Jenkins pipeline ile CI/CD akışı kurduk. Her veritabanı için ayrı pipeline'lar (Jenkinsfile-mysql, Jenkinsfile-mssql) ile DDL/DML context desteği, dry-run, rollback gibi gelişmiş özellikler ekledik.

    4) **PowerShell Automation**: Windows ortamında kolay kullanım için PowerShell script'leri ekledik. Otomatik health check, renkli çıktı ve hata yönetimi ile kullanıcı dostu deneyim sağladık.

    5) **Context Management**: DDL ve DML değişikliklerini ayrı ayrı yönetebilmek için Liquibase context özelliğini entegre ettik. Bu sayede şema ve veri değişikliklerini güvenli bir şekilde ayrı ayrı deploy edebiliyoruz.

    6) **Comprehensive Testing**: Smoke test'ler ile tabloların oluştuğunu, verilerin eklendiğini ve migration'ların başarılı olduğunu otomatik olarak doğruluyoruz.

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

    ### PostgreSQL
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

    ### MySQL
    ```bash
    # MySQL'e bağlan
    docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb

    # Tabloları listele
    docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb -e "SHOW TABLES;"

    # Veritabanı durumu
    docker compose -f docker-compose.mysql.yml ps

    # Logları gör
    docker compose -f docker-compose.mysql.yml logs mysql
    ```

    ### MSSQL
    ```bash
    # MSSQL'e bağlan
    docker exec -it mssql-testdb /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "Your_strong_password123" -d testdb

    # Tabloları listele
    docker exec -it mssql-testdb /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "Your_strong_password123" -d testdb -Q "SELECT name FROM sys.tables;"

    # Veritabanı durumu
    docker compose -f docker-compose.mssql.yml ps

    # Logları gör
    docker compose -f docker-compose.mssql.yml logs mssql
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

    ## 🚀 Proje Durumu ve Son Güncellemeler

    ### ✅ Tamamlanan Özellikler
    - **Multi-Database Support**: PostgreSQL, MySQL ve MSSQL desteği
    - **Docker Orchestration**: Her veritabanı için ayrı compose dosyaları
    - **Jenkins CI/CD**: Gelişmiş pipeline'lar ile DDL/DML context desteği
    - **PowerShell Scripts**: Windows ortamında otomatik migration script'leri
    - **Context Management**: DDL ve DML değişikliklerini ayrı yönetim
    - **Comprehensive Testing**: Smoke test'ler ile otomatik doğrulama
    - **Driver Management**: JDBC driver'ları otomatik indirme ve yönetim

    ### 🔧 Teknik Detaylar
    - **Liquibase Version**: 4.25.1
    - **Database Versions**: PostgreSQL 14, MySQL 8.0, MSSQL Server 2022
    - **Docker Compose**: Multi-file yapılandırma
    - **Jenkins**: Parametreli pipeline'lar ile esnek deployment
    - **PowerShell**: 7+ desteği ile modern script'ler

    ### 📈 Gelecek Planları
    - [ ] Oracle Database desteği
    - [ ] MongoDB desteği
    - [ ] Kubernetes deployment yapılandırmaları
    - [ ] Advanced rollback stratejileri
    - [ ] Database migration raporlama dashboard'u

    ### 🎯 Kullanım Senaryoları
    - **Development**: Hızlı veritabanı kurulumu ve migration testi
    - **Testing**: Otomatik test veritabanı oluşturma
    - **CI/CD**: Jenkins ile otomatik deployment
    - **Production**: Güvenli ve kontrollü veritabanı değişiklikleri

    Bu proje, modern veritabanı migration yönetimi için kapsamlı bir çözüm sunmaktadır.
