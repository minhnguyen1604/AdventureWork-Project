CREATE FUNCTION dbo.RemoveNumericCharacters (@InputString VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @OutputString VARCHAR(MAX) = ''
    DECLARE @Length INT = LEN(@InputString)
    DECLARE @Index INT = 1
    DECLARE @Character CHAR(1)

    WHILE @Index <= @Length
    BEGIN
        SET @Character = SUBSTRING(@InputString, @Index, 1)
        IF @Character NOT LIKE '[0-9]'
            SET @OutputString = @OutputString + @Character
        SET @Index = @Index + 1
    END

    RETURN @OutputString
END

USE AdventureWorksFinalASM;
-- Fact_SalesOrderDetail
-- Create the Fact_SalesOrderDetail table in the new database
CREATE TABLE Fact_SalesOrderDetail (
SalesOrderDetailKey INT PRIMARY KEY,
SalesOrderKey INT NOT NULL,
ProductKey INT NOT NULL,
SpecialOfferKey INT NOT NULL,
SalesOrderStatusKey INT NOT NULL,
SalesOnlineOrderFlag INT NOT NULL,
SalesOrderAccountNumber NVARCHAR(16) NOT NULL,
SalesOrderCustomerKey INT NOT NULL,
SalesPersonKey INT NOT NULL,
TerritoryKey INT NOT NULL,
BillToAddressKey INT NOT NULL,
ShipToAddressKey INT NOT NULL,
ShipMethodKey INT NOT NULL,
SalesOrderDetailModifiedDateKey INT NOT NULL,
SalesOrderDateKey INT NOT NULL,
SalesOrderDueDateKey INT NOT NULL,
SalesOrderShipDateKey INT NOT NULL,
SalesOrderModifiedDateKey INT NOT NULL,
OrderQty INT NOT NULL,
UnitPrice DECIMAL NOT NULL,
UnitPriceDiscount DECIMAL NOT NULL,
LineTotal DECIMAL NOT NULL,
SalesOrderSubTotal DECIMAL NOT NULL,
SalesOrderTaxAmount DECIMAL NOT NULL,
SalesOrderFreightAmount DECIMAL NOT NULL,
SalesOrderTotalDueAmount DECIMAL NOT NULL
);

-- Insert data into the Fact_SalesOrderDetail table from the existing database
INSERT INTO Fact_SalesOrderDetail
SELECT
SD.SalesOrderDetailID,
SH.SalesOrderID,
SD.ProductID,
SD.SpecialOfferID,
SH.Status,
SH.OnlineOrderFlag,
SH.AccountNumber,
SH.CustomerID,
ISNULL(SH.SalesPersonID, 0),
SH.TerritoryID,
SH.BillToAddressID,
SH.ShipToAddressID,
SH.ShipMethodID,
CONVERT(INT, CONVERT(VARCHAR(8), SD.ModifiedDate, 112)),
CONVERT(INT, CONVERT(VARCHAR(8), SH.OrderDate, 112)),
CONVERT(INT, CONVERT(VARCHAR(8), SH.DueDate, 112)),
CONVERT(INT, CONVERT(VARCHAR(8), SH.ShipDate, 112)),
CONVERT(INT, CONVERT(VARCHAR(8), SH.ModifiedDate, 112)),
SD.OrderQty,
SD.UnitPrice,
SD.UnitPriceDiscount,
SD.LineTotal,
SH.SubTotal,
SH.TaxAmt,
SH.Freight,
SH.TotalDue
FROM [AdventureWorks2022].Sales.SalesOrderDetail SD
LEFT JOIN [AdventureWorks2022].Sales.SalesOrderHeader SH ON SD.SalesOrderID = SH.SalesOrderID;

-- Dim_Product
CREATE TABLE Dim_Product (
ProductKey INT PRIMARY KEY,
ProductName NVARCHAR(60) NOT NULL,
ProductModel NVARCHAR(60) NOT NULL,
ProductCategory NVARCHAR(60) NOT NULL,
ProductSubCategory NVARCHAR(60) NOT NULL,
ProductNumber NVARCHAR(60) NOT NULL,
MakeFlag BIT NOT NULL,
FinishedGoodsFlag BIT NOT NULL,
Color NVARCHAR(50)NOT NULL,
Size NVARCHAR(50) NOT NULL,
SizeUnitMeasure NVARCHAR(50) NOT NULL,
[Weight] DECIMAL NOT NULL,
WeightUnitMeasure NVARCHAR(50) NOT NULL,
ProductLine NVARCHAR(50) NOT NULL,
ProductClass NVARCHAR(50) NOT NULL,
ProductStyle NVARCHAR(50) NOT NULL,
SellStartDateKey INT NOT NULL,
SellEndDateKey INT NOT NULL,
DiscontinuedDateKey INT NOT NULL,
ModifiedDateKey INT NOT NULL
);
-- Insert data into the Dim_Product table from the existing database
INSERT INTO Dim_Product
SELECT
P.ProductID AS ProductKey,
P.[Name] AS ProductName,
ISNULL(PM.[Name],dbo.[RemoveNumericCharacters](P.[Name])) AS ProductModel,
ISNULL(PC.[Name],'N/A') AS ProductCategory,
ISNULL(PSC.[Name],'N/A') AS ProductSubCategory,
P.ProductNumber AS ProductNumber,
P.MakeFlag,
P.FinishedGoodsFlag,
ISNULL(P.Color,'N/A') AS Color,
ISNULL(P.Size,'N/A') AS Size,
ISNULL(UM_Size.[Name],'N/A') AS SizeUnitMeasure,
ISNULL(P.[Weight],0) AS [Weight],
ISNULL(UM_Weight.[Name],'N/A') AS WeightUnitMeasure,
ISNULL(CAST(P.ProductLine AS NCHAR(3)),'N/A') ProductLine,
ISNULL(CAST(P.Class AS NCHAR(3)),'N/A') Class,
ISNULL(CAST(P.Style AS NCHAR(3)),'N/A') Style,
CONVERT(INT, CONVERT(VARCHAR(8), SellStartDate, 112)) AS SellStartDateKey,
ISNULL(CONVERT(INT, CONVERT(VARCHAR(8), SellEndDate, 112)),'99991231') AS SellEndDateKey,
ISNULL(CONVERT(INT, CONVERT(VARCHAR(8), DiscontinuedDate, 112)),'99991231') AS DiscontinuedDateKey,
CONVERT(INT, CONVERT(VARCHAR(8), P.ModifiedDate, 112)) AS ModifiedDateKey

FROM [AdventureWorks2022].Production.Product P
LEFT JOIN [AdventureWorks2022].Production.ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
LEFT JOIN [AdventureWorks2022].Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
LEFT JOIN [AdventureWorks2022].Production.ProductModel PM ON P.ProductModelID = PM.ProductModelID
LEFT JOIN [AdventureWorks2022].Production.UnitMeasure UM_Size ON P.SizeUnitMeasureCode = UM_Size.UnitMeasureCode
LEFT JOIN [AdventureWorks2022].Production.UnitMeasure UM_Weight ON P.WeightUnitMeasureCode = UM_Weight.UnitMeasureCode

-- Dim_SalesTerritory
CREATE TABLE Dim_SalesTerritory (
TerritoryKey INT PRIMARY KEY NOT NULL,
Territory NVARCHAR(50) NOT NULL,
CountryRegionCode NVARCHAR(50) NOT NULL,
TerritoryGroup NVARCHAR(50) NOT NULL,
ModifiedDateKey INT NOT NULL
)

-- Insert data into the Dim_SalesTerritory table from the existing database
INSERT INTO Dim_SalesTerritory
SELECT
TerritoryID AS TerritoryKey,
Name AS Territory,
CountryRegionCode,
[Group] AS TerritoryGroup,
CONVERT(INT, CONVERT(VARCHAR(8), ModifiedDate, 112)) AS ModifiedDateKey
FROM [AdventureWorks2022].Sales.SalesTerritory

-- Dim_Address
CREATE TABLE Dim_Address (
AddressKey INT PRIMARY KEY NOT NULL,
AddressLine1 NVARCHAR(50) NOT NULL,
AddressLine2 NVARCHAR(50) NOT NULL,
City NVARCHAR(50) NOT NULL,
PostalCode NVARCHAR(50) NOT NULL,
SpatialLocation GEOGRAPHY NOT NULL,
StateProvinceID INT NOT NULL,
AddressType NVARCHAR(50) NOT NULL,
ModifiedDateKey INT NOT NULL
)

-- Insert data into the Dim_Address table from the existing database
INSERT INTO Dim_Address
Select 
PA.AddressID AS AddressKey,
PA.AddressLine1,
ISNULL(PA.AddressLine2, 'N/A') AS AddressLine2,
PA.City,
PA.PostalCode,
PA.SpatialLocation,
PA.StateProvinceID,
ISNULL(PAT.[Name], 'N/A') AS AddressType,
CONVERT(INT, CONVERT(VARCHAR(8), PA.ModifiedDate, 112)) AS ModifiedDateKey
FROM [AdventureWorks2022].Person.Address PA
LEFT JOIN [AdventureWorks2022].Person.AddressType PAT ON PA.AddressID = PAT.AddressTypeID

-- Dim_ShipMethod
CREATE TABLE Dim_ShipMethod (
ShipMethodKey INT PRIMARY KEY NOT NULL,
ShipmentMethod NVARCHAR(50) NOT NULL
)

-- Insert data into the Dim_ShipMethod table from the existing database
INSERT INTO Dim_ShipMethod
SELECT 
ShipMethodID AS ShipMethodKey,
Name AS ShipmentMethod
FROM [AdventureWorks2022].[Purchasing].[ShipMethod]

-- Dim_SpecialOffer
CREATE TABLE Dim_SpecialOffer (
SpecialOfferKey INT PRIMARY KEY NOT NULL,
[Description] NVARCHAR(50) NOT NULL,
Type NVARCHAR(50) NOT NULL,
Category NVARCHAR(50) NOT NULL,
StartDateKey INT NOT NULL,
EndDateKey INT NOT NULL,
)

-- Insert data into the Dim_SpecialOffer table from the existing database
INSERT INTO Dim_SpecialOffer
SELECT 
SpecialOfferID AS SpecialOfferKey,
[Description],
Type,
Category,
CONVERT(INT, CONVERT(VARCHAR(8), StartDate, 112)) AS StartDateKey,
CONVERT(INT, CONVERT(VARCHAR(8), EndDate, 112)) AS EndDateKey
FROM [AdventureWorks2022].[Sales].[SpecialOffer]

-- Dim_Customer
CREATE TABLE Dim_Customer (
CustomerKey INT PRIMARY KEY NOT NULL,
StoreName NVARCHAR(50) NOT NULL,
Territory NVARCHAR(50) NOT NULL,
CountryRegionCode NVARCHAR(50) NOT NULL,
TerritoryGroup NVARCHAR(50) NOT NULL,
ModifiedDateKey INT NOT NULL
)

-- Insert data into the Dim_Customer table from the existing database
INSERT INTO Dim_Customer
SELECT
C.CustomerID AS CustomerKey,
ISNULL(S.Name, 'N/A') AS StoreName,
ST.Name AS Territory,
ST.CountryRegionCode,
ST.[Group] AS TerritoryGroup,
CONVERT(INT, CONVERT(VARCHAR(8), C.ModifiedDate, 112)) AS ModifiedDateKey
FROM [AdventureWorks2022].Sales.Customer C
LEFT JOIN [AdventureWorks2022].Sales.Store S ON C.StoreID = S.BusinessEntityID
LEFT JOIN [AdventureWorks2022].Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID

-- Dim_SalesPerson
CREATE TABLE Dim_SalesPerson (
SalesPersonKey INT PRIMARY KEY NOT NULL,
[Full Name] NVARCHAR(50) NOT NULL,
Territory NVARCHAR(50) NOT NULL,
CountryRegionCode NVARCHAR(50) NOT NULL,
TerritoryGroup NVARCHAR(50) NOT NULL
)

-- Insert data into the Dim_SalesPerson table from the existing database
INSERT INTO Dim_SalesPerson
SELECT
PP.BusinessEntityID AS SalesPersonKey,
PP.FirstName + ISNULL(' ' + PP.MiddleName,'') + ' ' + PP.LastName AS 'Full Name',
ISNULL(ST.Name,'N/A') AS Territory,
ISNULL(ST.CountryRegionCode,'N/A') AS CountryRegionCode,
ISNULL(ST.[Group],'N/A') AS TerritoryGroup

FROM [AdventureWorks2022].Person.Person PP
LEFT JOIN [AdventureWorks2022].Sales.SalesTerritory ST ON st.TerritoryID = PP.BusinessEntityID
LEFT JOIN [AdventureWorks2022].Sales.SalesPerson SP ON pp.BusinessEntityID = SP.BusinessEntityID;

INSERT INTO Dim_SalesPerson VALUES (0, 'Unknown', 'Unknown', 'Unknown','Unknown')
-- Dim_Date
CREATE TABLE Dim_Date (
DateKey INT PRIMARY KEY NOT NULL,
[Date] DATE NOT NULL
)

-- Insert data into the Dim_Date table from the existing database
INSERT INTO Dim_Date
SELECT
DateKey,
FullDateAlternateKey AS 'Date'
FROM [AdventureWorksDW2022].[dbo].[DimDate]

-- Create Foreign Key 
ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_ProductKey_FK
FOREIGN KEY (ProductKey) REFERENCES Dim_Product (ProductKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_TerritoryKey_FK
FOREIGN KEY (TerritoryKey) REFERENCES Dim_SalesTerritory (TerritoryKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_BillToAddressKey_FK
FOREIGN KEY (BillToAddressKey) REFERENCES Dim_Address (AddressKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_ShipToAddressKey_FK
FOREIGN KEY (ShipToAddressKey) REFERENCES Dim_Address (AddressKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_ShipMethodKey_FK
FOREIGN KEY (ShipMethodKey) REFERENCES Dim_ShipMethod (ShipMethodKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SpecialOfferKey_FK
FOREIGN KEY (SpecialOfferKey) REFERENCES Dim_SpecialOffer (SpecialOfferKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesOrderCustomerKey_FK
FOREIGN KEY (SalesOrderCustomerKey) REFERENCES Dim_Customer (CustomerKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesPersonKey_FK
FOREIGN KEY (SalesPersonKey) REFERENCES Dim_SalesPerson (SalesPersonKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesOrderDetailModifiedDateKey_FK
FOREIGN KEY (SalesOrderDetailModifiedDateKey) REFERENCES Dim_Date (DateKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesOrderDateKey_FK
FOREIGN KEY (SalesOrderDateKey) REFERENCES Dim_Date (DateKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesOrderDueDateKey_FK
FOREIGN KEY (SalesOrderDueDateKey) REFERENCES Dim_Date (DateKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesOrderShipDateKey_FK
FOREIGN KEY (SalesOrderShipDateKey) REFERENCES Dim_Date (DateKey) 

ALTER TABLE Fact_SalesOrderDetail ADD CONSTRAINT Fact_SalesOrderDetail_SalesOrderModifiedDateKey_FK
FOREIGN KEY (SalesOrderModifiedDateKey) REFERENCES Dim_Date (DateKey) 



