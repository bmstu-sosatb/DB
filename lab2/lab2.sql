-- 1. ���������
--��� ����� � ���� ����

select *
from Flights join PF on Flights.FlightNumber = PF.FlightNumber
where year(PF.FlightDate) = year(getdate());

-- 2. between
--��� �����, �������������� � 12 �� 17

select *
from Flights
where DepartingTime between '12:00:00' and '17:00:00';

-- 3. like
--��������� �� ������ mountain � ��������
select *
from Airports
where Name like '%Mountain%';


-- 4. in
--����� ����������, ������� � ������� �� ������

select FirstName, SecondName
from Passengers
where PassID in
	(select PassID
	from PF
	where FlightDate between '2019-08-01' and  ('2020-01-01'));


-- 5. exists
--������, � ������� ��� ������

select distinct City
from Airports
where exists
	(select City
	from Airports left join Flights on Airports.AirportID = Flights.AirportArriveID
	where AirportArriveID is null);


-- 6. �������� ��������� � ���������
--��������� �����, ��� ��� ������ ������� (�� ������� �����)

select distinct FirstName, SecondName, FlightDate
from Passengers join PF on Passengers.PassID = PF.PassID
	join Flights on PF.FlightNumber = Flights.FlightNumber
where month(FlightDate) = month(getdate()) 
	and ArrivalTime > all
	(select DepartingTime
	from PF join Flights on PF.FlightNumber = Flights.FlightNumber
	where month(FlightDate) = month(getdate()));


-- 7. ����������
--���������� ����������, ���������� �������

select count(distinct PassID) as 'cnt_today'
from PF 
where day(FlightDate) = day(getdate());

-- 8. ��������� ���������� � ���������� ��������
--����� ������� � ����� ������ ������ �� ���������

select Name,
	(select max(DepartingTime)
	from Flights
	where Flights.AirportDepartID = Airports.AirportID)
	as 'LatestDeparting',
	(select min(DepartingTime)
	from Flights
	where Flights.AirportDepartID = Airports.AirportID)
	as 'EarliestDeparting'
from Airports
where AirportID in
	(select AirportDepartID
	from Flights);

-- 9. ������� ��������� CASE
--������ ������ � ����� ��� �����

select Flights.FlightNumber, FlightDate,
	case year(FlightDate)
		when year(getdate()) + 1 then 'Next Year'
		when year(getdate()) then 'This year'
		else cast(datediff(year, FlightDate, getdate()) as varchar(5)) + ' year(s) ago'
	end as 'When'
from Flights join PF  on Flights.FlightNumber = PF.FlightNumber;

-- 10. ��������� ��������� CASE
--����� �����, �������� � ��� ��������� � ������� ���

select FlightNumber, Company, ArrivalTime,
	case
		when ArrivalTime < '05:00:00' then 'very early'
		when ArrivalTime < '09:00:00' then 'early'
		when ArrivalTime < '18:00:00' then 'ok'
		when ArrivalTime < '21:00:00' then 'late'
		else 'very late'
	end as 'Daytime'
from Flights;

-- 11. �������� ����� ��������� ��������� �������
--����� � ��������� � ���� ������

select FlightNumber, PassId
into #Thismonth
from PF
where month(FlightDate) = month(getdate());

select *
from #Thismonth;

-- 12. ��������� ��������������� ���������� � �������� ����������� ������ � ����������� FROM
--��������, �� �������� ������ ����� ������� � ���������� �������

select Name, MostDepartCNT
from Airports A join
	(select top(1) AirportDepartID, count(FlightNumber) as MostDepartCNT
	from Flights
	group by AirportDepartID
	order by MostDepartCNT desc) as MD on A.AirportID = MD.AirportDepartID;

-- 13. ��������� ���������� � ������� ����������� 3
--��������, �� �������� ������ ����� �������

select Name
from Airports
where AirportID = 
	(select AirportDepartID 
	from Flights
	group by AirportDepartID
	having count(FlightNumber) = 
		(select max(DepartCNT)
		from
			(select count(FlightNumber) as DepartCNT
			from Flights
			group by AirportDepartID) as DC
		)
	);

-- 14. group by ��� having
--���������� ���������� �� �����

select year(FlightDate) as 'Years', count(distinct PassID) as 'CNT'
from PF
group by (year(FlightDate));

-- 15. group by � having
--ID ����������, � ������� ��������� ������ ������ 12

select AirportArriveID, max(ArrivalTime) as 'MaxArrivalTime'
from Flights
group by AirportArriveID
having max(ArrivalTime) between '00:00:00' and '12:00:00';
	

-- 16. insert ���� ������

insert Passengers (PassID, FirstName, SecondName, PassportNumber)
values (3000, 'Fname', 'Sname', 111111111);

select *
from Passengers
where PassID = 3000;

-- 17. insert ����� ������ ����������
-- �������� ��� ���� ���� ����� ������ ����������� �����������

