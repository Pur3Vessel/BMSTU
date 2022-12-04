use Kindergarten
go
--SET transaction isolation level read uncommitted

SET transaction isolation level read committed

--SET transaction isolation level repeatable read

--SET transaction isolation level serializable


-- Грязное чтение

begin transaction
select * from Mentors
select resource_type, resource_description, request_mode from sys.dm_tran_locks
commit transaction
go


-- Невоспоизводимое чтение
/*
begin transaction
select * from Mentors
WAITFOR delay '00:00:10'
select * from Mentors
select resource_type, resource_description, request_mode from sys.dm_tran_locks
commit transaction
go
*/


-- Фантомное чтение
/*
begin transaction
select * from Mentors
WAITFOR delay '00:00:10'
select * from Mentors
select resource_type, resource_description, request_mode from sys.dm_tran_locks
commit transaction
go
*/
