use Kindergarten
go
if OBJECT_ID('Mentors', 'U') is NOT NULL DROP TABLE Mentors
go

CREATE TABLE Mentors (
    Mentor_ID int identity PRIMARY KEY,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    MiddleName NVARCHAR(25) NULL,
    E_mail VARCHAR(50) UNIQUE NULL,
    Salary int not null,
);
go

INSERT INTO Mentors(FirstName, LastName, MiddleName,E_mail, Salary)
VALUES (N'Иггер', N'Егр', N'Егросович','h@mail.ru', 40000),
       (N'Эрен', N'Йегер', NULL, 'a@yandex.ru', 80000)
GO