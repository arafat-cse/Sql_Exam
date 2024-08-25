use master;
GO
--DROP DATABASE
IF EXISTS(SELECT NAME FROM SYS.DATABASES WHERE NAME='InventoryDB')
BEGIN
	DROP DATABASE InventoryDB
END
GO
--CREATE DATABASE
CREATE DATABASE InventoryBD
ON PRIMARY(
NAME ='InventoryBD_1',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\InventoryDB_data_1.mdf',
SIZE=25MB,
MAXSIZE=100MB,
FILEGROWTH=5%
)
LOG ON
(
NAME ='InventoryBD_log_1',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\InventoryBD_log_1.ldf',
SIZE=2MB,
MAXSIZE=50MB,
FILEGROWTH=1%
)
GO
--USE DATABASE
USE InventoryBD
GO
--COLORS TABLE
CREATE TABLE Colors
(
ColorsId INT PRIMARY KEY,
ColorsName VARCHAR(20)
)
GO
--ITEM TABLE
CREATE TABLE Items
(
ItemsId INT PRIMARY KEY,
ItemsName VARCHAR(20)
)
GO
--LOTS TABLE
CREATE TABLE Lots
( 
LotsId INT PRIMARY KEY,
Quantity VARCHAR(20)
)
GO
--RELATION TABLE
CREATE TABLE ProductDetails
(
ProductDetailsId INT IDENTITY(1,1),
ItemsId INT REFERENCES Items(ItemsId),
ColorsId INT REFERENCES Colors(ColorsId),
LotsId INT REFERENCES Lots(LotsId),
UnitPrice MONEY,
Vat NUMERIC(8,5)

)
GO
--COLORS INSERT
INSERT INTO Colors
VALUES
(1,'Red'),
(2,'Blue'),
(3,'Yellow'),
(4,'Orange'),
(5,'Green'),
(6,'Vilolet'),
(7,'Indigo');
GO
SELECT *
FROM Items

--ITEM INSERT
INSERT INTO Items
VALUES
(1,'Camp Shirt'),
(2,'Camp Shirt'),
(3,'Dress Shirt'),
(4,'Dress Shirt'),
(5,'Poet Shirt'),
(6,'Poet Shirt'),
(7,'T-Shirt'),
(8,'T-Shirt'),
(9,'Polo Shirt'),
(10,'Polo Shirt'),
(11,'Sweat Shirt'),
(12,'Sweat Shirt')
GO

INSERT INTO lots 
values
(1,6),
(2,12);
GO
SELECT *
FROM ProductDetails
INSERT INTO ProductDetails
VALUES
(1,1,1,1500,0.15), 
(1,2,1,1500,0.15),
(2,1,2,1200,0.15), 
(2,3,2,1200,0.15),
(3,1,1,1800,0.15), 
(3,2,1,1800,0.15),
(4,2,2,1000,0.15), 
(4,4,2,1000,0.15),
(5,1,1,1500,0.15), 
(5,2,1,1500,0.15),
(6,5,2,1200,0.15), 
(6,6,2,1200,0.15),
(7,1,1,1600,0.15), 
(7,2,1,1600,0.15),
(8,2,2,1000,0.15), 
(8,7,2,1000,0.15),
(9,1,1,1500,0.15), 
(9,2,1,1500,0.15),
(10,1,2,1200,0.15), 
(10,3,2,1200,0.15),
(11,2,1,1800,0.15), 
(11,6,1,1200,0.15),
(12,1,1,1800,0.15), 
(12,2,1,1200,0.15);
GO
	---ans to the Question no 2--
Select *FROM items;
Select *FROM colors;
Select *FROM lots;
Select *FROM Productdetails;
GO
---
--CREATE FUNCTION
CREATE FUNCTION Fn_Sclar()
RETURNS INT
AS
BEGIN
	DECLARE @COUNT INT;
	SELECT @COUNT=COUNT(*)
	FROM Colors;
	RETURN @COUNT;
END
GO

SELECT dbo.Fn_Sclar() AS 'COUNT'
GO

--TABLE FUNCTION
CREATE FUNCTION Fn_Table()
RETURNS TABLE
AS
RETURN ( SELECT * FROM Colors)
GO
SELECT *
FROM dbo.Fn_Table();
GO