insert Flights(AirportDepartID, AirportArriveID, FlightNumber, ArrivalTime, DepartingTime, Company)
select(select top(1) AirportDepartID
		from Flights
		group by AirportDepartID
		order by count(FlightNumber) desc
		),
		(select top(1) AirportArriveID
		from Flights
		group by AirportArriveID
		order by count(FlightNumber) desc
		), FlightNumber - 1, '16:16:00', '13:13:00', 'Company'
from Flights
where  FlightNumber = (select top(1) FlightNumber
						from Flights
						order by FlightNumber);

select *
from Flights
where Company = 'Company';


-- 18. update �������

update Passengers
set PassportNumber = 666666666
where PassID = 3000;

select *
from Passengers
where PassID = 3000;

-- 19. UPDATE �� ��������� ����������� � ����������� SET
-- �������� ����� ������: ����������� - �����������, �������� - ������������ 

update Flights
set DepartingTime = 
				(select min(DepartingTime)
				from Flights),
	ArrivalTime = 
				(select max(ArrivalTime)
				from Flights)
where Company = 'Company';

select *
from Flights
where Company = 'Company';


delete Flights
where Company = 'Company';

-- 20. delete �������
delete Passengers
where PassID = 3000;

select *
from Passengers
where PassID = 3000;

-- 21. DELETE � ��������� ��������������� ����������� � ����������� WHERE
-- ������� ��� ���������� ���������, ������ ��� �������

insert Airports(AirportID, Name, City)
values(3000, 'SVO', 'Moscow');

select *
from Airports
where City = 'Moscow';

delete Airports
where AirportID in
	(select A.AirportID
	from Airports A left outer join Flights F on A.AirportID = F.AirportDepartID
	where F.AirportDepartID is null and City = 'Moscow');


-- 22. ������� ���������� ��������� ���������
-- departings

with Departings(Airport, DepartQty)
as
(select AirportDepartID, count(*) as cnt
from Flights
group by AirportDepartID)
select max(DepartQty) as 'max departings'
from Departings;




-- 23. ����������� ���������� ��������� ���������

create table Airplane (
    ContainingAssembly varchar(20),
    ContainedAssembly varchar(20),
    QuantityContained int,
    UnitCost int);

insert into Airplane Values ( 'Plane', 'Fuselage',1, 10);
insert into Airplane Values ( 'Plane', 'Wings', 1, 11);
insert into Airplane Values ( 'Plane', 'Tail',1, 12);
insert into Airplane Values ( 'Fuselage', 'Saloon', 1, 13);
insert into Airplane Values ( 'Fuselage', 'Cabin', 1, 14);
insert into Airplane Values ( 'Fuselage', 'Nose',1, 15);
insert into Airplane Values ( 'Saloon', NULL, 1,13);
insert into Airplane Values ( 'Cabin', NULL, 1, 14);
insert into Airplane Values ( 'Nose', NULL, 1, 15);
insert into Airplane Values ( 'Wings', NULL,2, 11);
insert into Airplane Values ( 'Tail', NULL, 1, 12);

select *
from Airplane;


-- ��������� ������ ������ �� ����� �� �������������
with list_of_parts(assembly1, quantity, cost) as
    (select ContainingAssembly, QuantityContained, UnitCost
     from Airplane
     where ContainedAssembly is null
     union all
        select a.ContainingAssembly, a.QuantityContained, l.quantity * l.cost
        from list_of_parts l, Airplane a
        where l.assembly1 = a.ContainedAssembly)
select assembly1 'detail', sum(quantity) as 'qty of parts' , sum(cost) as 'cost'
from list_of_parts
group by assembly1;

drop table Airplane;

-- 24. ������� �������. ������������� ����������� MIN/MAX/AVG OVER()
-- ������������ ����� ����������� �� ������� ��������� 

select distinct Name, max(DepartingTime) over(partition by AirportID) as 'MaxDepartTime'
from Airports A join Flights F on F.AirportDepartID = A.AirportID;



-- 25. ������� ������� ��� ���������� ������
-- ������������ ����� ����������� �� ������� ���������

select Name, max(DepartingTime) over(partition by AirportID) as 'MaxDepartTime'
into NewTable
from Airports A join Flights F on F.AirportDepartID = A.AirportID;

select *
from NewTable;

with T(AirName, MDT, RN) as
(select Name, MaxDepartTime, row_number() over(partition by Name order by Name ) as RN
from NewTable)
delete T
where RN > 1;

select *
from NewTable;


drop table NewTable;







select Name, MaxDepartTime
from
	(select Name, max(DepartingTime) over(partition by AirportID) as 'MaxDepartTime', 
			row_number() over(partition by Name order by AirportID ) as RN
	from Airports A join Flights F on F.AirportDepartID = A.AirportID) as Depart;
where RN = 1;
