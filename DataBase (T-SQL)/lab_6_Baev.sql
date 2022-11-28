USE Kindergarten;
go
if OBJECT_ID('Classes', 'U') is NOT NULL DROP TABLE Classes
go
if OBJECT_ID('Mentors', 'U') is NOT NULL DROP TABLE Mentors
go
if OBJECT_ID('Children', 'U') is NOT NULL DROP TABLE Children
go
if OBJECT_ID('Parents', 'U') is NOT NULL DROP TABLE Parents
go
if EXISTS (SELECT * FROM sys.sequences WHERE NAME = 'seq1') DROP SEQUENCE seq1
go 

-- Создается таблица с автоинкрементным первичным ключом. Добавляются поля, для которых используются ограничения (CHECK) и значения по умолчанию (DEFAULT)
CREATE TABLE Parents (
    Parent_ID int IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    MiddleName NVARCHAR(25) NULL,
    E_mail VARCHAR(50) UNIQUE NULL,
    Gender Bit NOT NULL DEFAULT 0,
);
go
-- В таблицу добавляется запись
INSERT INTO Parents(FirstName, LastName, MiddleName, E_mail)
VALUES (N'Валерий', N'Жмышенко', N'Альбертович', 'Zmishok@mail.ru'),
        (N'Гриша', N'Йегер', NULL, 'a@yandex.ru')
GO

SELECT * FROM Parents

-- Получение сгенерированного значения Identity
-- В любой области
SELECT IDENT_CURRENT('dbo.Parents') as curr 
GO
-- В текущей области выполнения
SELECT SCOPE_IDENTITY() as scope
GO
-- Cоздание таблицы с первичным ключом на основе глобального уникального идентификатора
-- Заодно вторая таблица связывывается с первой с помощью внешнего ключа
CREATE TABLE Children (
    Child_ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT (NEWID()),
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    MiddleName NVARCHAR(25) NULL,
    Gender Bit NOT NULL DEFAULT 0,
    Parent_ID int NULL,
    FOREIGN KEY (Parent_ID) REFERENCES Parents (Parent_ID)
);
GO
INSERT INTO Children(FirstName, LastName, MiddleName, Parent_ID)
VALUES (N'Денис', N'Жмышенко', N'Валерьевич', '1'),
       (N'Богдан', N'Жмышенко', N'Валерьевич', '1'),
       (N'Эрен', N'Йегер', NULL,  '2'),
       (N'Микаса', N'Аккерман', NULL, '2')
SELECT * FROM Children
GO
-- Созданиние таблицы с первичным ключом на основе последовательности
CREATE SEQUENCE seq1
    START WITH 0
    INCREMENT BY 1;
GO

SELECT * FROM sys.sequences


CREATE TABLE Mentors (
    Mentor_ID int PRIMARY KEY DEFAULT NEXT VALUE FOR seq1,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    MiddleName NVARCHAR(25) NULL,
    Date_of_birth  DATE NOT NULL CHECK (Date_of_birth > CONVERT(DATE, '1920-01-01') AND Date_of_birth < CONVERT(DATE, '2002-01-01')),
    E_mail VARCHAR(50) UNIQUE NULL,
    Gender Bit NOT NULL DEFAULT 0,
    Telephone Char(11) NOT NULL,
    Address NVARCHAR(80) NOT NULL, 
    Document_type INT NOT NUll CHECK (Document_type = 0 OR Document_type = 1) DEFAULT 0,
    Document_ID Char(10) UNIQUE NOT NULL,
    Qualification INT NOT NULL CHECK (QUALIFICATION = 0 OR QUALIFICATION = 1) DEFAULT 0,
    Work_group INT NOT NULL CHECK (Work_Group >= 0 AND Work_group <= 4) DEFAULT 0,
);
go

INSERT INTO Mentors(FirstName, LastName, MiddleName, Date_of_birth, Document_ID, Document_type,E_mail, Telephone, Address, Work_group)
VALUES (N'Иггер', N'Егр', N'Егросович', '2000-09-09', '3232523232', '1', 'h@mail.ru', '88005553535', N'Africa', 0),
       (N'Эрен', N'Йегер', NULL, '2000-09-09', '1212621213', '1', 'a@yandex.ru', '88005553535', N'Paradise', 1),
       (N'Хэ', N'Йегер', NULL, '2000-09-09', '1212621214', '1', 'w@yandex.ru', '88005553535', N'Paradise', 1),
       (N'Эрен', N'Йегер', NULL, '2000-09-09', '1212621215', '1', 'b@yandex.ru', '88005553535', N'Paradise', 1),
       (N'Эрен', N'Йегер', NULL, '2000-09-09', '1212621216', '1', 'c@rambler.ru', '88005553535', N'Paradise', 1),
       (N'Эрен', N'Йегер', NULL, '2000-09-09', '1212621217', '1', 'd@yandex.ru', '88005553535', N'Paradise', 1),
       (N'Эрен', N'Йегер', NULL, '2000-09-09', '1212621218', '1', 'w@mail.ru', '88005553535', N'Paradise', 1)
SELECT * FROM Mentors
GO
-- Тестирование действий для ограничений ссылочной целостности

-- Для Update'ов
CREATE TABLE Classes (
    Class_ID INT IDENTITY PRIMARY KEY,
    Subject VARCHAR(30) NULL,
    Date DATE NOT NULL,
    Mentor_ID INT NULL,
    FOREIGN KEY(Mentor_ID) REFERENCES Mentors(Mentor_ID)
)
GO

INSERT INTO Classes(Date, Mentor_ID)
VALUES ('03-03-2021', 1)
GO 
