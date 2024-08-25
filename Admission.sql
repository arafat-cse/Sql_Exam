--DROP DATABASE
IF EXISTS(SELECT NAME FROM SYS.DATABASES WHERE NAME ='Collage')
BEGIN
	DROP DATABASE Collage;
END
GO
--CREATE DATABASE
CREATE DATABASE Collage
ON PRIMARY
(
NAME='Collage_data',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Collage_data.mdf',
SIZE=1MB,
MAXSIZE=10MB,
FILEGROWTH=1MB
)
LOG ON
(
NAME='Collage_log',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Collage_log.ldf',
SIZE=1MB,
MAXSIZE=10MB,
FILEGROWTH=1MB
);
GO
--USE DATABASE
USE Collage;
GO
--TEACHER TABLE
CREATE TABLE Teacher
(
TeacherId INT PRIMARY KEY ,
Name VARCHAR(30)
);
GO

--STUDENT TABLE
CREATE TABLE Student
(
StudentId INT PRIMARY KEY ,
Name VARCHAR(30)
);
GO
--SEMESTER TABLE
CREATE TABLE Semester
(
SemesterId INT PRIMARY KEY ,
Name VARCHAR(20)
)
GO
--SUBJECT TABLE
CREATE TABLE Subjects
(
SubjectsId INT PRIMARY KEY ,
Name VARCHAR(30)
)
GO
--RELATION TABLE
CREATE TABLE Relation
(
RelationId INT IDENTITY(1,1),
TeacherId INT REFERENCES Teacher(TeacherId),
StudentId INT REFERENCES Student(StudentId),
SemesterId INT REFERENCES Semester(SemesterId),
SubjectsId INT REFERENCES Subjects(SubjectsId),
PRIMARY KEY(TeacherId,StudentId,SemesterId,SubjectsId)
)
GO

--INSERT DATA
--INSERT TEACHER
INSERT INTO Teacher
VALUES
(1,'A'),
(2,'B'),
(3,'C')
GO
SELECT *
FROM Semester
GO
--INSERT STUDENT
INSERT INTO Student
VALUES
(1,'AA'),
(2,'BB'),(3,'CC'),(4,'DD'),(5,'EE'),(6,'FF'),(7,'GG'),(8,'HH'),(9,'II')
GO
--INSERT SEMESTER
INSERT INTO Semester
VALUES
(1,'Spring'),
(2,'Summer'),
(3,'Winter')
GO
--INSERT SUBJECT
INSERT INTO Subjects
VALUES
(1,'#'),(2,'Data Base'),(3,'Web Desing'),(4,'Data Minig'),(5,'MIS'),(6,'PHP'),(7,'Project Manager'),(8,'PCL'),(9,'Softwere Engineering')
GO

--INSERT RELATION
INSERT INTO Relation
VALUES
(1,1,1,1),(1,2,1,1),(1,4,1,1),(2,1,1,2),(2,3,1,2),(2,9,1,2),(3,9,1,3),(3,8,1,3),(3,5,1,3),(3,7,1,3)
GO

--CREATE FUNCTION
CREATE FUNCTION Fn_Sclar()
RETURNS INT
AS
BEGIN
	DECLARE @COUNT INT;
	SELECT @COUNT=COUNT(*)
	FROM Student;
	RETURN @COUNT;
END
GO

SELECT dbo.Fn_Sclar() AS 'COUNT'
GO

--TABLE FUNCTION
CREATE FUNCTION Fn_Table()
RETURNS TABLE
AS
RETURN ( SELECT * FROM Student)
GO
SELECT *
FROM dbo.Fn_Table();
GO

--Multi Function
CREATE FUNCTION Fn_Mul()
RETURNS @TABLE TABLE(TeacherName VARCHAR(30), StudentName VARCHAR(30),SemesterName VARCHAR(30), SubjectName VARCHAR(30))
BEGIN
	INSERT INTO @TABLE (TeacherName,StudentName,SemesterName,SubjectName)
	SELECT t.Name,s.Name,se.Name,su.Name
	FROM Teacher T
	JOIN Relation R
	ON T.TeacherId = R.TeacherId
	JOIN Student S
	ON S.StudentId = R.StudentId
	JOIN Semester SE
	ON SE.SemesterId = R.SemesterId
	JOIN Subjects SU
	ON SU.SubjectsId = R.SubjectsId
	RETURN
END
GO
---SEE THE FUNCTION
SELECT *
FROM dbo.Fn_Mul()
GO
--Create View
--DROP VIEW just_views
CREATE VIEW just_views
AS
SELECT T.Name as TeacherName, S.Name as StudentName, SU.Name as SubjectName
FROM Teacher T
JOIN Relation R
ON T.TeacherId = R.TeacherId
JOIN Student S
ON S.StudentId = R.StudentId
JOIN Subjects SU
ON SU.SubjectsId = R.SubjectsId
WHERE SU.Name = 'Data Base';
GO
--Select
SELECT *
FROM just_views;
GO

