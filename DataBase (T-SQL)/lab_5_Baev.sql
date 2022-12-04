USE master;
go
IF DB_ID('Kindergarten') is NOT NULL DROP DATABASE Kindergarten
go
--Создается база данных
CREATE DATABASE Kindergarten
ON (
    NAME = Kindergarten_dat,
    FILENAME = '/home/main/kindergarten_dat.mdf',
    SIZE = 10,
    MAXSIZE = UNLIMITED
)
LOG ON (
    NAME = Kindergarten_log,
    FILENAME = '/home/main/kindergarten_log.ldf',
    SIZE = 5,
    MAXSIZE = 25,
    FILEGROWTH = 5
);
go
USE Kindergarten;
go
-- Создается таблица
CREATE TABLE Parents (
    Parent_ID int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    FirstName VARCHAR(25) NOT NULL,
    LastName VARCHAR(25) NOT NULL,
    MiddleName VARCHAR(25) NULL,
    Date_of_birth  SMALLDATETIME NOT NULL,
    E_mail VARCHAR(50) NULL,
    Gender Bit NOT NULL,
    Telephone Char(11) NOT NULL,
    Address VARCHAR(80) NOT NULL, 
    Document_type INT NOT NUll,
    Document_ID Char(10) NOT NULL,
);
go
-- В таблицу добавляется запись
INSERT INTO Parents(FirstName, LastName, MiddleName, Date_of_birth, E_mail, Gender, Telephone, Address, Document_type, Document_ID)
VALUES ('Valeriy', 'Zmishenko', 'Albertovich', 1968-01-01, 'Zmishok@mail.ru', 0, '88005553535', 'Pushkin street', 1, '1234567890')
--SELECT * FROM Parents
go 
-- Добавляется новая файловая группа
ALTER DATABASE Kindergarten 
ADD FILEGROUP kindergarten_sec
go

-- ДОбавляется новый файл данных в созданную файловую группу
ALTER DATABASE Kindergarten
ADD FILE(
    NAME = Kindergarten_sec_dat,
    FILENAME = '/home/sec/kindergarten_sec.ndf',
    SIZE = 10,
    MAXSIZE = 100,
    FILEGROWTH = 5%
) TO FILEGROUP kindergarten_sec
GO

-- Новая файловая группа становится файловой группой по умолчанию 
ALTER DATABASE Kindergarten
	modify filegroup kindergarten_sec default;
GO

--SELECT * FROM SYS.FILEGROUPS
--GO
-- Создается еще одна таблица
CREATE TABLE Mentors (
    Mentor_ID int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    FirstName VARCHAR(25) NOT NULL,
    LastName VARCHAR(25) NOT NULL,
    MiddleName VARCHAR(25) NULL,
    Date_of_birth  SMALLDATETIME NOT NULL,
    E_mail VARCHAR(50) NULL,
    Gender Bit NOT NULL,
    Telephone Char(11) NOT NULL,
    Address VARCHAR(80) NOT NULL, 
    Document_type INT NOT NUll,
    Document_ID Char(10) NOT NULL,
    Salary INT NOT NULL,
    Qualification INT NOT NULL,
    Work_group INT NOT NULL
);
--SELECT * FROM Mentors
--go

--SELECT * FROM sys.objects WHERE type in (N'U')
--go
-- Таблица удаляется, чтобы можно было удалить файловую группу
DROP TABLE Mentors
go 
-- Нельзя удалить файловую группу по умолчанию
ALTER DATABASE Kindergarten
    MODIFY FILEGROUP [primary] default;
go
-- Файл удаляется, чтобы можно было удалить файловую группу
ALTER DATABASE Kindergarten
REMOVE file Kindergarten_sec_dat
go 
-- Новая файловая группа удаляется
ALTER DATABASE Kindergarten
REMOVE FILEGROUP kindergarten_sec
go 

-- Создается схема
CREATE SCHEMA Visitors
go

-- В схему добавляется таблица
ALTER SCHEMA Visitors TRANSFER Parents
go

--SELECT * FROM sys.objects WHERE type in (N'U')

-- Удаление таблицы, чтобы можно было удалить схему
DROP TABLE Visitors.Parents 
go

-- Удаление схемы
DROP SCHEMA Visitors
go

--SELECT * FROM sys.objects WHERE type in (N'U')