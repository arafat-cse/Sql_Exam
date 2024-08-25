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
ColorId INT PRIMARY KEY IDENTITY(1,1),
ColorName VARCHAR(20)
);
GO
--CREATE TABLE ITEM
CREATE TABLE Item
(
ItemId INT PRIMARY KEY IDENTITY(1,1),
ItemName VARCHAR(20),
ColorId INT REFERENCES Colors(ColorId)
);
GO
--CREATE TABLE LOT
CREATE TABLE Lot
(
lotId INT PRIMARY KEY IDENTITY(	1,1),
lotName VARCHAR(10),
Quantity INT
);
--CRATE TABLE ITEMDETAIL
CREATE TABLE ItemDetail
(
ItemDetailId INT PRIMARY KEY IDENTITY(1,1),
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
('Red'),
('Blue');
GO

--INSERT ITEM
INSERT INTO Item
VALUES
('Denim Shirt',1),
('Denim Shirt',2),
('Camp Shirt',1),
('Camp Shirt',2),
('T-Shirt',1),
('T-Shirt',2),
('polo Shirt',1),
('polo Shirt',2);
GO

--INSERT LOT
SELECT *
FROM ItemDetail
INSERT INTO Lot
VALUES 
('Item 1',6),
('Item 2',12);
GO
--insert relation
INSERT INTO ItemDetail
VALUES
(1,1,1,1100,0.15),
(2,2,1,1200,0.15),
(1,3,1,1300,0.15),
(2,4,1,1400,0.15),
(1,5,1,1500,0.15),
(2,6,1,1600,0.15),
(1,7,1,1700,0.15),
(2,8,1,1800,0.15),

(1,1,2,1150,0.15),
(2,2,2,1250,0.15),
(1,3,2,1350,0.15),
(2,4,2,1450,0.15),
(1,5,2,1550,0.15),
(2,6,2,1650,0.15),
(1,7,2,1750,0.15),
(2,8,2,1850,0.15);
GO

--VIEW CREATE
CREATE VIEW V_ENCRYPTION
WITH ENCRYPTION
AS
SELECT *
FROM Item
GO
--SEE VIEW
SELECT *
from dbo.V_ENCRYPTION

--CREATE VIEW SCHEMABINDING
CREATE VIEW V_SCHEMABINDING
WITH SCHEMABINDING
AS
SELECT c.ColorId,c.ColorName
FROM dbo.Colors as c
GO

--see view
SELECT *
FROM dbo.V_SCHEMABINDING;
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
SELECT *
FROM ItemDetail
GO

--CREATE FUNCTION
CREATE FUNCTION F_Scalar()
RETURNS INT
AS
	BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(*)
	FROM Item
	RETURN @Count
END
GO

SELECT dbo.F_Scalar() AS ' Total';
GO
--CREATE TABLE FUNCTION
CREATE FUNCTION F_Table()
RETURNS TABLE
	AS
	RETURN(
	SELECT *
	FROM Item)
GO

SELECT *
FROM dbo.F_Table();
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

--SEE MUL VIEW
SELECT *
FROM dbo.M_Function()
Go


SELECT *
FROM Item



---CREATE TRIGGER
--LOG TABLE
CREATE TABLE ItemLog
(
logId INT IDENTITY(1,1),
ItemId INT,
Actions VARCHAR(20)
)
GO

--CREATE TRIGGER

CREATE TRIGGER Tr_Instard
ON Item
INSTEAD OF DELETE
AS
BEGIN 
	DECLARE @ItemId INT
	SELECT @ItemId = DELETED.ItemId
	FROM DELETED
	IF @ItemId =3
	BEGIN
		RAISERROR('CAN NOT DELETE',16,1)
		ROLLBACK
		INSERT INTO ItemLog VALUES(@ItemId,'Invild')
	END
	ELSE
	BEGIN
		DELETE Item
		WHERE @ItemId = ItemId
		INSERT INTO ItemLog VALUES (@ItemId,'DELETE')
	END
END
GO

DELETE Item WHERE ItemId = 3;
GO

SELECT *
FROM ItemLog;
GO
--Procedure
CREATE PROCEDURE P_Crud
(
@ColorID INT,
@ColorName VARCHAR(30),
@StatumentType VARCHAR(20) ='',
@Status VARCHAR(20) OUTPUT
)
AS
BEGIN
	IF @StatumentType ='SELECT'
	BEGIN
		SET @Status ='SELECT'
		SELECT *
		FROM Colors
		RETURN
	END
	IF @StatumentType = 'INSERT'
	BEGIN
		INSERT INTO Colors(ColorName)
		VALUES (@ColorName)
		SET @Status ='INSERTED'
	END
	IF @StatumentType ='UPDATE'
	BEGIN
		UPDATE Colors
		SET ColorName = @ColorName
		WHERE ColorId =@ColorID
		SET @Status ='UPDATE'
	END
	IF @StatumentType ='DELETE'
	BEGIN 
		DELETE Colors
		WHERE ColorId = @ColorID
		SET @Status ='DELETE'
	END
END
GO


--SELECT
DECLARE @SEE_Status VARCHAR(30);

EXEC P_Crud @ColorId =0,
@colorName ='',
@StatumentType = 'SELECT',
@Status=@SEE_Status OUTPUT

SELECT @SEE_Status AS SELECT_PARAMETER
GO
--INSERT
DECLARE @SEE_Status VARCHAR(30);
EXEC P_Crud @ColorId =2,
@ColorName='orgin',
@StatumentType='INSERT',
@Status =@SEE_Status OUTPUT

SELECT @SEE_Status AS INSERT_PARAMETER
GO
--UPDATE
DECLARE @SEE_Status VARCHAR(30);

EXEC P_Crud @ColorId =3,
@ColorName ='orgin',
@StatumentType ='UPDATE',
@Status =@SEE_Status OUTPUT
SELECT @SEE_Status AS UPDATE_PARAMETER
GO
--DELETE
DECLARE @SEE_Status VARCHAR(30);

EXEC P_Crud @ColorId =3,
@ColorName =' ',
@StatumentType ='DELETE',
@Status =@SEE_Status OUTPUT
SELECT @SEE_Status AS UPDATE_PARAMETER
GO
--INDEX
CREATE INDEX I_Color
ON Colors(ColorName);
GO

CREATE CLUSTERED INDEX C_Clustered
ON ItemLog(logid);
GO
--see 
EXEC sp_helpindex ItemLog
EXEC sp_helpindex Colors







