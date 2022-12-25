use master
go

IF DB_ID('Kindergarten') is NOT NULL DROP DATABASE Kindergarten
go
IF DB_ID('Kindergarten1') is NOT NULL DROP DATABASE Kindergarten1
go

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


CREATE DATABASE Kindergarten1
ON (
    NAME = Kindergarten1_dat,
    FILENAME = '/home/main/kindergarten1_dat.mdf',
    SIZE = 10,
    MAXSIZE = UNLIMITED
)
LOG ON (
    NAME = Kindergarten1_log,
    FILENAME = '/home/main/kindergarten1_log.ldf',
    SIZE = 5,
    MAXSIZE = 25,
    FILEGROWTH = 5
);
go

use Kindergarten
go

if OBJECT_ID(N'Parents',N'U') is NOT NULL
	DROP TABLE Parents;
go

create table Parents (
    Parent_ID int identity primary key,
    First_name NVARCHAR(25) not null,
    Last_name NVARCHAR(25) not null,
    Middle_name NVARCHAR(25) null,
    Email NVARCHAR(50) not null unique
)

use Kindergarten1

if OBJECT_ID(N'Children',N'U') is NOT NULL
	DROP TABLE Children;
go

create table Children (
    Child_ID int identity primary key,
    First_name NVARCHAR(25) not null,
    Last_name NVARCHAR(25) not null,
    Middle_name NVARCHAR(25) null,
    Parent_ID int not null,
)

use Kindergarten


IF OBJECT_ID(N'DeleteParent',N'TR') IS NOT NULL
	DROP TRIGGER DeleteParent
go

create trigger DeleteParent on Parents
after delete
as
    begin
        delete C from Kindergarten1.dbo.Children as C inner join deleted on C.Parent_ID = deleted.Parent_ID
    end
go

use Kindergarten1
go

IF OBJECT_ID(N'InsertChild',N'TR') IS NOT NULL
	DROP TRIGGER InsertChild
go

create trigger InsertChild on Children
after insert
as
    begin
        if exists (select i.Parent_ID from inserted as i where i.Parent_ID not in (Select Parent_ID from Kindergarten.dbo.Parents)) THROW 51000, N'Попытка добавить ребенка с несуществующим родителем', 1
    end
go

IF OBJECT_ID(N'UpdateChild',N'TR') IS NOT NULL
	DROP TRIGGER UpdateChild
go

create trigger UpdateChild on Children
after update
as
    begin
        if UPDATE(Parent_ID) THROW 51000, N'Ребенок не может менять родителя', 1
    end
go

use Kindergarten
go


insert into Parents (First_name, Last_name, Middle_name, Email) values
(N'Валерий', N'Жмышенко', N'Альбертович', 'Zmishok@mail.ru'),
(N'Гриша', N'Йегер', NULL, 'a@yandex.ru')
go

use Kindergarten1
go

insert into Children (First_name, Last_name, Middle_name, Parent_ID) values
(N'Денис', N'Жмышенко', N'Валерьевич', 1),
(N'Богдан', N'Жмышенко', N'Валерьевич', 1),
(N'Эрен', N'Йегер', NULL, 2)
go

use Kindergarten
go

delete from Parents where Parent_ID = 2
select * from Parents
go

select * from Kindergarten1.dbo.Children
go

if Object_ID(N'ParentsChildrenView', N'V') is not null
drop view ParentsChildrenView
go

create view ParentsChildrenView
    as
    select p.First_name as Parent_name, p.Last_name as Parent_Last_name, p.Middle_name as Parent_Middle_name, p.Email as Email,
        c.First_name as Child_name, c.Last_name as Child_Last_name, c.Middle_name as Child_Middle_name from Kindergarten.dbo.Parents as p inner join Kindergarten1.dbo.Children as c on p.Parent_ID = c.Parent_ID
go

select * from ParentsChildrenView



