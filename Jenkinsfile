pipeline {
    agent any
    
    parameters {
        file(name: 'packageZip', description: 'Upload ZIP containing docker-compose.yml, changelog/, drivers/')
        string(name: 'packageUrl', defaultValue: '', description: 'Optional: HTTP(S) URL to ZIP if upload fails')
        string(name: 'contexts', defaultValue: '', description: 'Optional: Liquibase contexts (e.g. ddl, dml, prod)')
        booleanParam(name: 'runOnlyDDL', defaultValue: false, description: 'Sadece DDL (şema) çalıştır')
        booleanParam(name: 'runOnlyDML', defaultValue: false, description: 'Sadece DML (veri) çalıştır')
        booleanParam(name: 'dryRunUpdate', defaultValue: false, description: 'Gerçek update yerine SQL çıktısı üret (updateSQL)')
        string(name: 'rollbackCount', defaultValue: '', description: 'Rollback sayısı (boş ise yapma)')
    }
    
    stages {
        stage('Checkout Source') {
            steps {
                // Explicit checkout to ensure full repo is available in workspace
                git branch: 'main', url: 'https://github.com/semihaker/liquibase.git'
            }
        }
        
        stage('Prepare Workspace') {
            steps {
                sh '''
                    #!/usr/bin/env bash
                    set -eu
                    if [ -n "${BASH:-}" ]; then set -o pipefail; fi
                    set -x
                    cd "$WORKSPACE"
                    echo "Preparing workspace..."
                    echo "Listing workspace after checkout:"
                    ls -la || true
                    
                    # Fallback: If compose file is still missing, clone repo contents explicitly
                    if [ ! -f docker-compose.yml ]; then
                      echo "docker-compose.yml not found. Cloning repository contents into workspace..."
                      command -v git >/dev/null 2>&1 || { echo "git not found"; exit 1; }
                      TMPDIR=$(mktemp -d)
                      git clone --depth=1 --branch main https://github.com/semihaker/liquibase.git "$TMPDIR"
                      cp -R "$TMPDIR"/* . || true
                      rm -rf "$TMPDIR"
                      echo "Workspace after explicit clone:" && ls -la || true
                    fi
                    ls -la || true
                    
                    # If compose file is missing, try to find and unzip a package in workspace
                    if [ ! -f docker-compose.yml ]; then
                        CANDIDATES="${packageZip:-} $WORKSPACE/${packageZip:-} $(ls -1 *.zip 2>/dev/null | head -n 1)"
                        ZIP_FILE=""
                        for f in $CANDIDATES; do
                            if [ -n "$f" ] && [ -f "$f" ]; then ZIP_FILE="$f"; break; fi
                        done
                        if [ -z "${ZIP_FILE:-}" ] && [ -d "${WORKSPACE}@tmp/fileParameters" ]; then
                            ZIP_FILE=$(find "${WORKSPACE}@tmp/fileParameters" -maxdepth 1 -type f -name "*.zip" | head -n 1 || true)
                        fi
                        if [ -z "${ZIP_FILE:-}" ] && [ -d "${WORKSPACE}@tmp" ]; then
                            ZIP_FILE=$(find "${WORKSPACE}@tmp" -maxdepth 3 -type f -name "*.zip" | head -n 1 || true)
                        fi
                        if [ -z "${ZIP_FILE:-}" ] && [ -n "${packageUrl:-}" ]; then
                            echo "Downloading ZIP from packageUrl: $packageUrl"
                            if ! command -v curl >/dev/null 2>&1 && command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y curl || true; fi
                            if command -v curl >/dev/null 2>&1; then
                                curl -L "$packageUrl" -o package.zip
                                ZIP_FILE="package.zip"
                            elif command -v wget >/dev/null 2>&1; then
                                wget -O package.zip "$packageUrl"
                                ZIP_FILE="package.zip"
                            else
                                echo "Neither curl nor wget available to download packageUrl" >&2
                            fi
                        fi
                        if [ -n "${ZIP_FILE:-}" ] && [ -f "$ZIP_FILE" ]; then
                            command -v unzip >/dev/null 2>&1 || (command -v apt-get >/dev/null 2>&1 && sudo apt-get update && sudo apt-get install -y unzip) || true
                            echo "Found ZIP at: $ZIP_FILE"
                            unzip -o "${ZIP_FILE}" || { echo "Failed to unzip $ZIP_FILE"; exit 1; }
                        else
                            echo "docker-compose.yml yok ve zip bulunamadı. Lütfen job'a bir zip yükleyin (packageZip) veya packageUrl ile bir adres verin, ya da SCM kullanın." >&2
                            exit 1
                        fi
                    fi
                '''
            }
        }
        
        stage('Run Migrations Script') {
            steps {
                sh '''
                    #!/usr/bin/env bash
                    set -eu
                    if [ -n "${BASH:-}" ]; then set -o pipefail; fi
                    set -x
                    export COMPOSE_PROJECT_NAME=liquibase
                    cd "$WORKSPACE"
                    
                    echo "Starting PostgreSQL container..."
                    docker-compose up -d postgres --remove-orphans
                    
                    echo "Waiting for PostgreSQL to be ready..."
                    timeout 180 sh -c 'until docker-compose exec -T postgres pg_isready -U admin -d testdb; do sleep 2; done'
                    
                    # Prepare contexts from string param
                    CTX_OPT=""
                    if [ -n "${contexts:-}" ]; then
                      CTX_OPT=" --contexts=${contexts}"
                      echo "Using contexts (string): ${contexts}"
                    fi
                    
                    # Override with boolean params if provided (mutual preference: if both true -> run all)
                    if [ "${runOnlyDDL:-false}" = "true" ] && [ "${runOnlyDML:-false}" != "true" ]; then
                      CTX_OPT=" --contexts=ddl"
                      echo "Using contexts (boolean): ddl"
                    elif [ "${runOnlyDML:-false}" = "true" ] && [ "${runOnlyDDL:-false}" != "true" ]; then
                      CTX_OPT=" --contexts=dml"
                      echo "Using contexts (boolean): dml"
                    elif [ "${runOnlyDDL:-false}" = "true" ] && [ "${runOnlyDML:-false}" = "true" ]; then
                      CTX_OPT=""
                      echo "Both runOnlyDDL and runOnlyDML are true -> run all (no contexts filter)"
                    elif [ -z "${contexts:-}" ]; then
                      echo "No contexts selected -> run all"
                    fi
                    
                    echo "Validating Liquibase changelog..."
                    docker-compose run --rm liquibase validate${CTX_OPT}
                    
                    # Rollback mi, dry-run mi, normal update mi?
                    if [ -n "${rollbackCount:-}" ]; then
                      echo "Rolling back ${rollbackCount} changesets..."
                      docker-compose run --rm liquibase rollbackCount ${rollbackCount}${CTX_OPT}
                    elif [ "${dryRunUpdate:-false}" = "true" ]; then
                      echo "Generating update SQL (dry run)..."
                      mkdir -p reports
                      docker-compose run --rm liquibase updateSQL${CTX_OPT} | tee reports/postgres_update.sql
                    else
                      echo "Applying Liquibase migrations..."
                      docker-compose run --rm liquibase update${CTX_OPT}
                    fi
                    
                    echo "Checking Liquibase status..."
                    docker-compose run --rm liquibase status${CTX_OPT}
                    
                    echo "Running Smoke Test: Verify tables and data counts..."
                    docker-compose exec -T postgres psql -U admin -d testdb -c "\\dt; SELECT COUNT(*) as user_count FROM users; SELECT COUNT(*) as product_count FROM products;"
                    
                    echo "Migration and reporting completed."
                '''
            }
        }
    }
    
    post {
        always {
            sh 'docker-compose down -v || true'
            archiveArtifacts artifacts: 'reports/**', fingerprint: true
        }
    }
}