--Multi Function
CREATE FUNCTION Fn_Mul()
RETURNS @TABLE TABLE(ColorsId INT,ColorsName VARCHAR(30))
BEGIN
	INSERT INTO @TABLE (ColorsId,ColorsName)
	SELECT c.ColorsId,c.ColorsName
	FROM Colors C
	JOIN Productdetails R
	ON C.ColorsId= R.ColorsId
	JOIN Lots L
	ON L.LotsId = R.LotsId
	RETURN
END
GO
---SEE THE FUNCTION
SELECT *
FROM dbo.Fn_Mul()
GO
--Create View
--CREATE VIEW ENCRYPTION
CREATE VIEW V_ENCRYPTION
WITH ENCRYPTION
AS
SELECT *
FROM Colors
GO
---
SELECT *
FROM V_ENCRYPTION;
GO

---
--CREATE VIEW ENCRYPTION
CREATE VIEW V_Schemabinding
WITH SCHEMABINDING
AS
SELECT C.ColorsName
FROM dbo.Colors AS C
GO

SELECT *
FROM V_Schemabinding;
GO
--drop trigger TRI_DEL
--TRIGGER
CREATE TABLE RelationLog(
RelationLogID INT IDENTITY(1,1),
RelationId INT ,
RelationDescription VARCHAR(30)
)
GO
----
CREATE TRIGGER TRI_DEL
ON ProductDetails
INSTEAD OF DELETE
AS 
BEGIN
	DECLARE @ProductDetailsId INT;
	SELECT @ProductDetailsId = DELETED.ProductDetailsId
	FROM DELETED;
	IF @ProductDetailsId = 8
		BEGIN 
			RAISERROR('CAN NOT DELETE',16,1)
			--ROLLBACK;
			INSERT INTO RelationLog VALUES (@ProductDetailsId,'Invlid')
		END
			ELSE
			BEGIN
				DELETE ProductDetails
				WHERE @ProductDetailsId = ProductDetailsId
				INSERT INTO RelationLog VALUES (@ProductDetailsId,'DELETE')
			END
END
GO
---DELETE TEACHER
DELETE ProductDetails WHERE ProductDetailsId =4
GO
--see trigger
select *
from RelationLog
go
select *
from ProductDetails
--SEE THE TEACHER
SELECT *
FROM Colors
GO
--PROC
CREATE PROC P_CRUD
(
@colorsId INT,
@ColorsName VARCHAR(20),
@StatumentType VARCHAR(20) ='',
@Status VARCHAR(20)		OUTPUT
)
AS
BEGIN
	IF @StatumentType = 'SELECT'
	BEGIN
		SET @Status ='SELECTED'
		SELECT *
		FROM Colors
		RETURN
	END
	IF @StatumentType ='INSERT'
	BEGIN
		INSERT INTO Colors(ColorsId) 
		VALUES (@colorsId)
		SET @Status = 'INSERTED'
	END
	IF @StatumentType ='UPDATE'
	BEGIN
		UPDATE Colors
		SET @colorsId = ColorsName
		WHERE @colorsId = colorsId
		SET @Status = 'UPDATED'
	END
	IF @StatumentType ='DELETE'
	BEGIN
		DELETE Colors
		WHERE @colorsId = colorsId
		SET @Status ='DELETED'
	END
END
GO


--
DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @ColorsId =0,
@ColorsName ='',
@StatumentType ='SELECT',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
--set IDENTITY_INSERT Semester  OFF
--set IDENTITY_INSERT Semester  ON

DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @ColorsId =12,
@ColorsName ='Orgin',
@StatumentType ='INSERT',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
----
DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @ColorsId =12,
@ColorsName ='Orgin',
@StatumentType ='UPDATE',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
--
DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @ColorsId =12,
@ColorsName ='',
@StatumentType ='DELETE',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
---INDEX
CREATE CLUSTERED INDEX IX_CLU
ON RelationLog(RelationLogID)
GO

CREATE NONCLUSTERED INDEX IX_NONCLU
ON RelationLog(RelationLogID)
GO
EXEC sp_helpindex 'RelationLog';




