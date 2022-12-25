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

-- Создание горизонтально фрагментированных таблиц
use Kindergarten
go

if OBJECT_ID(N'Mentors', N'U') is not null
    drop table Mentors
go

Create table Mentors (
    Mentor_ID int primary key not null check (Mentor_ID < 3),
    First_name NVARCHAR(25) NOT NULL,
    Last_name NVARCHAR(25) NOT NULL,
    Middle_name NVARCHAR(25) NULL,
    Email VARCHAR(50) NOT NULL unique
)

go

IF OBJECT_ID(N'firstInsert',N'TR') IS NOT NULL
	DROP TRIGGER firstInsert
go

create trigger firstInsert on Mentors
after  insert
as
    begin
        if (exists(select inserted.Email from inserted join Kindergarten1.dbo.Mentors as m on inserted.Email = m.Email)) THROW 51000, N'Такой email уже существует', 1
    end
go
IF OBJECT_ID(N'firstUpdate',N'TR') IS NOT NULL
	DROP TRIGGER firstUpdate
go


create trigger firstUpdate on Mentors
    after update
    as
    begin
        if update(Mentor_ID) throw 51000,  N'Нельзя менять ID', 1
        if (exists(select inserted.Email from inserted join Kindergarten1.dbo.Mentors as m on inserted.Email = m.Email)) THROW 51000, N'Такой email уже существует', 1
    end
go


use Kindergarten1
go

if OBJECT_ID(N'Mentors', N'U') is not null
    drop table Mentors
go


Create table Mentors (
    Mentor_ID int primary key not null check (Mentor_ID >= 3),
    First_name NVARCHAR(25) NOT NULL,
    Last_name NVARCHAR(25) NOT NULL,
    Middle_name NVARCHAR(25) NULL,
    Email VARCHAR(50) NOT NULL unique
)
go


IF OBJECT_ID(N'secondInsert',N'TR') IS NOT NULL
	DROP TRIGGER secondInsert
go

create trigger secondInsert on Mentors
after  insert
as
    begin
        if (exists(select inserted.Email from inserted join Kindergarten.dbo.Mentors as m on inserted.Email = m.Email)) THROW 51000, N'Такой email уже существует', 1
    end
go

IF OBJECT_ID(N'secondUpdate',N'TR') IS NOT NULL
	DROP TRIGGER secondUpdate
go
create trigger secondUpdate on Mentors
    after update
    as
    begin
        if update(Mentor_ID) throw 51000,  N'Нельзя менять ID', 1
        if (exists(select inserted.Email from inserted join Kindergarten.dbo.Mentors as m on inserted.Email = m.Email)) THROW 51000, N'Такой email уже существует', 1
    end
go

use Kindergarten
go


if Object_ID(N'MentorsView', N'V') is NOT null
drop view MentorsView
go

create view MentorsView as
select * from Kindergarten.dbo.Mentors
union all
select * from Kindergarten1.dbo.Mentors
go

use Kindergarten1
go

if Object_ID(N'MentorsView', N'V') is NOT null
drop view MentorsView
go

create view MentorsView as
select * from Kindergarten.dbo.Mentors
union all
select * from Kindergarten1.dbo.Mentors
go

insert into MentorsView values
    (1, N'Иггер', N'Егр', N'Егросович', 'h@mail.ru'),
    (2, N'Эрен', N'Йегер', NULL, 'h@yandex.ru'),
    (3, N'Иггер', N'Егр', N'Егросович', 'a@mail.ru'),
    (4, N'Эрен', N'Йегер', NULL, 'a@yandex.ru')

go

select * from MentorsView
select * from Kindergarten.dbo.Mentors
select * from Kindergarten1.dbo.Mentors
go

delete from MentorsView
where Mentor_ID = 3
select * from Kindergarten.dbo.Mentors
select * from Kindergarten1.dbo.Mentors
go

Update MentorsView
set First_name = N'A'
where Mentor_ID = 1

select * from Kindergarten.dbo.Mentors
select * from Kindergarten1.dbo.Mentors
go
