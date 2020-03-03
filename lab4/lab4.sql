exec sp_configure 'clr enabled', 1;  
reconfigure;  
go
alter database Flights set trustworthy on;
go

select * from sys.assemblies
where name='sharp_clr';
go

drop function YearCount;
drop aggregate geometric_mean;
drop function squared_range;
drop procedure copy_flights;
drop trigger alter_handler;
drop type dbo.Human;
drop assembly sharp_clr;
go

create assembly sharp_clr from 'C:\Users\Şëèÿ\Documents\SQL Server Management Studio\flights\CLR\CLR\bin\Debug\CLR.dll'
with PERMISSION_SET = UNSAFE;
go

-- 1. Ñêàëÿğíàÿ ôóíêöèÿ. Êîë-âî ïàññàæèğîâ â çàäàííîì ãîäó
create function YearCount(@year int)
returns int
as
	external name sharp_clr.[CLR.ScalarFuncs].YearCount;
go

select dbo.YearCount(2020) as clr_result;
select count(*) from dbo.PF where year(FlightDate) = 2020;


-- 2. Aggregate. Returns the geometric meaming of values
create aggregate geometric_mean(@input float)
returns float
external name sharp_clr.[CLR.GeometricMean] -- same as sharp_clr."CLR.GeometricMean"
go

select * from Phones
where id > 0 and id < 5;
select dbo.geometric_mean(id) as clr_result from Phones
where id > 0 and id < 5;
go

-- 3. Tàáëè÷íàÿ ôóíêöèÿ. Âîçâğàùàåò òàáëèöó êâàäğàòîâ.
create function dbo.squared_range(@begin int, @end int)
returns table(squared_range int)
as external name sharp_clr.[CLR.TableFuncs].SqrRange;
go

select * from dbo.squared_range(1, 5);
go

-- 4. Õğàíèìàÿ ïğîöåäóğà. Êîïèğóåò âñå ğåéñû â ıòîì ãîäó
create procedure dbo.copy_flights @table_name nvarchar(20)
as
external name sharp_clr.[CLR.StoredProcedures].CopyFlights;
go

exec dbo.copy_flights 'TYPF';
go

select * from TYPF;
select * from PF where year(FlightDate) = year(getdate());
drop table TYPF;
go

-- 5. Trigger. Forbids deleting. If the action is insert, creates a copy of a table and inserts data in a copied table
create trigger dbo.alter_handler on PF
instead of delete, insert
as
external name sharp_clr.[CLR.Triggers].AlterHandler;
go

delete from Manufacturers where id = 999;
select * from Manufacturers where id = 999;
go 

--6. User-defined type. Human(birth date, name, sex)
create type dbo.Flight
external name sharp_clr.[CLR.Flight];
go

declare @person dbo.Human;
set @person  = cast('01-01-1901;Petrov Daniil Yaroslavovich;Male' as dbo.Human);
select @person.ToString()
select @person.age_at('02-01-1905');
go
