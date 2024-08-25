--NAME: MD ARAFAT RAHMAN
--ID: 1284616

--DROP DATABASE
DROP DATABASE WarehouseDB;
GO
--CREATE DATABASE
CREATE DATABASE WarehouseDB
ON PRIMARY
(
    NAME = N'WarehouseDB_Data_1', 
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\WarehouseDB_Data_1.mdf',
    SIZE = 25600KB, 
    MAXSIZE = 102400KB, 
    FILEGROWTH = 5%
)
LOG ON
(
    NAME = N'WarehouseDB_Log_1', 
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\WarehouseDB_Log_1.ldf', 
    SIZE = 2048KB, 
    MAXSIZE = 25600KB, 
    FILEGROWTH = 1%
);
GO

--USE DATABASE
USE WarehouseDB;
GO

-- Table 1: color
CREATE TABLE color (
    ColorId INT PRIMARY KEY,
    ColorName VARCHAR(30)
);
GO

-- Table 2: lots
CREATE TABLE lots (
    LotID INT PRIMARY KEY,
    Quantity INT
);
GO

-- Table 3: items
CREATE TABLE items (
    ItemId INT PRIMARY KEY,
    ItemName VARCHAR(50),
    ColorID INT REFERENCES color(ColorID)
);
GO

-- Table 4: Itemdetails
--DROP TABLE Itemdetails
CREATE TABLE Itemdetails (
	ItemdetailsiD INT,
    ItemId INT REFERENCES Items(ItemId),
    LotId INT REFERENCES Lots(Lotid),
    UnitPrice MONEY,
    Vat NUMERIC(8,5)
	PRIMARY KEY (ItemdetailsiD,ItemId,LotId)
);
GO

-- Create a clustered index on ItemNo in Itemdetails
--CREATE CLUSTERED INDEX IndexItemDetails ON Itemdetails(ItemNo);
--GO

-- Insert data into color table
INSERT INTO color (ColorId, ColorName)
VALUES 
(1, 'Red'),
(2, 'Blue');
GO

-- Insert data into lots table
INSERT INTO lots (LotID, Quantity)
VALUES 
(1, 6),
(2, 12);
GO

-- Insert data into items table
INSERT INTO Items (Itemid, ItemName, ColorId)
VALUES 
(1, 'Denim Shirt', 1),
(2, 'Denim Shirt', 2),
(3, 'Champ Dress', 1),
(4, 'Champ Dress', 2),
(5, 'T-Shirt', 1),
(6, 'T-Shirt', 2),
(7, 'Polo Shirt', 1),
(8, 'Polar Shirt', 2);
GO

-- Insert data into Itemdetails table
INSERT INTO Itemdetails (ItemdetailsiD,Itemid, Lotid, UnitPrice, Vat)
VALUES 
(1,1, 1, 1100, 0.15),
(2,2, 1, 1200, 0.15),
(3,3, 1, 1300, 0.15),
(4,4, 1, 1400, 0.15),
(5,5, 1, 1500, 0.15),
(6,6, 1, 1600, 0.15),
(7,7, 1, 1700, 0.15),
(8,8, 1, 1800, 0.15),
(1,1, 2, 1150, 0.15),
(2,2, 2, 1250, 0.15),
(3,3, 2, 1350, 0.15),
(4,4, 2, 1450, 0.15),
(5,5, 2, 1550, 0.15),
(6,6, 2, 1650, 0.15),
(7,7, 2, 1750, 0.15),
(8,8, 2, 1850, 0.15);
GO

-- Select all data from the tables
SELECT * FROM color;
SELECT * FROM lots;
SELECT * FROM items;
SELECT * FROM Itemdetails;
GO

-- Function Creation
-- Scalar Function
CREATE FUNCTION fn_sclarLOT()
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM items;
    RETURN @Count;
END;
GO

-- Test the scalar function
SELECT dbo.fn_sclarLOT();
GO

-- Table-Valued Function
CREATE FUNCTION Fn_TBItem()
RETURNS TABLE
AS
RETURN 
(
    SELECT * FROM items
);
GO

-- Test the table-valued function
SELECT * FROM dbo.Fn_TBItem();
GO

-- Multi-Statement Table-Valued Function
CREATE FUNCTION fn_mulItem()
RETURNS @Table TABLE
(
    ItemNo INT,
    EXItemNo INT,
    ItemName VARCHAR(50)
)
AS
BEGIN
    INSERT INTO @Table (ItemNo, EXItemNo, ItemName)
    SELECT ItemID, ItemID + 100, ItemName
    FROM items;

    RETURN;
END;
GO

-- Test the multi-statement table-valued function
SELECT * FROM dbo.fn_mulItem();
GO


drop table ItemdetailsLog

---Log table
CREATE TABLE ItemdetailsLog(
ItemdetailsLogId int identity(1,1),
Itemdetails varchar(50),
DesItemdetails varchar(50)
);
GO
drop trigger tr_instead
-- Trigger Creation
CREATE TRIGGER tr_instead
ON Itemdetails
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @ItemNo INT;
    SELECT @ItemNo = DELETED.ItemID 
	FROM DELETED;

    IF @ItemNo = 1
    BEGIN
        RAISERROR('Cannot delete Item 1', 16, 1);
        ROLLBACK 
        INSERT INTO ItemdetailsLog VALUES(@ItemNo, 'Invalid');
    END
    ELSE
    BEGIN
        DELETE FROM Itemdetails WHERE ItemID = @ItemNo;
        INSERT INTO ItemdetailsLog VALUES(@ItemNo, 'DELETED');
    END
END;
GO


--
delete Itemdetails where ItemID=1;

select * from ItemdetailsLog;
go

delete Itemdetails where ItemID=2;

select * from ItemdetailsLog;
go
-- View Creation
-- View with Encryption
CREATE VIEW vw_enccryption
WITH ENCRYPTION
AS
SELECT ItemId, ItemName
FROM items;
GO

-- Test the encrypted view
SELECT * FROM vw_enccryption;
GO

-- View with Schema Binding
CREATE VIEW vw_sche
WITH SCHEMABINDING
AS
SELECT ItemId, ItemName
FROM dbo.items;
GO

-- Test the schema-bound view
SELECT * FROM vw_sche;
GO

-- View with Encryption and Schema Binding Together
CREATE VIEW vw_togather
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT ItemId, ItemName
FROM dbo.items;
GO

-- Test the view with both encryption and schema binding
SELECT * FROM vw_togather;
GO