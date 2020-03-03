--а1) скалярная функция
--сколько человек летит в этом месяце
if object_id(N'DepThisMonthCNT', N'FN') is not null
drop function DepThisMonthCNT;
go

create function DepThisMonthCNT()
returns  int
as
begin
	return
	(select count(*)
	from PF
	where month(FlightDate) = month(getdate()))
end;
go


select dbo.DepThisMonthCNT() as 'cntThisMonth';
go

--а2) подставляемая табличная функция
-- кол-во рейсов у каждого пассажира, который летит

if object_id(N'PassFlightCNT', N'FN') is not null
drop function PassFlightCNT;
go

create function PassFlightCNT()
returns table
as
return
	(select FirstName, SecondName, count(*) as CNT
	from Passengers P join PF on P.PassID = PF.PassID
	group by P.PassID, FirstName, SecondName);
go

select *
from PassFlightCNT()
order by CNT;


--а3) многооператорная табличная функция
--пассажир, откуда и куда летит

if object_id(N'PassCity', N'FN') is not null
drop function PassCity;
go

create function PassCity()
returns @PC table
(
	FirstName varchar(100) not null,
	SecondName varchar(100) not null,
	CityDep varchar(100) not null,
	CityArr varchar(100) not null,
	FlightNumber int not null
)
as
begin
	insert into @PC
	select FirstName, SecondName, A1.City as CityDep, A2.City as CityArr, F.FlightNumber
	from Passengers P join PF on P.PassID = PF.PassID
		join Flights F on F.FlightNumber = PF.FlightNumber
		join Airports A1 on A1.AirportID = F.AirportDepartID
		join Airports A2 on A2.AirportID = F.AirportArriveID
return
end;
go

select *
from PassCity();
go



--а4) рекурсивная функция или функция с рекурсивным ОТВ
-- возведение целого числа х в целую неотрицательную степень n

if object_id(N'sqr', N'FN') is not null
drop function sqr;
go

create function sqr(@x int, @n int)
returns int
with returns null on null input
as
begin
	declare @res int
	set @res = null
	if @n >= 0 begin
		with Numbers(result, num)
		as
		(select 1, 0
		union all
		select result * @x, num + 1
		from Numbers
		where num < @n)
		select @res = result
		from Numbers
	end
	return @res
end;
go

select dbo.sqr(-3,3);
go


--b1) хранимая процедура без параметров или с параметрами
--переносит все полеты с заданной даты на 1 день и выводит перенесенные рейсы

if object_id(N'DelayFlight', N'P') is not null
drop proc DelayFlight;
go

create proc DelayFlight
@fdate as date
as
begin
	select PassID, FlightNumber
	from PF
	where FlightDate = @fdate;

	update PF
	set FlightDate = dateadd(d, 1, FlightDate)
	where FlightDate = @fdate;
end;
go

select *
from PF
where FlightDate = '2020-08-11';

exec dbo.DelayFlight @fdate = '2020-08-11';
go


--b2)рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
--люди с id от start до stop полетят на nd дней позже

if object_id(N'DelayOnID', N'P') is not null
drop proc DelayOnID;
go

select *
into #PFCopy
from PF;
go

create proc DelayOnID
@start as int = 1,
@stop as int = 200,
@nd as int = 1
as
begin
	if @start <= @stop
	begin
		update #PFCopy
		set FlightDate = dateadd(d, @nd, FlightDate)
		where PassID = @start;
		set @start = @start + 1;
		exec DelayOnID @start, @stop, @nd;
	end		
end;
go

select *
from #PFCopy
where PassID between 200 and 300
order by FlightDate;

exec DelayOnID 200, 300, 2;
go

--b3)хранимая процедура с курсором
--люди с id от start до stop полетят на nd дней позже

if object_id(N'DelayOnIDCur', N'P') is not null
drop proc DelayOnIDCur;
go


create proc DelayOnIDCur
@start as int = 1,
@stop as int = 200,
@nd as int = 1
as
begin
	declare cur cursor for
	select *
	from #PFCopy
	where PassID between @start and @stop;
	declare @id int, @fn int, @fd date

	open cur
	fetch next from cur into @id, @fn, @fd
	while @@FETCH_STATUS = 0
	begin
		update #PFCopy
		set FlightDate = dateadd(d, @nd, FlightDate)
		where PassID = @id and FlightNumber = @fn and FlightDate = @fd;

		fetch next from cur into @id, @fn, @fd
	end	
	close cur
	deallocate cur
end;
go

select *
from #PFCopy
where PassID between 200 and 300
order by FlightDate;

exec DelayOnID 200, 300, -2;
go

--b4)хранимая процедура доступа к метаданным
--таблицы, количество столбцов и строк в них

if object_id(N'ProcMeta', N'P') is not null
drop proc ProcMeta;
go

create proc ProcMeta
as
begin
	select O.id, O.name, count(*) as ColumnCNT, I.rowcnt
	from sysobjects O join syscolumns C on O.id = C.id
					join sysindexes I on O.id = I.id
	where O.xtype = 'U' and I.indid < 2
	group by O.id, O.name, I.rowcnt	
end;

exec ProcMeta;


--c1)Триггер AFTER
if object_id(N'NewFlight', N'TR') is not null
drop trigger NewFlight;
go

create trigger NewFlight
on PF after insert
as
begin
	declare @info varchar(200)
	set @info = 
	(select P.FirstName+' '+P.SecondName+' flies on '+convert(varchar,I.FlightDate)+', flight number is '+convert(varchar,I.FlightNumber)
	from Inserted I join Passengers P on P.PassID = I.PassID)
	print(@info)
end;


insert into PF(PassID, FlightNumber, FlightDate) values (202, 12096, '2025-01-01');

delete PF
where year(FlightDate) = 2025;

--c2)Триггер INSTEAD OF
if object_id(N'ForbidAddFlight', N'TR') is not null
drop trigger ForbidAddFlight;
go

create trigger ForbidAddFlight
on Flights instead of delete
as
begin
	raiserror('You are enable to delete from this table.', 10, 1)
end;

delete Flights
where FlightNumber between 20000 and 50000;