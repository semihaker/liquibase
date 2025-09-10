# Liquibase Database Migration Project

A comprehensive database migration solution using Liquibase, Docker, and Jenkins for PostgreSQL and MySQL databases.

## Overview

This project provides automated database migration management using Liquibase. It supports both PostgreSQL and MySQL databases with Docker containerization and Jenkins CI/CD integration.

## Project Structure

### Docker Configuration
- **`docker-compose.yml`** - PostgreSQL service configuration
- **`docker-compose.mysql.yml`** - MySQL service configuration

### Liquibase Configuration
- **`liquibase.properties`** - PostgreSQL connection settings
- **`liquibase-mysql.properties`** - MySQL connection settings

### Migration Files
- **`changelog/changelog.sql`** - Main PostgreSQL migration file
- **`changelog/mysql/changelog.sql`** - MySQL-specific migration file
- **`changelog/advanced-migrations.sql`** - Advanced migration examples
- **`changelog/seed-data.sql`** - Test data seeding
- **`changelog/test-database.sql`** - Test database setup

### Jenkins Pipelines
- **`Jenkinsfile`** - PostgreSQL pipeline
- **`jenkins/Jenkinsfile-mysql`** - MySQL pipeline

### PowerShell Scripts
- **`scripts/start-project.ps1`** - Start PostgreSQL project
- **`scripts/run-mysql-migrations.ps1`** - Run MySQL migrations
- **`scripts/test-database.ps1`** - Create test database
- **`scripts/clean-test-database.ps1`** - Clean test database
- **`scripts/query-test-database.ps1`** - Query test database

### JDBC Drivers
- **`drivers/postgresql-42.7.1.jar`** - PostgreSQL JDBC driver
- **`drivers/mysql-connector-j-8.4.0.jar`** - MySQL JDBC driver

## Quick Start

### PostgreSQL Setup
```powershell
# Start PostgreSQL project
.\scripts\start-project.ps1
```

### MySQL Setup
```powershell
# Start MySQL project
.\scripts\run-mysql-migrations.ps1
```

### Manual Commands
```bash
# PostgreSQL
docker-compose up -d
docker-compose run --rm liquibase update

# MySQL
docker compose -f docker-compose.mysql.yml up -d
docker compose -f docker-compose.mysql.yml run --rm liquibase update
```

## Database Connection Information

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

## Migration Management

### Basic Commands
```bash
# Check migration status
docker-compose run --rm liquibase status

# Apply new migrations
docker-compose run --rm liquibase update

# Validate changelog
docker-compose run --rm liquibase validate

# Rollback changes
docker-compose run --rm liquibase rollback --changesetId=semih:001:create-users-table
```

### Context Usage
```bash
# Run only DDL changes
docker-compose run --rm liquibase update --contexts=ddl

# Run only DML changes
docker-compose run --rm liquibase update --contexts=dml
```

## Jenkins Integration

### Pipeline Features
- Automatic health checks
- Context support (DDL/DML separation)
- Dry run capabilities
- Rollback functionality
- Smoke testing

### Jenkins Parameters
- **contexts:** Liquibase contexts (e.g., `ddl,dml`)
- **runOnlyDDL:** Run only DDL changes
- **runOnlyDML:** Run only DML changes
- **dryRunUpdate:** Generate SQL output
- **rollbackCount:** Number of changesets to rollback

## Changeset Structure

### DDL Example
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

### DML Example
```sql
--changeset semih:010:seed-users context:dml
INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('user1', 'user1@example.com');
--rollback DELETE FROM users WHERE username IN ('admin', 'user1');
```

## Testing

### Test Database
```bash
# Create test database
.\scripts\test-database.ps1

# Query test data
.\scripts\query-test-database.ps1

# Clean test database
.\scripts\clean-test-database.ps1
```

## Database Access

### PostgreSQL
```bash
# Connect to PostgreSQL
docker exec -it postgres-testdb psql -U admin -d testdb

# List tables
docker exec -it postgres-testdb psql -U admin -d testdb -c "\dt"

# View logs
docker-compose logs postgres
```

### MySQL
```bash
# Connect to MySQL
docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb

# List tables
docker compose -f docker-compose.mysql.yml exec -T mysql mysql -uadmin -padmin -D testdb -e "SHOW TABLES;"
```

## Cleanup

```bash
# Stop services
docker-compose down

# Stop services and remove volumes
docker-compose down -v

# Stop MySQL services
docker compose -f docker-compose.mysql.yml down -v
```

## Requirements

- Docker
- Docker Compose
- PowerShell 7+ (for Windows)
- Git (optional)

## Project Features

- Multi-database support (PostgreSQL & MySQL)
- Docker orchestration
- Jenkins CI/CD integration
- PowerShell automation scripts
- Context management (DDL/DML separation)
- Comprehensive testing
- Automatic driver management

## Troubleshooting

### Common Issues
1. **Port conflicts:** Ensure ports 5432 and 3307 are available
2. **Permission issues:** Run PowerShell as Administrator
3. **Docker not running:** Start Docker Desktop
4. **Network issues:** Check Docker network configuration

### Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs postgres
docker-compose logs liquibase
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.