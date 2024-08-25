
use master;
GO
--DROP DATABASE
IF EXISTS(SELECT NAME FROM SYS.DATABASES WHERE NAME='WarehouseDB')
BEGIN
DROP DATABASE WarehouseDB
END
GO
CREATE DATABASE WarehouseDB
ON PRIMARY(
NAME='Warehose_Data_1',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Warehose_Data_1.mdf',
SIZE=25MB,
MAXSIZE=100MB,
FILEGROWTH=5%
)
LOG ON(
NAME='Warehose_Log_1',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Warehose_Log_1.ldf',
SIZE=2MB,
MAXSIZE=50MB,
FILEGROWTH=1%
)
GO
--USE DATABASE
USE WarehouseDB;
GO
--CREATE TABLE COLOR
CREATE TABLE Colors
(
ColorId INT PRIMARY KEY ,
ColorName VARCHAR(20)
);
GO
--CREATE TABLE ITEM
CREATE TABLE Item
(
ItemId INT PRIMARY KEY ,
ItemName VARCHAR(20),
ColorId INT REFERENCES Colors(ColorId)
);
GO
--CREATE TABLE LOT
CREATE TABLE Lot
(
lotId INT PRIMARY KEY ,
lotName VARCHAR(10),
Quantity INT
);
GO
--CRATE TABLE ITEMDETAIL
CREATE TABLE ItemDetail
(
ItemDetailId INT PRIMARY KEY,
ColorId INT REFERENCES Colors(ColorId),
ItemId INT REFERENCES Item(ItemId),
lotId INT REFERENCES Lot(lotId),
UnitPrice MONEY,
VAT NUMERIC(8,5)
);
GO
--INSERT COLOR
INSERT INTO colorS
VALUES
(1,'Red'),
(2,'Blue');
GO

--INSERT ITEM
INSERT INTO Item
VALUES
(1,'Denim Shirt',1),
(2,'Denim Shirt',2),
(3,'Camp Shirt',1),
(4,'Camp Shirt',2),
(5,'T-Shirt',1),
(6,'T-Shirt',2),
(7,'polo Shirt',1),
(8,'polo Shirt',2);
GO

--INSERT LOT
SELECT *
FROM ItemDetail
INSERT INTO Lot
VALUES 
(1,'Item 1',6),
(2,'Item 2',12);
GO
--insert relation
INSERT INTO ItemDetail
VALUES
(1,1,1,1,1100,0.15),
(2,2,2,1,1200,0.15),
(3,1,3,1,1300,0.15),
(4,2,4,1,1400,0.15),
(5,1,5,1,1500,0.15),
(6,2,6,1,1600,0.15),
(7,1,7,1,1700,0.15),
(8,2,8,1,1800,0.15),

(9,1,1,2,1150,0.15),
(10,2,2,2,1250,0.15),
(11,1,3,2,1350,0.15),
(12,2,4,2,1450,0.15),
(13,1,5,2,1550,0.15),
(14,2,6,2,1650,0.15),
(15,1,7,2,1750,0.15),
(16,2,8,2,1850,0.15);
GO

--CREATE VIEW ENCRYPTION
CREATE VIEW V_ENCRYPTION
WITH ENCRYPTION
AS
SELECT *
FROM Colors
GO

SELECT *
FROM V_ENCRYPTION;
GO

--CREATE VIEW SCHEMABINDING
CREATE VIEW V_SCHEMABINDING
WITH SCHEMABINDING
AS
SELECT it.ItemName,c.ColorName
FROM dbo.Item as it
JOIN dbo.Colors as c
ON It.ColorId = C.ColorId
GO
--SEE
SELECT *
FROM dbo.V_SCHEMABINDING
GO
--FIND VAT OR COLOR RAD
CREATE VIEW V_EN
WITH ENCRYPTION
AS
SELECT id.VAT, c.ColorName
FROM 
    ItemDetail AS id
JOIN 
    Colors AS c
    ON id.ColorId = c.ColorId
JOIN 
    Item AS i
    ON id.ItemId = i.ItemId
WHERE 
    c.ColorName = 'Red';
GO
--SEE
SELECT *
FROM V_EN
GO
--CREATE FUNCTION
CREATE FUNCTION S_Calar()
RETURNS INT
AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = Count(*)
	FROM Item
	RETURN @Count
END
GO
--SEE FUNCTION
SELECT dbo.S_Calar() as 'Total Item';
GO
--CREATE TABLE FUNCTION
CREATE FUNCTION Fn_Table()
RETURNS TABLE
RETURN(SELECT * FROM colors)
GO
SELECT * FROM dbo.Fn_Table();
GO
--Milt Function
CREATE FUNCTION M_Function()
RETURNS @Table
TABLE(ItemId INT,ItemName VARCHAR(20),ColorId INT)
BEGIN
	INSERT INTO @Table(ItemId,ItemName ,ColorId)
	SELECT IT.ItemId +100,IT.ItemName,IT.ColorId+99
	FROM Item AS IT
	RETURN
