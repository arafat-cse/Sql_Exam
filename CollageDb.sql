USE master;
GO
IF EXISTS (SELECT NAME FROM SYS.DATABASES WHERE NAME ='CollageDB')
BEGIN
DROP DATABASE CollageDB
END
GO
CREATE DATABASE CollageDB
ON PRIMARY(
Name='Collage_Data_1',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Collage_Data_1.mdf',
SIZE=25MB,
MAXSIZE=100MB,
FILEGROWTH=5%
)
LOG ON
(
Name='Collage_Log_1',
FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Collage_Log_1.ldf',
SIZE=2MB,
MAXSIZE=25MB,
FILEGROWTH=1%
)
GO
USE CollageDB;
GO
--create table
CREATE TABLE StudentInfo
(
StinfoId INT PRIMARY KEY IDENTITY,
StudenId INT ,
StudentName VARCHAR(30)
)
GO
--CREATE TABLE
CREATE TABLE Course
(
CourseId INT PRIMARY KEY IDENTITY,
CourseName VARCHAR(20)
)
GO
--CREATE TABLE
CREATE TABLE Semester
(
SemesterID INT PRIMARY KEY IDENTITY,
SemesterName VARCHAR(30)
)
GO
--CREATE TABLE
CREATE TABLE AdmissionInfo
(
AdmissionID INT PRIMARY KEY IDENTITY,
AdmissionDate DATE,
StinfoId INT REFERENCES StudentInfo(StinfoId),
CourseId INT REFERENCES Course(CourseId),
SemesterID INT REFERENCES Semester(SemesterID)
)
GO
SELECT *
FROM StudentInfo
--INSERT 
INSERT INTO StudentInfo
VALUES
(1148703,'MD HAYATUNNABI'),
(1148704,'MD SHAJADUR RAHMAN'),
(1148705,'MD ESAHAK ALI'),
(1148706,'MD HAZMAL HOSSAN'),
(1148707,'MD AMINUR ISLAM');

GO

--Course
INSERT INTO Course
VALUES
('C#'),
('HTML'),
('XML'),
('JAVA'),
('UML');
GO
SELECT *
FROM AdmissionInfo
--Semester
INSERT INTO Semester
VALUES
('FALL'),
('SUMMER');
GO
--AdmissionInfo
INSERT INTO AdmissionInfo
VALUES
('1/1/2019',1,1,1),
('1/1/2019',1,2,1),
('1/1/2019',1,3,1),
('2/1/2019',2,2,2),
('2/1/2019',2,4,2),
('2/1/2019',2,3,2),
('1/2/2019',3,3,2),
('1/2/2019',3,2,2),
('1/2/2019',3,5,2),
('2/2/2019',3,1,1),
('2/2/2019',4,4,1),
('2/2/2019',4,3,1),
('1/3/2019',5,1,1),
('1/3/2019',5,2,1),
('1/3/2019',5,3,1);
GO

--TRIGGER
CREATE TABLE SELog
(
SemesterId INT,
SemesterName VARCHAR(30)
)
GO
------TRIGGER OPTION
CREATE TRIGGER Tr_Instard
ON Semester
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @SemesterId INT;
    DECLARE @SemesterName VARCHAR(30);
    
    SELECT @SemesterId = SemesterId, @SemesterName = SemesterName
    FROM DELETED;

    IF EXISTS (SELECT 1 FROM AdmissionInfo WHERE SemesterID = @SemesterId)
    BEGIN
        -- Handle the case where there are references in AdmissionInfo
        RAISERROR ('Cannot delete because the semester is referenced in AdmissionInfo.', 16, 1);
        INSERT INTO SELog VALUES(@SemesterId, 'DELETE FAILED - REFERENCED');
        --ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Semester
        WHERE SemesterId = @SemesterId;
        INSERT INTO SELog VALUES(@SemesterId, 'DELETED');
    END
