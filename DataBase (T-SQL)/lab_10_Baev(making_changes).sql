use Kindergarten
go

-- Грязное чтение
/*
begin transaction
    select * from Mentors
    update Mentors set Salary = 50000 where Mentor_ID = 2
    waitfor delay '00:00:15'
    rollback
    select * from Mentors
    select resource_type, resource_description, request_mode from sys.dm_tran_locks
go
*/

-- Невоспроизводимое чтение
/*
begin transaction
    select * from Mentors
    update Mentors set Salary = 10000 where Mentor_ID = 1
    select * from Mentors
    select resource_type, resource_description, request_mode from sys.dm_tran_locks
    commit transaction
go
*/

-- Фантомное чтение
/*
begin transaction
    insert into Mentors(FirstName, LastName, MiddleName, E_mail, Salary) VALUES (N'He', N'He', NULL, 'a@rambler.ru', 15000)
    select resource_type, resource_description, request_mode from sys.dm_tran_locks
    commit transaction
go
*/


