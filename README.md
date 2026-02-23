# Ace Invoice API

## Database and API Setup

### Prerequisites

- Microsoft SQL Server
- SQL Server Management Studio
- Local SQL Server instance

### 1) Create the database
In SSMS, create a database named `AceInvoice`.

### 2) Run schema + seed script
Run the provided `init.sql` against the `AceInvoice` database. This creates the tables and inserts seed data.

### 3) Run stored procedures script
Run the provided `stored-procs.sql` against the `AceInvoice` database. This creates the stored procedures used by the API.

### 4) Enable TCP/IP and set port 1433 (required for Node connectivity)
SSMS can connect using shared memory, but Node connects over TCP. Please make sure SQL Server is reachable over TCP:

1. Open SQL Server Configuration Manager
2. Go to SQL Server Network Configuration -> Protocols for "your instance"
3. Enable TCP/IP
4. TCP/IP Properties -> IP Addresses -> IPAll
   - Clear `TCP Dynamic Ports`
   - Set `TCP Port` to `1433`
5. Restart the SQL Server service

### 5) Create a .env file in the project root and paste:
```
PORT=5001
API_KEY=key12345

DB_SERVER=localhost
DB_PORT=1433
DB_DATABASE=AceInvoice
DB_USER=sa
DB_PASSWORD=yourpasswordhere
DB_ENCRYPT=false
DB_TRUST_CERT=true
```

### 6) Ensure SQL Server is configured for Mixed Mode:

1. In SSMS -> right click server -> properties 
2. Click Security
3. Select SQL Server and Windows Auth mode
4. Restart SQL Server
5. Enable/configure sa login in SSMS:
    ```
    ALTER LOGIN sa ENABLE;
    ALTER LOGIN sa WITH PASSWORD = 'yourpasswordhere';
    ```

### 7) Run the API

Navigate to the project root then run: 
```
npm install
npm start 
```
Should show: "API listening on port 5001" and can now be tested.

## Assumptions and Design Decisions

- All data access is implemented through stored procedures.
- SQL Authentication is used for simplicity and consistent local setup.
- SQL Server must be reachable over TCP (port 1433) for Node connectivity.
- `POST /api/order/new` creates an order with a single line item per request.