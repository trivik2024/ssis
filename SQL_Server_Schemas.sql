
-- ============================================
-- PrintTech Manufacturing Supply Chain Database
-- SQL Server Database Schemas
-- ============================================

CREATE DATABASE PrintTech_SupplyChain;
GO

USE PrintTech_SupplyChain;
GO

-- ============================================
-- MASTER DATA TABLES
-- ============================================

-- Suppliers Table
CREATE TABLE dbo.Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode NVARCHAR(20) UNIQUE NOT NULL,
    CompanyName NVARCHAR(255) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    StateProvince NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    Email NVARCHAR(100),
    Website NVARCHAR(255),
    TaxID NVARCHAR(50),
    PaymentTerms NVARCHAR(50),
    CreditLimit DECIMAL(18,2),
    SupplierType NVARCHAR(50), -- Raw Material, Component, Service
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Products Table (Components and Raw Materials)
CREATE TABLE dbo.Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode NVARCHAR(50) UNIQUE NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    ProductCategory NVARCHAR(100), -- Raw Material, Component, Finished Goods
    ProductType NVARCHAR(100), -- Ink Cartridge, Toner, Print Head, etc.
    UnitOfMeasure NVARCHAR(20),
    StandardCost DECIMAL(18,4),
    ListPrice DECIMAL(18,4),
    Weight DECIMAL(10,4),
    WeightUOM NVARCHAR(10),
    Dimensions NVARCHAR(100),
    Color NVARCHAR(50),
    ManufacturerPartNumber NVARCHAR(100),
    SupplierID INT,
    ReorderLevel INT,
    SafetyStockLevel INT,
    LeadTimeDays INT,
    ShelfLifeDays INT,
    QualityGrade NVARCHAR(20),
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers(SupplierID)
);

-- Customers Table
CREATE TABLE dbo.Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode NVARCHAR(20) UNIQUE NOT NULL,
    CompanyName NVARCHAR(255) NOT NULL,
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(50),
    BillingAddress NVARCHAR(255),
    ShippingAddress NVARCHAR(255),
    City NVARCHAR(100),
    StateProvince NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    Email NVARCHAR(100),
    TaxID NVARCHAR(50),
    CreditLimit DECIMAL(18,2),
    PaymentTerms NVARCHAR(50),
    CustomerType NVARCHAR(50), -- Retail, Wholesale, Corporate
    SalesRepID INT,
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Warehouses/Locations Table
CREATE TABLE dbo.Warehouses (
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseCode NVARCHAR(20) UNIQUE NOT NULL,
    WarehouseName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(100),
    StateProvince NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    ManagerName NVARCHAR(100),
    Capacity DECIMAL(18,2),
    CapacityUOM NVARCHAR(20),
    WarehouseType NVARCHAR(50), -- Raw Materials, Components, Finished Goods
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Employees Table
CREATE TABLE dbo.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeCode NVARCHAR(20) UNIQUE NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50),
    JobTitle NVARCHAR(100),
    HireDate DATE,
    Email NVARCHAR(100),
    Phone NVARCHAR(30),
    ManagerID INT,
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ManagerID) REFERENCES dbo.Employees(EmployeeID)
);

-- ============================================
-- TRANSACTIONAL TABLES
-- ============================================

-- Purchase Orders Header
CREATE TABLE dbo.Purchase_Orders (
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderNumber NVARCHAR(50) UNIQUE NOT NULL,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL,
    RequiredDate DATE,
    PromisedDate DATE,
    ShippedDate DATE,
    ReceivedDate DATE,
    BuyerID INT,
    WarehouseID INT,
    TotalAmount DECIMAL(18,2),
    Tax DECIMAL(18,2),
    Freight DECIMAL(18,2),
    Currency NVARCHAR(10) DEFAULT 'USD',
    PaymentTerms NVARCHAR(50),
    Status NVARCHAR(50) DEFAULT 'Draft', -- Draft, Sent, Confirmed, Shipped, Received, Closed
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers(SupplierID),
    FOREIGN KEY (BuyerID) REFERENCES dbo.Employees(EmployeeID),
    FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID)
);

-- Purchase Order Details
CREATE TABLE dbo.Purchase_Order_Details (
    PurchaseOrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderID INT NOT NULL,
    LineNumber INT NOT NULL,
    ProductID INT NOT NULL,
    OrderedQuantity DECIMAL(18,4) NOT NULL,
    ReceivedQuantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) NOT NULL,
    LineTotal AS (OrderedQuantity * UnitPrice),
    RequiredDate DATE,
    Status NVARCHAR(50) DEFAULT 'Open', -- Open, Partially Received, Received, Cancelled
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (PurchaseOrderID) REFERENCES dbo.Purchase_Orders(PurchaseOrderID),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);

