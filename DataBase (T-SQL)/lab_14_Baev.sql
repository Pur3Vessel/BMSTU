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

-- Создание вертикально фрагментированных таблиц
use Kindergarten
go

if OBJECT_ID(N'Mentors', N'U') is not null
    drop table Mentors
go

Create table Mentors (
    Mentor_ID int primary key  not null,
    First_name NVARCHAR(25) NOT NULL,
    Last_name NVARCHAR(25) NOT NULL,
    Middle_name NVARCHAR(25) NULL,
)

go


use Kindergarten1
go

if OBJECT_ID(N'Mentors', N'U') is not null
    drop table Mentors
go


Create table Mentors (
    Mentor_ID int primary key  not null,
    Email VARCHAR(50) NOT NULL unique
)
go

use Kindergarten1
go

if Object_ID(N'MentorsView', N'V') is NOT null
drop view MentorsView
go

create view MentorsView as
select m1.Mentor_ID, m1.First_name, m1.Last_name, m1.Middle_name, m2.Email from Kindergarten.dbo.Mentors as m1
inner join Kindergarten1.dbo.Mentors as m2 on m1.Mentor_ID = m2.Mentor_ID
go

IF OBJECT_ID(N'ViewInsertInsert',N'TR') IS NOT NULL
	DROP TRIGGER ViewInsert
go

IF OBJECT_ID(N'ViewUpdate',N'TR') IS NOT NULL
	DROP TRIGGER ViewUpdate
go

IF OBJECT_ID(N'ViewDelete',N'TR') IS NOT NULL
	DROP TRIGGER ViewDelete
go

create trigger ViewInsert
    on MentorsView
    instead of insert
as
    insert into Kindergarten1.dbo.Mentors(Mentor_ID,Email)
    select Mentor_ID, Email from inserted

    insert into Kindergarten.dbo.Mentors(Mentor_ID,First_name, Last_name, Middle_name)
    select Mentor_ID, First_name, Last_name, Middle_name from inserted

go

create trigger ViewUpdate
    on MentorsView
    instead of update
as
    update Kindergarten1.dbo.Mentors set Email = inserted.Email from inserted where Kindergarten1.dbo.Mentors.Mentor_ID = inserted.Mentor_ID
    update Kindergarten.dbo.Mentors set First_name = inserted.First_name, Last_name = inserted.Last_name,
                                        Middle_name = inserted.Middle_name from inserted where Kindergarten.dbo.Mentors.Mentor_ID = inserted.Mentor_ID

go


create trigger ViewDelete
    on MentorsView
    instead of delete
as
    begin
    delete from Kindergarten.dbo.Mentors where  Mentor_ID in (select Mentor_ID from deleted)
    delete from Kindergarten1.dbo.Mentors where  Mentor_ID in (select  Mentor_ID from deleted)
    end
go


insert into MentorsView values
    (1, N'Игге', N'Ег', NULL, 'h@mail.ru'),
    (2, N'Эрен', N'Йегер', NULL, 'h@yandex.ru'),
    (3, N'Игге', N'Ег', NULL, 'a@mail.ru'),
    (4, N'Эрен', N'Йегер', NULL, 'a@yandex.ru')
go

select * from MentorsView
go

select * from Kindergarten.dbo.Mentors
select * from Kindergarten1.dbo.Mentors
go

delete from MentorsView
where Mentor_ID = 3
select * from Kindergarten.dbo.Mentors
select * from Kindergarten1.dbo.Mentors
go

Update MentorsView
set First_name = N'A', Email = 'a@rambler.ru'
where Mentor_ID = 1

select * from Kindergarten.dbo.Mentors
select * from Kindergarten1.dbo.Mentors
go
