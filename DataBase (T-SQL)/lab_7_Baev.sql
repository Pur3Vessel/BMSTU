use Kindergarten
go
 

UPDATE Mentors
SET LastName =  N'Йегер'
Where LastName = N'ыыыыаааа'
GO
if OBJECT_ID(N'MentorsView',N'V') is NOT NULL
	DROP VIEW MentorsView;
go
if OBJECT_ID(N'ParentsChildrenView',N'V') is NOT NULL
	DROP VIEW ParentsChildrenView;
go
if EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_Mentor_name')
    DROP INDEX IX_Mentor_name ON Mentors
GO
if OBJECT_ID(N'MentorsIndexView',N'V') is NOT NULL
	DROP VIEW MentorsIndexView;
go
if EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_Mentor_clust')
    DROP INDEX IX_Mentor_clust ON Mentors
GO
-- Создание представления
CREATE VIEW MentorsView AS
	SELECT *
	FROM Mentors
go

SELECT * FROM MentorsView
GO

-- Создание представления на основе полей двух связанных таблиц


CREATE VIEW ParentsChildrenView AS
SELECT c.FirstName as name, c.LastName as lastname, p.FirstName as parent_name, p.LastName as p_lastname
FROM Children as c INNER JOIN Parents as p ON c.Parent_ID = p.Parent_ID
GO 

SELECT * FROM ParentsChildrenView
GO

-- Создание индекса для одной из таблиц, включив в него дополнительные неключевые поля
CREATE INDEX IX_Mentor_name
    ON Mentors(FirstName)
        INCLUDE (LastName, MiddleName)
GO

SELECT FirstName, LastName, MiddleName FROM Mentors
ORDER BY FirstName
GO
-- Создание индексированного представления

CREATE VIEW MentorsIndexView
WITH SCHEMABINDING
AS
    SELECT E_mail, FirstName, LastName, MiddleName
    FROM dbo.Mentors
GO

CREATE UNIQUE CLUSTERED INDEX IX_Mentor_clust
    ON MentorsIndexView(E_mail)
GO

SELECT * FROM MentorsIndexView
GO

UPDATE Mentors
SET LastName = N'ыыыыаааа'
Where LastName = N'Йегер'
GO


SELECT * FROM MentorsIndexView
GO



SELECT * FROM sys.indexes
WHERE name = N'IX_Mentor_name' OR name = N'IX_Mentor_clust'
GO