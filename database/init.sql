-- customers table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers')
BEGIN 
	CREATE TABLE Customers (
		customerId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
		customerName NVARCHAR(200) NOT NULL,
		customerAddress1 NVARCHAR(200) NOT NULL,
		customerAddress2 NVARCHAR(200) NULL,
		customerCity NVARCHAR(100) NOT NULL,
		customerState NVARCHAR(50) NOT NULL,
		customerPostalCode NVARCHAR(20) NOT NULL,
		customerTelephone NVARCHAR(50) NOT NULL,
		customerContactName NVARCHAR(200) NOT NULL,
		customerEmailAddress NVARCHAR(255) NOT NULL,

		CONSTRAINT PK_Customers PRIMARY KEY (customerId),
		CONSTRAINT UQ_Customers_Email UNIQUE (customerEmailAddress)
	);
END
GO


-- products table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN 
	CREATE TABLE Products (
		productId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
		productName NVARCHAR(200) NOT NULL,
		productCost DECIMAL(18,2) NOT NULL,

		CONSTRAINT PK_Products PRIMARY KEY (productId),
		CONSTRAINT CK_Products_Cost CHECK (productCost >= 0)
	);
END
GO


-- orders table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders')
BEGIN 
	CREATE TABLE Orders (
		invoiceNumber INT IDENTITY(1,1) NOT NULL,
		invoiceDate DATETIME2 NOT NULL,
		customerId UNIQUEIDENTIFIER NOT NULL,

		CONSTRAINT PK_Orders PRIMARY KEY (invoiceNumber),
		CONSTRAINT FK_Orders_Customers FOREIGN KEY (customerId)REFERENCES dbo.Customers(customerId)
	);
END
GO


-- orderlineitems table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderLineItems')
BEGIN 
	CREATE TABLE OrderLineItems (
		lineItemId UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
		invoiceNumber INT NOT NULL,
		productId UNIQUEIDENTIFIER NOT NULL,
		quantity INT NOT NULL,
		productCost DECIMAL(18,2) NOT NULL, 

		CONSTRAINT PK_LineItems PRIMARY KEY (lineItemId),
		CONSTRAINT CK_LineItems_Qty CHECK (quantity > 0),
		CONSTRAINT CK_LineItems_Cost CHECK (productCost >= 0),

		CONSTRAINT FK_LineItems_Orders FOREIGN KEY (invoiceNumber) REFERENCES dbo.Orders(invoiceNumber),

		CONSTRAINT FK_LineItems_Products FOREIGN KEY (productId) REFERENCES dbo.Products(productId)
	);
END
GO



-- seed customers 
IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE customerId = 'aa5fd07a-05d6-460f-b8e3-6a09142f9d71')
BEGIN
  INSERT INTO dbo.Customers (
    customerId, customerName, customerAddress1, customerAddress2, customerCity, customerState,
    customerPostalCode, customerTelephone, customerContactName, customerEmailAddress
  )
  VALUES (
    'aa5fd07a-05d6-460f-b8e3-6a09142f9d71',
    'Smith, LLC',
    '505 Central Avenue',
    'Suite 100',
    'San Diego',
    'CA',
    '90383',
    '619-483-0987',
    'Jane Smith',
    'email@jane.com'
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE customerId = '15907644-3f44-448b-b64e-a949c529fa0b')
BEGIN
  INSERT INTO dbo.Customers (
    customerId, customerName, customerAddress1, customerAddress2, customerCity, customerState,
    customerPostalCode, customerTelephone, customerContactName, customerEmailAddress
  )
  VALUES (
    '15907644-3f44-448b-b64e-a949c529fa0b',
    'Doe, Inc',
    '123 Main Street',
    NULL,
    'Los Angeles',
    'CA',
    '90010',
    '310-555-1212',
    'John Doe',
    'email@doe.com'
  );
END
GO


-- seed products
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE productId = '26812d43-cee0-4413-9a1b-0b2eabf7e92c')
BEGIN
  INSERT INTO dbo.Products (productId, productName, productCost)
  VALUES ('26812d43-cee0-4413-9a1b-0b2eabf7e92c', 'Thingie', 2.00);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE productId = '3c85f645-ce57-43a8-b192-7f46f8bbc273')
BEGIN
  INSERT INTO dbo.Products (productId, productName, productCost)
  VALUES ('3c85f645-ce57-43a8-b192-7f46f8bbc273', 'Gadget', 5.15);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE productId = 'a102e2b7-30d6-4ab6-b92b-8570a7e1659c')
BEGIN
  INSERT INTO dbo.Products (productId, productName, productCost)
  VALUES ('a102e2b7-30d6-4ab6-b92b-8570a7e1659c', 'Gizmo', 1.00);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE productId = '9e3ef8ce-a6fd-4c9b-ac5d-c3cb471e1e27')
BEGIN
  INSERT INTO dbo.Products (productId, productName, productCost)
  VALUES ('9e3ef8ce-a6fd-4c9b-ac5d-c3cb471e1e27', 'Widget', 2.50);
END
GO

-- seed order (invoiceNumber = 5)
IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE invoiceNumber = 5)
BEGIN
  SET IDENTITY_INSERT dbo.Orders ON;

  INSERT INTO dbo.Orders (invoiceNumber, invoiceDate, customerId)
  VALUES (
    5,
    '2024-12-20T14:30:00',
    'aa5fd07a-05d6-460f-b8e3-6a09142f9d71'
  );

  SET IDENTITY_INSERT dbo.Orders OFF;
END
GO


-- seed orderlineitems
IF NOT EXISTS (SELECT 1 FROM dbo.OrderLineItems WHERE lineItemId = '9d91681f-0971-4170-bba4-1617e53e7e8c')
BEGIN
  INSERT INTO dbo.OrderLineItems (lineItemId, invoiceNumber, productId, quantity, productCost)
  VALUES (
    '9d91681f-0971-4170-bba4-1617e53e7e8c',
    5,
    '3c85f645-ce57-43a8-b192-7f46f8bbc273',
    5,
    5.15
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.OrderLineItems WHERE lineItemId = '91c75521-b7c5-45bb-b0c6-fdca3a89ecd9')
BEGIN
  INSERT INTO dbo.OrderLineItems (lineItemId, invoiceNumber, productId, quantity, productCost)
  VALUES (
    '91c75521-b7c5-45bb-b0c6-fdca3a89ecd9',
    5,
    '26812d43-cee0-4413-9a1b-0b2eabf7e92c',
    2,
    2.00
  );
END
GO