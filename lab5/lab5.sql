use Flights;

select P.PassID, FirstName, SecondName,FlightNumber, FlightDate
from Passengers P join PF on PF.PassID = P.PassID
for xml raw('PassID');

select P.PassID, FirstName, SecondName,FlightNumber, FlightDate
from Passengers P join PF on PF.PassID = P.PassID
for xml auto;

select P.PassID, FirstName, SecondName,FlightNumber, FlightDate
from Passengers P join PF on PF.PassID = P.PassID
for xml path;

select 1 as Tag,
null as Parent,
PassID as 'Passengers!1!PassID',
FirstName as 'Passengers!1!FirstName',
SecondName as 'Passengers!1!SecondName',
null as 'PF!2!FlightNumber', 
null as 'PF!2!FlightDate'
from Passengers P
union all
select 2 as Tag, 1 as Parent,
P.PassID, null, null,
FlightNumber,
FlightDate
from Passengers P join PF on PF.PassID = P.PassID
order by P.PassID
for xml explicit;



select *
from Passengers 
for xml path, root('Passengers');

declare @idoc int, @doc xml;
select @doc = c from openrowset(bulk 'C:\Users\Юлия\Documents\SQL Server Management Studio\flights\passengers.xml', single_blob) as temp(c);
exec sp_xml_preparedocument @idoc output, @doc;
select *
from openxml (@idoc, '/Passengers/row',2)
with (PassID int, FirstName varchar(100), SecondName varchar(100), PassportNumber int);
exec sp_xml_removedocument @idoc;