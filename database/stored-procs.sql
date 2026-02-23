-- get all customers
CREATE OR ALTER PROCEDURE dbo.ViewAll_Customers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        customerId,
        customerName,
        customerAddress1,
        customerAddress2,
        customerCity,
        customerState,
        customerPostalCode,
        customerTelephone,
        customerContactName,
        customerEmailAddress
    FROM dbo.Customers
    ORDER BY customerName, customerId;
END
GO


-- get all products
CREATE OR ALTER PROCEDURE dbo.ViewAll_Products
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        productId,
        productName,
        productCost
    FROM dbo.Products
    ORDER BY productName, productId;
END
GO


-- get all orders
CREATE OR ALTER PROCEDURE dbo.ViewAll_Orders
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.invoiceNumber,
        o.invoiceDate,
        o.customerId,
        c.customerName,
        c.customerContactName,
        c.customerEmailAddress
    FROM dbo.Orders o
    JOIN dbo.Customers c
        ON c.customerId = o.customerId
    ORDER BY o.invoiceNumber DESC;
END
GO


-- get all orders with line item details
CREATE OR ALTER PROCEDURE dbo.ViewAll_OrderDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.invoiceNumber,
        o.invoiceDate,

        c.customerId,
        c.customerName,
        c.customerAddress1,
        c.customerAddress2,
        c.customerCity,
        c.customerState,
        c.customerPostalCode,
        c.customerTelephone,
        c.customerContactName,
        c.customerEmailAddress,

        li.lineItemId,
        li.productId,
        p.productName,
        li.quantity,
        li.productCost,
        CAST(li.quantity * li.productCost AS DECIMAL(18,2)) AS lineTotal
    FROM dbo.Orders o
    JOIN dbo.Customers c
        ON c.customerId = o.customerId
    LEFT JOIN dbo.OrderLineItems li
        ON li.invoiceNumber = o.invoiceNumber
    LEFT JOIN dbo.Products p
        ON p.productId = li.productId
    ORDER BY o.invoiceNumber DESC, p.productName, li.lineItemId;
END
GO

-- get a specific order with full details
CREATE OR ALTER PROCEDURE dbo.ViewOrder_FullDetails
    @invoiceNumber INT
AS
BEGIN
    SET NOCOUNT ON;

    -- header
    SELECT
        o.invoiceNumber,
        o.invoiceDate,
        o.customerId,
        c.customerName,
        c.customerAddress1,
        c.customerAddress2,
        c.customerCity,
        c.customerState,
        c.customerPostalCode,
        c.customerTelephone,
        c.customerContactName,
        c.customerEmailAddress
    FROM dbo.Orders o
    JOIN dbo.Customers c
        ON c.customerId = o.customerId
    WHERE o.invoiceNumber = @invoiceNumber;

    -- line items
    SELECT
        li.lineItemId,
        li.invoiceNumber,
        li.productId,
        p.productName,
        li.quantity,
        li.productCost,
        CAST(li.quantity * li.productCost AS DECIMAL(18,2)) AS lineTotal
    FROM dbo.OrderLineItems li
    JOIN dbo.Products p
        ON p.productId = li.productId
    WHERE li.invoiceNumber = @invoiceNumber
    ORDER BY p.productName, li.lineItemId;

    -- order total 
    SELECT
        o.invoiceNumber,
        CAST(SUM(li.quantity * li.productCost) AS DECIMAL(18,2)) AS orderTotal
    FROM dbo.Orders o
    LEFT JOIN dbo.OrderLineItems li
        ON li.invoiceNumber = o.invoiceNumber
    WHERE o.invoiceNumber = @invoiceNumber
    GROUP BY o.invoiceNumber;
END
GO


-- add a new order
CREATE OR ALTER PROCEDURE dbo.Create_Order
    @customerId UNIQUEIDENTIFIER,
    @productId UNIQUEIDENTIFIER,
    @quantity INT,
    @invoiceDate DATETIME2 = NULL,
    @invoiceNumber INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @productCost DECIMAL(18,2);

    SELECT @productCost = productCost
    FROM dbo.Products
    WHERE productId = @productId;

    IF @productCost IS NULL
    BEGIN
        RAISERROR('Invalid productId. No matching product found.', 16, 1);
        RETURN;
    END

    IF @quantity IS NULL OR @quantity <= 0
    BEGIN
        RAISERROR('Quantity must be greater than 0.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

            INSERT INTO dbo.Orders (invoiceDate, customerId)
            VALUES (COALESCE(@invoiceDate, SYSUTCDATETIME()), @customerId);

            SET @invoiceNumber = SCOPE_IDENTITY();

            INSERT INTO dbo.OrderLineItems (invoiceNumber, productId, quantity, productCost)
            VALUES (@invoiceNumber, @productId, @quantity, @productCost);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @severity INT = ERROR_SEVERITY();
        DECLARE @state INT = ERROR_STATE();

        RAISERROR(@msg, @severity, @state);
        RETURN;
    END CATCH
END
GO



