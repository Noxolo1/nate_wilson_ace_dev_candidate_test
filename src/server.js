require("dotenv").config();

const express = require("express");
const cors = require("cors");
const { sql, getPool } = require("./db");
const { requireApiKey } = require("./auth");

const app = express();
app.use(cors());
app.use(express.json());

// GET /api/public/hello (no auth)
app.get("/api/public/hello", (req, res) => {
  res.status(200).json({ message: "hello" });
});

// everything else under /api requires auth
app.use("/api", requireApiKey);

// GET /api/customer/viewall (auth)
app.get("/api/customer/viewall", async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute("dbo.ViewAll_Customers");
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /api/product/viewall (auth)
app.get("/api/product/viewall", async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute("dbo.ViewAll_Products");
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /api/order/viewall (auth)
app.get("/api/order/viewall", async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute("dbo.ViewAll_Orders");
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /api/order/vieworderdetail (auth)
app.get("/api/order/vieworderdetail", async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute("dbo.ViewAll_OrderDetails");
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  }
});

// GET /api/order/details/{invoiceNumber} (auth)
app.get("/api/order/details/:invoiceNumber", async (req, res) => {
  try {
    const invoiceNumber = Number.parseInt(req.params.invoiceNumber, 10);
    if (!Number.isInteger(invoiceNumber)) {
      return res.status(400).json({ error: "Invalid invoiceNumber" });
    }

    const pool = await getPool();
    const result = await pool
      .request()
      .input("invoiceNumber", sql.Int, invoiceNumber)
      .execute("dbo.ViewOrder_FullDetails");

    const headerRows = result.recordsets[0] || [];
    const lineItems = result.recordsets[1] || [];
    const totalsRows = result.recordsets[2] || [];

    if (headerRows.length === 0) {
      return res.status(404).json({ error: "Not found" });
    }

    return res.json({
      order: headerRows[0],
      lineItems,
      totals: totalsRows[0] || null,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
});

// POST /api/order/new (auth)
app.post("/api/order/new", async (req, res) => {
  try {
    const { customerId, productId, quantity, invoiceDate } = req.body;

    if (!customerId || typeof customerId !== "string") {
      return res.status(400).json({ error: "Invalid customerId" });
    }
    if (!productId || typeof productId !== "string") {
      return res.status(400).json({ error: "Invalid productId" });
    }
    if (!Number.isInteger(quantity) || quantity <= 0) {
      return res.status(400).json({ error: "Invalid quantity" });
    }

    const pool = await getPool();

    const request = pool
      .request()
      .input("customerId", sql.UniqueIdentifier, customerId)
      .input("productId", sql.UniqueIdentifier, productId)
      .input("quantity", sql.Int, quantity)
      .output("invoiceNumber", sql.Int);

    if (invoiceDate) {
      request.input("invoiceDate", sql.DateTime2, invoiceDate);
    }

    const createResult = await request.execute("dbo.Create_Order");
    const newInvoiceNumber = createResult.output.invoiceNumber;

    // return full details using existing proc
    const details = await pool
      .request()
      .input("invoiceNumber", sql.Int, newInvoiceNumber)
      .execute("dbo.ViewOrder_FullDetails");

    return res.status(201).json({
      invoiceNumber: newInvoiceNumber,
      order: (details.recordsets[0] || [])[0] || null,
      lineItems: details.recordsets[1] || [],
      totals: (details.recordsets[2] || [])[0] || null,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
});

const port = Number.parseInt(process.env.PORT || "5001", 10);
app.listen(port, () => console.log(`API listening on port ${port}`));