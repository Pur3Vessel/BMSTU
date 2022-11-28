use Kindergarten
go
 
IF OBJECT_ID(N'dbo.first_proc', N'P') IS NOT NULL
    DROP PROCEDURE dbo.first_proc
GO

IF OBJECT_ID(N'dbo.second_proc', N'P') IS NOT NULL
    DROP PROCEDURE dbo.second_proc
GO
IF OBJECT_ID(N'dbo.second_proc_v2', N'P') IS NOT NULL
    DROP PROCEDURE dbo.second_proc_v2
GO
IF OBJECT_ID(N'dbo.PRINT_C', N'P') IS NOT NULL
    DROP PROCEDURE dbo.PRINT_C
GO
IF OBJECT_ID(N'dbo.count_same_fullnames', N'FN') IS NOT NULL
    DROP FUNCTION dbo.count_same_fullnames 
GO
IF OBJECT_ID(N'dbo.PREDICATE', N'FN') IS NOT NULL
    DROP FUNCTION dbo.PREDICATE 
GO
IF OBJECT_ID(N'dbo.Form_Table', N'IF') IS NOT NULL
    DROP FUNCTION dbo.Form_Table 
GO

-- Создание хранимой процедуры, которая производит выборку из некоторой таблицы и возвращающую резльтат выборки в виде курсора

CREATE PROCEDURE dbo.first_proc
    @cursor CURSOR VARYING OUTPUT
AS
    SET @cursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT FirstName, LastName, E_mail
    FROM Mentors;

    OPEN @cursor;
    RETURN
GO

DECLARE @mentors_cursor CURSOR;
DECLARE @code int, @name NVARCHAR(25), @email VARCHAR(50), @lname NVARCHAR(25);
EXEC @code = dbo.first_proc @cursor = @mentors_cursor OUTPUT;


FETCH NEXT FROM @mentors_cursor INTO @name, @lname, @email;
PRINT @name + ' ' + @lname + ' ' + @email
WHILE (@@FETCH_STATUS = 0)  
BEGIN;
    FETCH NEXT FROM @mentors_cursor INTO @name, @lname, @email;
    PRINT @name + ' ' + @lname + ' ' + @email
END;


CLOSE @mentors_cursor;
DEALLOCATE @mentors_cursor;
GO

-- Второй пункт

CREATE FUNCTION dbo.count_same_fullnames  (@name NVARCHAR(25), @lastname NVARCHAR(25))
RETURNS INT
AS
BEGIN
    DECLARE @r INT;
    SELECT @r = COUNT(FirstName) FROM Mentors
    WHERE FirstName = @name AND LastName = @lastname

RETURN @r
END;
GO
CREATE PROCEDURE dbo.second_proc
    @cursor CURSOR VARYING OUTPUT
AS
    SET @cursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT FirstName, LastName, E_mail, dbo.count_same_fullnames(FirstName, LastName) AS count_same
    FROM Mentors;

    OPEN @cursor;
    RETURN
GO

DECLARE @mentors_cursor CURSOR;
DECLARE @code int, @name NVARCHAR(25), @email VARCHAR(50), @lname NVARCHAR(25);
EXEC @code = dbo.second_proc @cursor = @mentors_cursor OUTPUT;


FETCH NEXT FROM @mentors_cursor INTO @name, @lname, @email, @code;
PRINT @name + ' ' + @lname + ' ' + @email
PRINT @code
WHILE (@@FETCH_STATUS = 0)  
BEGIN;
    FETCH NEXT FROM @mentors_cursor INTO @name, @lname, @email, @code;
    PRINT @name + ' ' + @lname + ' ' + @email 
    PRINT @code
END;

CLOSE @mentors_cursor;
DEALLOCATE @mentors_cursor;
GO

-- Третий пункт

CREATE FUNCTION dbo.PREDICATE (@email VARCHAR(50))
RETURNS INT
AS 
BEGIN
    IF (@email LIKE '%@yandex.ru') RETURN 1
    RETURN 0
END;
GO

CREATE PROCEDURE dbo.PRINT_C 
    @cursor CURSOR VARYING OUTPUT
AS
    DECLARE @inner CURSOR
    DECLARE @name NVARCHAR(25), @email VARCHAR(50), @lname NVARCHAR(25);
    EXEC dbo.first_proc @cursor = @inner OUTPUT
    FETCH NEXT FROM @inner INTO @name, @lname, @email
    IF (dbo.PREDICATE(@email) = 1) PRINT @name + ' ' + @lname + ' ' + @email 
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        FETCH NEXT FROM @inner INTO @name, @lname, @email
        IF (dbo.PREDICATE(@email) = 1) PRINT @name + ' ' + @lname + ' ' + @email 
    END
GO

DECLARE @c CURSOR

EXEC PRINT_C @cursor = @c OUTPUT;
GO


-- Четвертый пункт

CREATE FUNCTION dbo.Form_Table()
RETURNS TABLE
AS
RETURN
(
    SELECT FirstName, LastName, E_mail, dbo.count_same_fullnames(FirstName, LastName) as count_name
    FROM Mentors 
);
GO

CREATE PROCEDURE second_proc_v2
    @cursor CURSOR VARYING OUTPUT
AS
    SET @cursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT * FROM dbo.Form_Table()
    OPEN @cursor
GO

DECLARE @mentors_cursor CURSOR;
DECLARE @code int, @name NVARCHAR(25), @email VARCHAR(50), @lname NVARCHAR(25);
EXEC @code = dbo.second_proc @cursor = @mentors_cursor OUTPUT;


FETCH NEXT FROM @mentors_cursor INTO @name, @lname, @email, @code;
PRINT @name + ' ' + @lname + ' ' + @email
PRINT @code
WHILE (@@FETCH_STATUS = 0)  
BEGIN;
    FETCH NEXT FROM @mentors_cursor INTO @name, @lname, @email, @code;
    PRINT @name + ' ' + @lname + ' ' + @email 
    PRINT @code
END;

CLOSE @mentors_cursor;
DEALLOCATE @mentors_cursor;
GO