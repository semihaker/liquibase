#!/usr/bin/env sh
set -euo pipefail

COMPOSE="docker compose -f docker-compose.mysql.yml"
DEFAULTS="--defaultsFile=/liquibase/liquibase-mysql.properties"

echo "[MySQL] starting container..."
${COMPOSE} up -d mysql --remove-orphans

echo "[Liquibase] validate"
${COMPOSE} run --rm liquibase ${DEFAULTS} validate

echo "[Liquibase] update"
${COMPOSE} run --rm liquibase ${DEFAULTS} update

echo "[Liquibase] status"
${COMPOSE} run --rm liquibase ${DEFAULTS} status

echo "[SmokeTest] verify tables and counts"
${COMPOSE} exec -T mysql sh -lc "mysql -uadmin -padmin -D testdb -e \"SHOW TABLES; SELECT COUNT(*) AS user_count FROM users; SELECT COUNT(*) AS product_count FROM products;\""

echo "[Report] generate CSV"
${COMPOSE} exec -T mysql sh -lc "mysql -uadmin -padmin -D testdb -B -e \"SELECT (SELECT COUNT(*) FROM users) AS users, (SELECT COUNT(*) FROM products) AS products, (SELECT COUNT(*) FROM categories) AS categories;\" > /tmp/counts.tsv && tr '\t' ',' < /tmp/counts.tsv > /tmp/table_counts.csv"

echo "[Report] copy to workspace"
rm -rf reports && mkdir -p reports
docker cp mysql-testdb:/tmp/table_counts.csv reports/table_counts.csv

echo "[Done]"