--VIEW ENCRYPTION
CREATE VIEW ENC_VIEW
WITH ENCRYPTION
AS
SELECT S.Name AS StudenName,SU.Name AS SubjectName
FROM Student S
JOIN Relation R
ON S.StudentId = R.StudentId
JOIN Subjects SU
ON SU.SubjectsId = R.SubjectsId
WHERE SU.Name ='DATA BASE' AND S.Name = 'AA';
GO
--see
SELECT *
FROM dbo.ENC_VIEW;
GO
--drop view SCHEMA_VIEW
--SCHEMABINDING
CREATE VIEW SCHEMA_VIEW
WITH SCHEMABINDING
AS
SELECT S.Name AS StudenName,SU.Name AS SubjectName
FROM dbo.Student S
JOIN dbo.Relation R
ON S.StudentId = R.StudentId
JOIN dbo.Subjects SU
ON SU.SubjectsId = R.SubjectsId
WHERE SU.Name ='DATA BASE' AND S.Name = 'AA';
GO
--see
SELECT *
FROM dbo.SCHEMA_VIEW;
GO
----view encryption schemabinding
--DROP VIEW VIW_TOGERTHER
--
CREATE VIEW VIW_TOGERTHER
WITH ENCRYPTION,SCHEMABINDING
AS
SELECT S.Name AS SubjectName,SE.Name as SemesterName
FROM dbo.Subjects S
JOIN dbo.Relation R
ON S.SubjectsId = R.SubjectsId
JOIN dbo.Semester se
ON SE.SemesterId = R.SemesterId
WHERE SE.Name='Spring' AND S.Name='DATA BASE';
GO

--
SELECT *
FROM dbo.VIW_TOGERTHER;
GO

--TRIGGER
CREATE TABLE RelationLog(
RelationLogID INT IDENTITY(1,1),
RelationId INT ,
RelationDescription VARCHAR(30)
)
GO
----
CREATE TRIGGER TRI_DEL
ON Relation
INSTEAD OF DELETE
AS 
BEGIN
	DECLARE @RelationId INT;
	SELECT @RelationId = DELETED.RelationId
	FROM DELETED;
	IF @RelationId = 8
		BEGIN 
			RAISERROR('CAN NOT DELETE',16,1)
			ROLLBACK;
			INSERT INTO RelationLog VALUES (@RelationId,'Invlid')
		END
			ELSE
			BEGIN
				DELETE Relation
				WHERE @RelationId = RelationId
				INSERT INTO RelationLog VALUES (@RelationId,'DELETE')
			END
END
GO
---DELETE TEACHER
DELETE Relation WHERE RelationId =9
GO
--SEE THE TEACHER
SELECT *
FROM Semester
GO
--PROC
CREATE PROC P_CRUD
(
@SemesterId INT,
@SemesterName VARCHAR(20),
@StatumentType VARCHAR(20) ='',
@Status VARCHAR(20)		OUTPUT
)
AS
BEGIN
	IF @StatumentType = 'SELECT'
	BEGIN
		SET @Status ='SELECTED'
		SELECT *
		FROM Semester
		RETURN
	END
	IF @StatumentType ='INSERT'
	BEGIN
		INSERT INTO Semester (SemesterId) 
		VALUES (@SemesterId)
		SET @Status = 'INSERTED'
	END
	IF @StatumentType ='UPDATE'
	BEGIN
		UPDATE Semester
		SET @SemesterName = Name
		WHERE @SemesterId = SemesterId
		SET @Status = 'UPDATED'
	END
	IF @StatumentType ='DELETE'
	BEGIN
		DELETE Semester
		WHERE @SemesterId = SemesterId
		SET @Status ='DELETED'
	END
END
GO


--
DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @SemesterId =0,
@SemesterName ='',
@StatumentType ='SELECT',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
--set IDENTITY_INSERT Semester  OFF
--set IDENTITY_INSERT Semester  ON

DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @SemesterId =7,
@SemesterName ='ORGIN',
@StatumentType ='INSERT',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
----
DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @SemesterId =7,
@SemesterName ='ORGIN',
@StatumentType ='UPDATE',
@Status =@SEE_STAUS OUTPUT

SELECT @SEE_STAUS AS SELECT_PARAMETER
GO
--
DECLARE @SEE_STAUS VARCHAR(20);

EXEC P_CRUD @SemesterId =7,
@SemesterName ='',
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