-- Sales Orders Header
CREATE TABLE dbo.Sales_Orders (
    SalesOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderNumber NVARCHAR(50) UNIQUE NOT NULL,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    RequiredDate DATE,
    ShippedDate DATE,
    SalesPersonID INT,
    WarehouseID INT,
    TotalAmount DECIMAL(18,2),
    Tax DECIMAL(18,2),
    Freight DECIMAL(18,2),
    Currency NVARCHAR(10) DEFAULT 'USD',
    PaymentTerms NVARCHAR(50),
    ShippingMethod NVARCHAR(50),
    Status NVARCHAR(50) DEFAULT 'Open', -- Open, Processing, Shipped, Delivered, Closed, Cancelled
    Priority NVARCHAR(20) DEFAULT 'Normal', -- Low, Normal, High, Urgent
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    FOREIGN KEY (SalesPersonID) REFERENCES dbo.Employees(EmployeeID),
    FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID)
);

-- Sales Order Details
CREATE TABLE dbo.Sales_Order_Details (
    SalesOrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID INT NOT NULL,
    LineNumber INT NOT NULL,
    ProductID INT NOT NULL,
    OrderedQuantity DECIMAL(18,4) NOT NULL,
    ShippedQuantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) NOT NULL,
    UnitPriceDiscount DECIMAL(5,4) DEFAULT 0,
    LineTotal AS (OrderedQuantity * UnitPrice * (1 - UnitPriceDiscount)),
    RequiredDate DATE,
    Status NVARCHAR(50) DEFAULT 'Open', -- Open, Allocated, Picked, Shipped, Delivered
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SalesOrderID) REFERENCES dbo.Sales_Orders(SalesOrderID),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);

-- Inventory Transactions (All movements in/out)
CREATE TABLE dbo.Inventory_Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionNumber NVARCHAR(50) UNIQUE NOT NULL,
    TransactionDate DATETIME2 NOT NULL,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL, -- Receipt, Issue, Transfer, Adjustment, Return
    ReferenceType NVARCHAR(50), -- PO, SO, WO, ADJ, etc.
    ReferenceID INT,
    Quantity DECIMAL(18,4) NOT NULL, -- Positive for receipts, Negative for issues
    UnitCost DECIMAL(18,4),
    TotalCost AS (Quantity * UnitCost),
    BatchLotNumber NVARCHAR(50),
    ExpirationDate DATE,
    ReasonCode NVARCHAR(50),
    EmployeeID INT,
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID),
    FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID)
);

-- Production Orders
CREATE TABLE dbo.Production_Orders (
    ProductionOrderID INT IDENTITY(1,1) PRIMARY KEY,
    ProductionOrderNumber NVARCHAR(50) UNIQUE NOT NULL,
    ProductID INT NOT NULL, -- Finished Good being produced
    OrderDate DATE NOT NULL,
    StartDate DATE,
    DueDate DATE NOT NULL,
    CompletedDate DATE,
    QuantityOrdered DECIMAL(18,4) NOT NULL,
    QuantityProduced DECIMAL(18,4) DEFAULT 0,
    QuantityRejected DECIMAL(18,4) DEFAULT 0,
    WarehouseID INT,
    Status NVARCHAR(50) DEFAULT 'Planned', -- Planned, Released, In Production, Completed, Closed
    Priority NVARCHAR(20) DEFAULT 'Normal',
    SupervisorID INT,
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID),
    FOREIGN KEY (SupervisorID) REFERENCES dbo.Employees(EmployeeID)
);

-- ============================================
-- OPERATIONAL TABLES
-- ============================================

-- Current Inventory Levels (Snapshot)
CREATE TABLE dbo.Inventory_Levels (
    InventoryLevelID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    QuantityOnHand DECIMAL(18,4) NOT NULL DEFAULT 0,
    QuantityAllocated DECIMAL(18,4) NOT NULL DEFAULT 0,
    QuantityAvailable AS (QuantityOnHand - QuantityAllocated),
    QuantityOnOrder DECIMAL(18,4) NOT NULL DEFAULT 0,
    ReorderPoint DECIMAL(18,4),
    MaximumLevel DECIMAL(18,4),
    AverageCost DECIMAL(18,4),
    LastCostUpdate DATETIME2,
    LastMovementDate DATETIME2,
    LastCountDate DATETIME2,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID),
    UNIQUE (ProductID, WarehouseID)
);