END;
GO
-------
DELETE FROM Semester WHERE SemesterID = 1;
----------
SELECT * FROM SELog;
GO
--TRIGGER CREATE
CREATE TRIGGER Tr_Instard
ON Semester
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @SemesterId INT 
	SELECT @SemesterId = DELETED.SemesterId
	FROM DELETED
	IF @SemesterId = 2
	BEGIN
		RAISERROR ('CAN NOT DELETE',16,1)
		--ROLLBACK
		INSERT INTO SELog VALUES(@SemesterId,'INVAILD')
	END
	ELSE
	BEGIN
		DELETE Semester
		WHERE @SemesterId = SemesterId
		INSERT INTO SELog VALUES(@SemesterId,'DELETE')
	END
END
GO
---SE DELETE
DELETE Semester WHERE SemesterID = 1
--SEE TRIGGER
SELECT *
FROM SELog;
GO
--INDEX
 CREATE INDEX I_student
ON StudentInfo(StudenId);
GO
Exec sp_helpindex StudentInfo;
go
 --Clustered
--7 CREATE PROCEDURE SELECT,INSET
SELECT *
FROM Course
GO
CREATE PROCEDURE P_CURD
(
    @CourseId INT,
    @CourseName VARCHAR(20),
    @StatumentType VARCHAR(30) = '',
    @Status VARCHAR(30) OUTPUT
)
AS
BEGIN
    IF @StatumentType = 'SELECT'
    BEGIN
        SET @Status = 'SELECTED';
        SELECT * FROM Course;
        RETURN;
    END

    IF @StatumentType = 'INSERT'
    BEGIN
        INSERT INTO Course (CourseName)
        VALUES (@CourseName);
        SET @Status = 'INSERTED';
    END

    IF @StatumentType = 'UPDATE'
    BEGIN
        UPDATE Course
        SET CourseName = @CourseName
        WHERE CourseId = @CourseId;
        SET @Status = 'UPDATED';
    END

    IF @StatumentType = 'DELETE'
    BEGIN 
        IF EXISTS (SELECT 2 FROM AdmissionInfo WHERE CourseId = @CourseId)
        BEGIN
            SET @Status = 'DELETE FAILED - REFERENCED IN AdmissionInfo';
        END
        ELSE
        BEGIN
            DELETE FROM Course
            WHERE CourseId = @CourseId;
            SET @Status = 'DELETED';
        END
    END
END;

--SEE
DECLARE @SEE_Status VARCHAR(20);

EXEC P_CURD @CourseId =0,
@CourseName ='',
@StatumentType = 'SELECT',
@Status=@SEE_Status OUTPUT

SELECT @SEE_Status AS SELECT_PARAMETER
GO
--
--SET IDENTITY_INSERT Course off;
--GO
--insert
DECLARE @SEE_Status VARCHAR(20);

EXEC P_CURD @CourseId =3,
@CourseName ='NET',
@StatumentType = 'INSERT',
@Status=@SEE_Status OUTPUT

SELECT @SEE_Status AS insert_PARAMETER
GO

--update
DECLARE @SEE_Status VARCHAR(20);

EXEC P_CURD @CourseId =3,
@CourseName ='SPRING',
@StatumentType = 'UPDATE',
@Status=@SEE_Status OUTPUT

SELECT @SEE_Status AS UPDATE_PARAMETER
GO
--DELETE
DECLARE @SEE_Status VARCHAR(30);

EXEC P_CURD @CourseId = 2,
@CourseName = '',
@StatumentType = 'DELETE',
@Status = @SEE_Status OUTPUT;

SELECT @SEE_Status AS DELETE_STATUS;

--FUNCTION
CREATE FUNCTION S_Calar()
RETURNS INT
AS
BEGIN
	DECLARE @count INT
	SELECT @count = COUNT(*)
	FROM Course
	RETURN @count
END
GO

SELECT dbo.S_Calar() AS 'Total Course'
GO
CREATE FUNCTION F_Table()
RETURNS TABLE
AS

	RETURN (SELECT C.CourseId,C.CourseName
	FROM dbo.Course AS C)
GO

SELECT *
FROM dbo.F_Table() 	