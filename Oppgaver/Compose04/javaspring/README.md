# Learniken Compose04 API - Build and Debug Guide

## Prerequisites

- Docker and Docker Compose installed
- Maven 3.9+ (for local builds)
- Java 17+
- IDE with debugger support (IntelliJ IDEA, VS Code, Eclipse)

## Project Structure

```
javaspring/
├── src/
│   ├── main/
│   │   ├── java/com/learniken/
│   │   │   ├── Compose04ApiApplication.java     # Spring Boot entry point
│   │   │   ├── controller/CustomerController.java
│   │   │   ├── service/CustomerService.java
│   │   │   ├── entity/Customer.java
│   │   │   └── repository/CustomerRepository.java
│   │   └── resources/
│   │       └── application.properties             # Database config
│   └── test/
├── pom.xml                                        # Maven dependencies
├── target/                                        # Build output (auto-generated)
└── Dockerfile                                     # Container image (in javaspring/)
```

## Building the Application

### Local Build with Maven

```bash
cd javaspring
mvn clean package -DskipTests
```

This generates:
- `target/compose04-api-1.0.0.jar` - the executable JAR
- `target/dependency/` - extracted dependencies

### Docker Build

The Docker image expects a pre-built JAR:

```bash
# From the root directory
docker compose down
docker compose up -d --build
```

## Running with Docker Compose

### Start All Services (PostgreSQL + API)

```bash
# From the root directory
docker compose up -d
```

Services:
- **PostgreSQL**: `localhost:5432` (user: `postgres`, password: `password`, db: `mydb`)
- **Spring Boot API**: `http://localhost:8088/api/customers`

### Stop Services

```bash
docker compose down
```

### Stop and Remove Everything (Including Volumes)

```bash
docker compose down -v
```

## Debugging

### Remote Debugging Setup

The API container exposes a debug port on `5005`. Configure your IDE:

#### IntelliJ IDEA

1. **Run** → **Edit Configurations**
2. Click **+** → **Remote JVM Debug**
3. Set:
   - Name: `Compose04 Remote Debug`
   - Host: `localhost`
   - Port: `5005`
4. Click **Debug** (or **Shift+F9**)

#### VS Code

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Compose04 Remote Debug",
      "type": "java",
      "name": "Debug (Attach)",
      "request": "attach",
      "hostName": "localhost",
      "port": 5005,
      "preLaunchTask": "build"
    }
  ]
}
```

Then press **F5** to attach the debugger.

#### Eclipse

1. **Run** → **Debug Configurations**
2. Right-click **Remote Java Application** → **New**
3. Set:
   - Connection Type: `Standard (Socket Attach)`
   - Host: `localhost`
   - Port: `5005`
4. Click **Debug**

### Setting Breakpoints

Once the debugger is attached:
1. Open a source file in `javaspring/src/main/java/com/learniken/`
2. Click on the line number to set a breakpoint
3. Make an API request to trigger the breakpoint

Example:
```bash
curl http://localhost:8088/api/customers
```

The debugger will pause at your breakpoint. Use Step Over (F10), Step Into (F11), and evaluate expressions as needed.

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/customers` | List all customers |
| GET | `/api/customers/{id}` | Get customer by ID |
| POST | `/api/customers` | Create new customer |
| PUT | `/api/customers/{id}` | Update customer |
| DELETE | `/api/customers/{id}` | Delete customer |

### Example Requests

**Get all customers:**
```bash
curl http://localhost:8088/api/customers
```

**Create a customer:**
```bash
curl -X POST http://localhost:8088/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Doe",
    "email": "jane.doe@example.com",
    "phone": "555-1234",
    "city": "Boston"
  }'
```

**Get customer by ID:**
```bash
curl http://localhost:8088/api/customers/1
```

**Update customer:**
```bash
curl -X PUT http://localhost:8088/api/customers/1 \
  -H "Content-Type: application/json" \
  -d '{
    "city": "New York"
  }'
```

**Delete customer:**
```bash
curl -X DELETE http://localhost:8088/api/customers/1
```

## Development Workflow

1. **Build locally** with Maven:
   ```bash
   cd javaspring
   mvn clean package -DskipTests
   ```

2. **Start containers**:
   ```bash
   docker compose up -d
   ```

3. **Attach debugger** (see IDE-specific steps above)

4. **Edit source code**, set breakpoints, and test via API calls

5. **For code changes**, rebuild and restart:
   ```bash
   cd javaspring
   mvn clean package -DskipTests
   docker compose restart api
   ```

## Viewing Logs

```bash
# API logs
docker logs learniken_compose04_api -f

# PostgreSQL logs
docker logs learniken_compose04_postgres -f

# Compose logs
docker compose logs -f
```

## Database Access

Connect to PostgreSQL directly:

```bash
# Using psql (if installed)
psql -h localhost -p 5432 -U postgres -d mydb

# Using docker exec
docker exec -it learniken_compose04_postgres psql -U postgres -d mydb

# View customer table
SELECT * FROM customer;
```

## Troubleshooting

**API won't start:**
- Check PostgreSQL is healthy: `docker compose ps`
- View logs: `docker logs learniken_compose04_api`
- Ensure ports 8088 and 5005 are not in use

**Debugger won't connect:**
- Verify API is running: `docker compose ps`
- Check port 5005 is accessible: `netstat -an | grep 5005`
- Restart the API: `docker compose restart api`

**Database connection issues:**
- Verify PostgreSQL is healthy: `docker compose logs learniken_compose04_postgres`
- Check connection string in `application.properties`

**Build fails locally:**
- Ensure Java 17+ is installed: `java -version`
- Clean Maven cache: `mvn clean`
- Update Maven: `mvn -v` (should be 3.9+)
