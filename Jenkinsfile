pipeline {
    agent any
    
    parameters {
        choice(
            name: 'DATABASE_TYPE',
            choices: ['postgresql', 'mysql', 'mssql', 'oracle'],
            description: 'Hangi veritabanı için migration çalıştırılacak?'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: 'Sadece SQL oluştur, çalıştırma (dry run)'
        )
        string(
            name: 'CONTEXTS',
            defaultValue: '',
            description: 'Context filtreleme (örn: ddl,dml) - boş bırakırsan hepsini çalıştırır'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Git repo yoksa bu kısmı kaldır
                // checkout scm
                echo "Repository checkout tamamlandı"
            }
        }
        
        stage('Prepare Workspace') {
            steps {
                script {
                    echo "Workspace hazırlanıyor..."
                    sh '''
                        mkdir -p drivers
                        mkdir -p changelog
                        echo "Klasörler oluşturuldu"
                        
                        # Changelog dosyasını oluştur
                        cat > changelog/changelog.sql << 'EOF'
--liquibase formatted sql

--changeset admin:001:create-users-table context:ddl
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--rollback DROP TABLE users;

--changeset admin:002:create-categories-table context:ddl
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--rollback DROP TABLE categories;

--changeset admin:003:create-products-table context:ddl
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
--rollback DROP TABLE products;

--changeset admin:004:add-indexes context:ddl
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_users_email ON users(email);
--rollback DROP INDEX idx_products_category_id; DROP INDEX idx_products_name; DROP INDEX idx_users_email;

--changeset admin:010:seed-categories context:dml
INSERT INTO categories (name, description) VALUES 
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Fashion and apparel'),
('Books', 'Books and literature');
--rollback DELETE FROM categories WHERE name IN ('Electronics', 'Clothing', 'Books');

--changeset admin:011:seed-products context:dml
INSERT INTO products (name, description, price, category_id) VALUES
('Laptop', 'High-performance laptop computer', 999.99, 1),
('Smartphone', 'Latest model smartphone', 699.99, 1),
('T-Shirt', 'Cotton t-shirt', 19.99, 2),
('Jeans', 'Blue denim jeans', 49.99, 2),
('Programming Book', 'Learn to code', 29.99, 3),
('Garden Tools', 'Complete garden tool set', 79.99, 4);
--rollback DELETE FROM products WHERE name IN ('Laptop', 'Smartphone', 'T-Shirt', 'Jeans', 'Programming Book', 'Garden Tools');

--changeset admin:012:seed-users context:dml
INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('user1', 'user1@example.com'),
('user2', 'user2@example.com');
--rollback DELETE FROM users WHERE username IN ('admin', 'user1', 'user2');
EOF
                        
                        echo "Changelog dosyası oluşturuldu!"
                        ls -la changelog/
                    '''
                }
            }
        }
        
        stage('Run Migrations') {
            steps {
                script {
                    if (params.DATABASE_TYPE == 'postgresql') {
                        echo "PostgreSQL migration'ları çalıştırılıyor..."
                        sh '''
                            export COMPOSE_PROJECT_NAME=liquibase
                            
                            # PostgreSQL container'ını başlat
                            echo "PostgreSQL container başlatılıyor..."
                            docker run -d --name postgres-testdb -e POSTGRES_DB=testdb -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -p 5432:5432 postgres:15
                            
                            # PostgreSQL'in hazır olmasını bekle
                            echo "PostgreSQL hazır olması bekleniyor..."
                            timeout 60 sh -c 'until docker exec postgres-testdb pg_isready -U admin -d testdb; do sleep 2; done'
                            
                            # Liquibase migration'larını çalıştır
                            echo "Liquibase migration'ları çalıştırılıyor..."
                            if [ "$DRY_RUN" = "true" ]; then
                                docker run --rm --network host -v $(pwd)/changelog:/liquibase/changelog -v $(pwd)/drivers:/liquibase/lib liquibase/liquibase:4.25.1 --url=jdbc:postgresql://localhost:5432/testdb --username=admin --password=admin --driver=org.postgresql.Driver --classpath=/liquibase/lib --changeLogFile=/liquibase/changelog/changelog.sql updateSQL
                            else
                                docker run --rm --network host -v $(pwd)/changelog:/liquibase/changelog -v $(pwd)/drivers:/liquibase/lib liquibase/liquibase:4.25.1 --url=jdbc:postgresql://localhost:5432/testdb --username=admin --password=admin --driver=org.postgresql.Driver --classpath=/liquibase/lib --changeLogFile=/liquibase/changelog/changelog.sql update
                            fi
                            
                            # Durum kontrolü
                            echo "Migration durumu:"
                            docker run --rm --network host -v $(pwd)/changelog:/liquibase/changelog -v $(pwd)/drivers:/liquibase/lib liquibase/liquibase:4.25.1 --url=jdbc:postgresql://localhost:5432/testdb --username=admin --password=admin --driver=org.postgresql.Driver --classpath=/liquibase/lib --changeLogFile=/liquibase/changelog/changelog.sql status
                        '''
                    } else if (params.DATABASE_TYPE == 'mysql') {
                        echo "MySQL migration'ları çalıştırılıyor..."
                        sh '''
                            export COMPOSE_PROJECT_NAME=liquibase
                            
                            # MySQL container'ını başlat
                            echo "MySQL container başlatılıyor..."
                            docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mysql.yml up -d mysql
                            
                            # MySQL'in hazır olmasını bekle
                            echo "MySQL hazır olması bekleniyor..."
                            timeout 60 sh -c 'until docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mysql.yml exec -T mysql mysqladmin ping -h localhost -uadmin -padmin --silent; do sleep 2; done'
                            
                            # MySQL driver'ını indir
                            echo "MySQL driver indiriliyor..."
                            curl -L https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar -o drivers/mysql-connector-j-8.4.0.jar
                            
                            # Liquibase migration'larını çalıştır
                            echo "Liquibase migration'ları çalıştırılıyor..."
                            if [ "$DRY_RUN" = "true" ]; then
                                docker run --rm --network liquibase_default -v $(pwd)/changelog/mysql:/liquibase/changelog -v $(pwd)/drivers:/liquibase/lib liquibase/liquibase:4.25.1 --url=jdbc:mysql://mysql:3306/testdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC --username=admin --password=admin --driver=com.mysql.cj.jdbc.Driver --classpath=/liquibase/lib --changeLogFile=/liquibase/changelog/changelog.sql updateSQL
                            else
                                docker run --rm --network liquibase_default -v $(pwd)/changelog/mysql:/liquibase/changelog -v $(pwd)/drivers:/liquibase/lib liquibase/liquibase:4.25.1 --url=jdbc:mysql://mysql:3306/testdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC --username=admin --password=admin --driver=com.mysql.cj.jdbc.Driver --classpath=/liquibase/lib --changeLogFile=/liquibase/changelog/changelog.sql update
                            fi
                            
                            # Durum kontrolü
                            echo "Migration durumu:"
                            docker run --rm --network liquibase_default -v $(pwd)/changelog/mysql:/liquibase/changelog -v $(pwd)/drivers:/liquibase/lib liquibase/liquibase:4.25.1 --url=jdbc:mysql://mysql:3306/testdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC --username=admin --password=admin --driver=com.mysql.cj.jdbc.Driver --classpath=/liquibase/lib --changeLogFile=/liquibase/changelog/changelog.sql status
                        '''
                    } else if (params.DATABASE_TYPE == 'mssql') {
                        echo "MSSQL migration'ları çalıştırılıyor..."
                        sh '''
                            export COMPOSE_PROJECT_NAME=liquibase
                            
                            # MSSQL container'ını başlat
                            echo "MSSQL container başlatılıyor..."
                            docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mssql.yml up -d mssql
                            
                            # MSSQL'in hazır olmasını bekle
                            echo "MSSQL hazır olması bekleniyor..."
                            timeout 120 sh -c 'until docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mssql.yml exec -T mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Admin123! -C -Q "SELECT 1" > /dev/null 2>&1; do sleep 5; done'
                            
                            # Liquibase migration'larını çalıştır
                            echo "Liquibase migration'ları çalıştırılıyor..."
                            if [ "$DRY_RUN" = "true" ]; then
                                docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mssql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mssql.properties updateSQL
                            else
                                docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mssql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mssql.properties update
                            fi
                            
                            # Durum kontrolü
                            echo "Migration durumu:"
                            docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mssql.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-mssql.properties status
                        '''
                    } else if (params.DATABASE_TYPE == 'oracle') {
                        echo "Oracle migration'ları çalıştırılıyor..."
                        sh '''
                            export COMPOSE_PROJECT_NAME=liquibase
                            
                            # Oracle container'ını başlat
                            echo "Oracle container başlatılıyor..."
                            docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.oracle.yml up -d oracle
                            
                            # Oracle'ın hazır olmasını bekle
                            echo "Oracle hazır olması bekleniyor..."
                            timeout 180 sh -c 'until docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.oracle.yml exec -T oracle sqlplus -L system/admin@localhost:1521/XE -S -c "SELECT 1 FROM DUAL;" > /dev/null 2>&1; do sleep 10; done'
                            
                            # Liquibase migration'larını çalıştır
                            echo "Liquibase migration'ları çalıştırılıyor..."
                            if [ "$DRY_RUN" = "true" ]; then
                                docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.oracle.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-oracle.properties updateSQL
                            else
                                docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.oracle.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-oracle.properties update
                            fi
                            
                            # Durum kontrolü
                            echo "Migration durumu:"
                            docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.oracle.yml run --rm liquibase --defaultsFile=/liquibase/liquibase-oracle.properties status
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Cleanup yapılıyor..."
                sh '''
                    docker stop postgres-testdb mysql-testdb mssql-testdb oracle-testdb 2>/dev/null || true
                    docker rm postgres-testdb mysql-testdb mssql-testdb oracle-testdb 2>/dev/null || true
                '''
            }
        }
        success {
            echo "Migration başarıyla tamamlandı!"
        }
        failure {
            echo "Migration başarısız!"
        }
    }
}
