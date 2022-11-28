use Kindergarten
go
if OBJECT_ID('Children', 'U') is NOT NULL DROP TABLE Children
go
if OBJECT_ID('Parents', 'U') is NOT NULL DROP TABLE Parents
go

IF OBJECT_ID(N'Delete_child',N'TR') IS NOT NULL
	DROP TRIGGER Delete_child
go

IF OBJECT_ID(N'Update_child',N'TR') IS NOT NULL
	DROP TRIGGER Update_child
go

IF OBJECT_ID(N'Insert_child',N'TR') IS NOT NULL
	DROP TRIGGER Insert_child
go

IF OBJECT_ID(N'Insert_view',N'TR') IS NOT NULL
	DROP TRIGGER Insert_view
go

IF OBJECT_ID(N'Update_view',N'TR') IS NOT NULL
	DROP TRIGGER Update_view
go

IF OBJECT_ID(N'Delete_view',N'TR') IS NOT NULL
	DROP TRIGGER Delete_view
go

IF OBJECT_ID(N'PC_View',N'V') IS NOT NULL
	DROP VIEW PC_View
go


CREATE TABLE Parents (
    Parent_ID int IDENTITY PRIMARY KEY,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    MiddleName NVARCHAR(25) NULL,
    E_mail VARCHAR(50) UNIQUE NOT NULL,
    Gender Bit NOT NULL DEFAULT 0,
);
go

INSERT INTO Parents(FirstName, LastName, MiddleName, E_mail)
VALUES (N'Валерий', N'Жмышенко', N'Альбертович', 'Zmishok@mail.ru'),
        (N'Гриша', N'Йегер', NULL, 'a@yandex.ru')
GO

CREATE TABLE Children (
    Child_ID INT identity PRIMARY KEY,
    FirstName NVARCHAR(25) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    MiddleName NVARCHAR(25) NULL,
    Gender Bit NOT NULL DEFAULT 0,
    Birth_certificate CHAR(10) unique NOT NULL,
    Parent_ID int unique NULL,
    FOREIGN KEY (Parent_ID) REFERENCES Parents (Parent_ID)
);
GO
INSERT INTO Children(FirstName, LastName, MiddleName, Parent_ID, Birth_certificate)
VALUES (N'Денис', N'Жмышенко', N'Валерьевич', '1', '0000000000'),
       (N'Эрен', N'Йегер', NULL,  '2', '0000000001')
GO
-- Пункт 1
-- Удаление

CREATE TRIGGER Delete_child
    ON Children
    AFTER DELETE
AS
    BEGIN
        Delete From Parents Where NOT EXISTS (SELECT * From Children where Parents.Parent_ID = Children.Parent_ID)
    END
GO

DELETE FROM Children Where LastName = N'Жмышенко'
GO

-- Обновление

CREATE TRIGGER Update_child
    ON Children
    FOR UPDATE
AS
    IF UPDATE (Child_ID)
    BEGIN
        THROW 51000, N'Нельзя менять ID', 1
    END
GO


--Update Children
--SET Child_ID = Child_ID + 10
--WHERE Gender = 0
--GO

-- Вставка

CREATE TRIGGER Insert_child
    ON Children
    FOR INSERT
AS
    PRINT N'Вставка прошла успешно'
GO

INSERT INTO Parents(FirstName, LastName, MiddleName, E_mail)
VALUES (N'Валерий', N'Жмышенко', N'Альбертович', 'Zmishok@mail.ru')
GO


INSERT INTO Children(FirstName, LastName, MiddleName, Parent_ID, Birth_certificate)
VALUES (N'Денис', N'Жмышенко', N'Валерьевич', '3', '0000000000')
GO


-- Пункт 2

CREATE VIEW PC_View AS
    SELECT p.FirstName as ParentName, p.LastName as ParentLastName, p.MiddleName as ParentMiddleName, p.E_mail as Email,
        c.FirstName as ChildName, c.LastName as ChildLastName, c.MiddleName as ChildMiddleName, c.Birth_certificate as Birth_certicicate
    FROM Parents as p INNER JOIN Children as c ON c.Parent_ID = p.Parent_ID
GO

SELECT * FROM PC_View
GO


-- Вставка

CREATE TRIGGER Insert_view
    ON PC_View
    INSTEAD OF INSERT
AS
    BEGIN
        if (EXISTS(SELECT Email, count(*) from inserted group by Email having count(*) > 1)) THROW 51000, N'Попытка вставить двух одинаковых родителей в одном запросе', 1
        if (EXISTS(SELECT Birth_certicicate, count(*) from inserted group by Birth_certicicate having count(*) > 1)) THROW 51000, N'Попытка вставить двух одинаковых детей в одном запросе', 1

        insert into Parents(FirstName, LastName, MiddleName, E_mail)
        SELECT ParentName, ParentLastName, ParentMiddleName, Email
        FROM inserted

        declare @t table (
            FN NVARCHAR(25),
            LN NVARCHAR(25),
            MN NVARCHAR(25),
            BC CHAR(10),
            PI int
                         )
        insert into @t(FN, LN,MN, BC, PI)
        select i.ChildName, i.ChildLastName, i.ChildMiddleName, i.Birth_certicicate, p.Parent_ID
        from inserted as i join Parents as p on i.Email = p.E_mail

        INSERT INTO Children(FirstName, LastName, MiddleName, Birth_certificate, Parent_ID)
        select * from @t

    end
go

INSERT INTO PC_VIEW(ParentName, ParentLastName, ParentMiddleName, Email, ChildName, ChildLastName, ChildMiddleName, Birth_certicicate)
values (N'Сергей', N'Пират', NULL, 'talant@yandex.ru', N'Отмена', N'тп', N'на аме', '0000000002')
go

Select * FROM Parents
GO

SELECT * from Children
go


-- Удаление

create trigger Delete_view
    on PC_View
    INSTEAD OF delete
AS
    begin
        delete from Children where Children.Birth_certificate in (SELECT Birth_certicicate from deleted)
    end
go

delete from PC_View where Birth_certicicate = '0000000002'
go
select * from Children
go

-- Обновление

create trigger Update_view
    on PC_View
    INSTEAD OF update
as
    begin
        Update Children SET Children.FirstName = inserted.ChildName, Children.LastName = inserted.ChildLastName, Children.MiddleName = inserted.ChildMiddleName, Children.Birth_certificate = inserted.Birth_certicicate
                            from inserted where Children.Birth_certificate = inserted.Birth_certicicate
        Update Parents SET Parents.FirstName = inserted.ParentName, Parents.LastName = inserted.ParentLastName, Parents.MiddleName = inserted.ParentMiddleName, Parents.E_mail = inserted.Email
                       from inserted where Parents.E_mail = inserted.Email
    end
go

update PC_View
set ChildName = N'Сменили имя'  where ParentName = N'Гриша' or ParentName = N'Валерий'
GO

select *
from Children
go