END
GO

SELECT *
FROM dbo.M_Function()
Go

--Trigger
CREATE TABLE ItemLog
(
logId INT IDENTITY(1,1),
ItemId INT ,
Actions VARCHAR(20)
)
GO
-- CREATE TRIGGER
CREATE TRIGGER Tr_Instesd
ON item
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @ItemId INT
	SELECT @ItemId=DELETED.ItemId
	FROM DELETED
	IF @ItemId = 3
	BEGIN
		RAISERROR('CAN NOT DELETE',16,1)
		--ROLLBACK
		INSERT INTO ItemLog VALUES(@ItemId,'Invaild')
	END
	ELSE
	BEGIN
		DELETE Item
		WHERE @ItemId = ItemId
		INSERT INTO ItemLog VALUES(@ItemId,'DELETE')
	END
END
GO
--
DELETE Item
WHERE ItemId = 3
GO
--
SELECT *
FROM ItemLog
GO
--DROP PROCEDURE Sp_Crud
--CREATE PROCEDURE
--CREATE PROCEDURE Sp_Crud
--(
--@ColorId INT,
--@ColorName VARCHAR(30),
--@StatumentType VARCHAR(20) = '',
--@Status VARCHAR(30) OUTPUT
--)
--AS
--BEGIN
--	IF @StatumentType = 'SELECT'
--	BEGIN 
--		SET @Status = 'SELECTED';
--		SELECT *
--		FROM Colors
--		RETURN;
--	END
--	 IF @StatumentType = 'INSERT'
--	BEGIN
--		INSERT INTO Colors(ColorName)
--		VALUES(@ColorName)
--		SET @Status = 'INSERTED'
--	END
--	IF @StatumentType = 'UPDATE'
--	BEGIN
--		UPDATE Colors
--		SET ColorName = @ColorName
--		WHERE @ColorId = ColorId
--		SET @Status = 'UPDATED'
--	END
--	 IF @StatumentType = 'DELETE'
--	BEGIN
--		DELETE Colors
--		WHERE ColorId = @ColorId
--		SET @Status ='DELETED'
--	END
--END
--GO
--drop PROCEDURE Sp_Crud
CREATE PROCEDURE Sp_Crud
(
    @ColorId INT,  -- Must be provided
    @ColorName VARCHAR(30),
    @StatumentType VARCHAR(20) = '',
    @Status VARCHAR(30) OUTPUT
)
AS
BEGIN
    IF @StatumentType = 'SELECT'
    BEGIN 
        SET @Status = 'SELECTED';
        SELECT * FROM Colors;
        RETURN;
    END

    IF @StatumentType = 'INSERT'
    BEGIN
        -- Inserting with ColorId explicitly provided
        INSERT INTO Colors (ColorId, ColorName)
        VALUES (@ColorId, @ColorName);
        SET @Status = 'INSERTED';
    END

    IF @StatumentType = 'UPDATE'
    BEGIN
        UPDATE Colors
        SET ColorName = @ColorName
        WHERE ColorId = @ColorId;
        SET @Status = 'UPDATED';
    END

    IF @StatumentType = 'DELETE'
    BEGIN
        DELETE FROM Colors
        WHERE ColorId = @ColorId;
        SET @Status = 'DELETED';
    END
END
GO

--SELECT
DECLARE @SEE_Status VARCHAR(30);

EXEC Sp_Crud @ColorId =0,
@colorName ='',
@StatumentType = 'SELECT',
@Status=@SEE_Status OUTPUT

SELECT @SEE_Status AS OUTPUT_PARAMETER
GO
--INSERT
DECLARE @SEE_Status VARCHAR(30);

EXEC Sp_Crud 
    @ColorId = 4,  -- Must provide ColorId
    @ColorName = 'OrngeR',
    @StatumentType = 'INSERT',
    @Status = @SEE_Status OUTPUT;

SELECT @SEE_Status AS Insert_PARAMETER;
GO


--UPDATE
DECLARE @SEE_Status VARCHAR(30);

EXEC Sp_Crud 
    @ColorId = 4,        
    @ColorName = 'Green', 
    @StatumentType = 'UPDATE', 
    @Status = @SEE_Status OUTPUT;

SELECT @SEE_Status AS OUTPUT_PARAMETER;
GO
--DELETE
DECLARE @SEE_Status VARCHAR(30);

EXEC Sp_Crud 
    @ColorId = 4,        
    @ColorName = '',    
    @StatumentType = 'DELETE', 
    @Status = @SEE_Status OUTPUT;

SELECT @SEE_Status AS OUTPUT_PARAMETER;
GO
--index
CREATE  CLUSTERED INDEX IX_ITEM
ON ItemLog(ItemId)
GO

CREATE  NONCLUSTERED INDEX IX_NONITEM
ON ItemLog(LogId)
GO
exec sp_helpindex ItemLog



