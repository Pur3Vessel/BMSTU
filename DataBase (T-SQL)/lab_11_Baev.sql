USE master;
go
IF DB_ID('Kindergarten') is NOT NULL DROP DATABASE Kindergarten
go
if OBJECT_ID('Classes', 'U') is NOT NULL DROP TABLE Classes
go
if OBJECT_ID('Mentors', 'U') is NOT NULL DROP TABLE Mentors
go
if OBJECT_ID('Children', 'U') is NOT NULL DROP TABLE Children
go
if OBJECT_ID('Parents', 'U') is NOT NULL DROP TABLE Parents
go
if OBJECT_ID('Child_visits', 'U') is NOT NULL DROP TABLE Child_visits
go
IF OBJECT_ID(N'ParentInsertView',N'V') IS NOT NULL
	DROP VIEW ParentInsertView
go
IF OBJECT_ID(N'ParentInsert',N'TR') IS NOT NULL
	DROP TRIGGER ParentInsert
go

IF OBJECT_ID(N'ChildrenUpdate',N'TR') IS NOT NULL
	DROP TRIGGER ChildrenUpdate
go

IF OBJECT_ID(N'ChildrenDelete',N'TR') IS NOT NULL
	DROP TRIGGER ChildrenDelete
go

IF OBJECT_ID(N'ViewDelete',N'TR') IS NOT NULL
	DROP TRIGGER ViewDelete
go
IF OBJECT_ID(N'ViewUpdate',N'TR') IS NOT NULL
	DROP TRIGGER ViewUpdate
go
IF OBJECT_ID(N'ViewInsert',N'TR') IS NOT NULL
	DROP TRIGGER ViewInsert
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


--Создание таблиц

Create table Parents (
    Parent_ID int primary key identity NOT NULL,
    First_name NVARCHAR(25) not null,
    Last_name NVARCHAR(25) not null,
    Middle_name NVARCHAR(25) null,
    Date_of_birth date not null,
    Gender bit NOT NULL default 0,
    Telephone Char(11) not null,
    Address nvarchar(80) not null,
    E_mail varchar(64) unique not null,
    Document_type int not null,
    Document_id char(10) not null,
    unique(Document_type, Document_id)
)

create table Children(
    Child_ID int primary key identity NOT NULL,
    First_name NVARCHAR(25) not null,
    Last_name NVARCHAR(25) not null,
    Middle_name NVARCHAR(25) null,
    Date_of_birth date not null,
    Gender bit NOT NULL default 0,
    Study_group int not null,
    Document_type int not null,
    Document_id char(10) not null,
    unique(Document_type, Document_id),
    Parent_ID int not null,
    FOREIGN KEY (Parent_ID) REFERENCES Parents (Parent_ID)
)

Create table Mentors (
    Mentor_ID int primary key identity NOT NULL,
    First_name NVARCHAR(25) not null,
    Last_name NVARCHAR(25) not null,
    Middle_name NVARCHAR(25) null,
    Date_of_birth date not null,
    Gender bit NOT NULL default 0,
    Telephone Char(11) not null,
    Address nvarchar(80) not null,
    E_mail varchar(64) unique not null,
    Document_type int not null,
    Document_id char(10) not null,
    unique(Document_type, Document_id),
    Qualification int not null,
    Salary int not null,
    Work_group int not null
)

CREATE table Classes (
    Class_ID int PRIMARY KEY identity NOT NULL,
    Class_group int not null,
    Date date not null,
    unique(Class_group, Date),
    Subject NVARCHAR(50) null,
    Mentor_ID int not null,
    FOREIGN KEY (Mentor_ID) REFERENCES Mentors(Mentor_ID)
)

create table Child_visits (
    Class_ID int not null,
    Child_ID int not null,
    primary key (Class_ID, Child_ID),
    foreign key (Class_ID) references Classes(Class_ID),
    foreign key (Child_ID) references Children(Child_ID)
)
go

create view ParentInsertView
as
    select p.First_name as Parent_name, p.Last_name as Parent_last_name, p.Middle_name as Parent_middle_name,p.Date_of_birth as Parent_date, p.Gender as Parent_gender,
    p.Telephone as Telephone, p.Address as Address, p.E_mail as E_mail, p.Document_type as Parent_type, p.Document_id as Parent_docID,
    c.First_name as Child_name, c.Last_name as Child_last_name, c.Middle_name as Child_middle_name, c.Date_of_birth as Child_date, c.Gender as Child_gender,
    c.Study_group as Child_group, c.Document_type as Child_type, c.Document_id as Child_docID
    from Parents as p join Children as c on p.Parent_ID = c.Parent_ID
go

create trigger ParentInsert
    on Parents
    instead of INSERT
as
    begin
        THROW 51000, N'Пожалуйста, используйте ParentInsertView для вставки в Parents', 1
    end
go

create trigger ChildrenUpdate
    on Children
    after update
as
    begin
        if UPDATE(Parent_ID) THROW 51000, N'Ребенок не может менять родителя', 1
    end
go

create trigger ChildrenDelete
    on Children
    after delete
as
        begin
            Delete From Parents Where NOT EXISTS (SELECT * From Children where Parents.Parent_ID = Children.Parent_ID)
        end
go

create trigger ViewUpdate
    on ParentInsertView
    instead of update
as
    begin
        THROW 51000, N'Вы не можете пользоваться этим представлением для обновления', 1
    end
go
create trigger ViewDelete
    on ParentInsertView
    instead of delete
as
    begin
        THROW 51000, N'Вы не можете пользоваться этим представлением для удаления', 1
    end
go


create trigger ViewInsert
    on ParentInsertView
    instead of insert
as
    begin
        if (EXISTS(SELECT Child_docID, count(*) from inserted group by Child_docID having count(*) > 1)) THROW 51000, N'Попытка вставить двух одинаковых детей в одном запросе', 1
        if (EXISTS(SELECT Parents.E_mail from Parents join inserted on Parents.E_mail = inserted.E_mail)) THROW 51000, N'Попытка вставить существующего родителя', 1
        if (EXISTS(SELECT Child_docID from Children join inserted on Children.Document_id = inserted.Child_docID)) THROW 51000, N'Попытка вставить существующего ребенка', 1

        insert into Parents(First_name, Last_name, Middle_name, Date_of_birth, Gender, Telephone, Address, E_mail, Document_type, Document_id)
        SELECT distinct Parent_name,Parent_last_name,Parent_middle_name,Parent_date,Parent_gender,Telephone,Address,E_mail,Parent_type,Parent_docID
        FROM inserted

        INSERT INTO Children(First_name, Last_name, Middle_name, Date_of_birth,Gender, Study_group, Document_type, Document_id,Parent_ID)
        select i.Child_name, i.Child_last_name, i.Child_middle_name, i.Child_date, i.Child_gender,i.Child_group, i.Child_type, i.Child_docID,p.Parent_ID
        from inserted as i join Parents as p on i.E_mail = p.E_mail
    end

go


