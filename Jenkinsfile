pipeline {
    agent any
    
    parameters {
        choice(
            name: 'DATABASE_TYPE',
            choices: ['postgresql', 'mysql'],
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
                checkout scm
                echo "Repository checkout tamamlandı"
            }
        }
        
        stage('Prepare Workspace') {
            steps {
                script {
                    echo "Workspace hazırlanıyor..."
                    sh '''
                        mkdir -p drivers
                        echo "Drivers klasörü oluşturuldu"
                        ls -la drivers/
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
                            docker compose --project-name $COMPOSE_PROJECT_NAME up -d postgres
                            
                            # PostgreSQL'in hazır olmasını bekle
                            echo "PostgreSQL hazır olması bekleniyor..."
                            timeout 60 sh -c 'until docker compose --project-name $COMPOSE_PROJECT_NAME exec -T postgres pg_isready -U admin -d testdb; do sleep 2; done'
                            
                            # Liquibase migration'larını çalıştır
                            echo "Liquibase migration'ları çalıştırılıyor..."
                            docker compose --project-name $COMPOSE_PROJECT_NAME run --rm liquibase \
                                --url=jdbc:postgresql://postgres:5432/testdb \
                                --username=admin \
                                --password=admin \
                                --driver=org.postgresql.Driver \
                                --classpath=/liquibase/lib \
                                --changeLogFile=changelog/changelog.sql \
                                ${DRY_RUN == "true" ? "updateSQL" : "update"}
                            
                            # Durum kontrolü
                            echo "Migration durumu:"
                            docker compose --project-name $COMPOSE_PROJECT_NAME run --rm liquibase \
                                --url=jdbc:postgresql://postgres:5432/testdb \
                                --username=admin \
                                --password=admin \
                                --driver=org.postgresql.Driver \
                                --classpath=/liquibase/lib \
                                --changeLogFile=changelog/changelog.sql \
                                status
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
                            docker run --rm --network liquibase_default \
                                -v $(pwd)/changelog/mysql:/liquibase/changelog \
                                -v $(pwd)/drivers:/liquibase/lib \
                                liquibase/liquibase:4.25.1 \
                                --url=jdbc:mysql://mysql:3306/testdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC \
                                --username=admin \
                                --password=admin \
                                --driver=com.mysql.cj.jdbc.Driver \
                                --classpath=/liquibase/lib \
                                --changeLogFile=changelog/changelog.sql \
                                ${DRY_RUN == "true" ? "updateSQL" : "update"}
                            
                            # Durum kontrolü
                            echo "Migration durumu:"
                            docker run --rm --network liquibase_default \
                                -v $(pwd)/changelog/mysql:/liquibase/changelog \
                                -v $(pwd)/drivers:/liquibase/lib \
                                liquibase/liquibase:4.25.1 \
                                --url=jdbc:mysql://mysql:3306/testdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC \
                                --username=admin \
                                --password=admin \
                                --driver=com.mysql.cj.jdbc.Driver \
                                --classpath=/liquibase/lib \
                                --changeLogFile=changelog/changelog.sql \
                                status
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
                    export COMPOSE_PROJECT_NAME=liquibase
                    docker compose --project-name $COMPOSE_PROJECT_NAME down
                    docker compose --project-name $COMPOSE_PROJECT_NAME -f docker-compose.mysql.yml down
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