-- Quality Control Tests
CREATE TABLE dbo.Quality_Control_Tests (
    QCTestID INT IDENTITY(1,1) PRIMARY KEY,
    TestNumber NVARCHAR(50) UNIQUE NOT NULL,
    TestDate DATETIME2 NOT NULL,
    ProductID INT NOT NULL,
    BatchLotNumber NVARCHAR(50),
    TestType NVARCHAR(100) NOT NULL, -- Incoming, In-Process, Final
    TestDescription NVARCHAR(255),
    TestSpecification NVARCHAR(255),
    TestResult NVARCHAR(100),
    ActualValue NVARCHAR(100),
    PassFail NVARCHAR(10), -- Pass, Fail
    InspectorID INT,
    QuantityTested DECIMAL(18,4),
    QuantityPassed DECIMAL(18,4),
    QuantityFailed DECIMAL(18,4),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID),
    FOREIGN KEY (InspectorID) REFERENCES dbo.Employees(EmployeeID)
);

-- Shipments
CREATE TABLE dbo.Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentNumber NVARCHAR(50) UNIQUE NOT NULL,
    SalesOrderID INT,
    CarrierID INT, -- Reference to Suppliers table (carriers)
    ShipDate DATE NOT NULL,
    DeliveryDate DATE,
    TrackingNumber NVARCHAR(100),
    FreightAmount DECIMAL(18,2),
    Weight DECIMAL(10,4),
    WeightUOM NVARCHAR(10),
    Dimensions NVARCHAR(100),
    PackageCount INT,
    Status NVARCHAR(50) DEFAULT 'Scheduled', -- Scheduled, Shipped, In Transit, Delivered, Exception
    WarehouseID INT,
    ShippingAddress NVARCHAR(MAX),
    SpecialInstructions NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SalesOrderID) REFERENCES dbo.Sales_Orders(SalesOrderID),
    FOREIGN KEY (CarrierID) REFERENCES dbo.Suppliers(SupplierID),
    FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID)
);

-- Supplier Performance Tracking
CREATE TABLE dbo.Supplier_Performance (
    PerformanceID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    EvaluationPeriod NVARCHAR(20), -- Monthly, Quarterly, Yearly
    EvaluationDate DATE NOT NULL,
    OnTimeDeliveryRate DECIMAL(5,2), -- Percentage
    QualityRating DECIMAL(5,2), -- 1-10 scale
    PriceCompetitiveness DECIMAL(5,2), -- 1-10 scale
    CommunicationRating DECIMAL(5,2), -- 1-10 scale
    OverallRating DECIMAL(5,2), -- 1-10 scale
    TotalOrders INT,
    OnTimeOrders INT,
    QualityIssues INT,
    DeliveryIssues INT,
    PriceVariances DECIMAL(18,2),
    Notes NVARCHAR(MAX),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers(SupplierID)
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Products Indexes
CREATE INDEX IX_Products_ProductCode ON dbo.Products(ProductCode);
CREATE INDEX IX_Products_ProductCategory ON dbo.Products(ProductCategory);
CREATE INDEX IX_Products_SupplierID ON dbo.Products(SupplierID);

-- Purchase Orders Indexes
CREATE INDEX IX_PurchaseOrders_SupplierID ON dbo.Purchase_Orders(SupplierID);
CREATE INDEX IX_PurchaseOrders_OrderDate ON dbo.Purchase_Orders(OrderDate);
CREATE INDEX IX_PurchaseOrders_Status ON dbo.Purchase_Orders(Status);

-- Sales Orders Indexes  
CREATE INDEX IX_SalesOrders_CustomerID ON dbo.Sales_Orders(CustomerID);
CREATE INDEX IX_SalesOrders_OrderDate ON dbo.Sales_Orders(OrderDate);
CREATE INDEX IX_SalesOrders_Status ON dbo.Sales_Orders(Status);

-- Inventory Transactions Indexes
CREATE INDEX IX_InventoryTrans_ProductID ON dbo.Inventory_Transactions(ProductID);
CREATE INDEX IX_InventoryTrans_WarehouseID ON dbo.Inventory_Transactions(WarehouseID);
CREATE INDEX IX_InventoryTrans_TransactionDate ON dbo.Inventory_Transactions(TransactionDate);
CREATE INDEX IX_InventoryTrans_TransactionType ON dbo.Inventory_Transactions(TransactionType);

-- Inventory Levels Indexes
CREATE INDEX IX_InventoryLevels_ProductID ON dbo.Inventory_Levels(ProductID);
CREATE INDEX IX_InventoryLevels_WarehouseID ON dbo.Inventory_Levels(WarehouseID);

