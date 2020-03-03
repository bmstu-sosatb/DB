using System.Data;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;
using System.Collections;


namespace CLR
{
    public class ScalarFuncs
    {
        [SqlFunction(DataAccess = DataAccessKind.Read)]
        public static int YearCount(SqlInt32 year)
        {
            int count = 0;
            using (SqlConnection connection = new SqlConnection("context connection=true"))
            {
                SqlCommand command = connection.CreateCommand();
                connection.Open();
                command.CommandText = "select * from dbo.PF where year(FlightDate) = @year";
                SqlParameter parameter = new SqlParameter("@year", SqlDbType.Int);
                parameter.Value = year;
                command.Parameters.Add(parameter);
                SqlDataReader reader = command.ExecuteReader();
                while (reader.Read())
                {
                    ++count;
                }
                reader.Close();
            }
            return count;
        }
    }

    /*
        [System.Serializable]
        [SqlUserDefinedAggregate(Format.UserDefined, MaxByteSize = 8000)]
        public class GeometricMean : IBinarySerialize
        {
            private double mul;
            private int count;

            public void Init()
            {
                count = 0;
                mul = 1;
            }

            public void Accumulate(SqlDouble value)
            {
                mul *= value.Value;
                ++count;
            }

            public void Merge(GeometricMean other)
            {
                mul *= other.mul;
                count += other.count;
            }

            public SqlDouble Terminate() => System.Math.Pow(mul, 1.0 / count);
            public void Read(System.IO.BinaryReader reader)
            {
                mul = reader.ReadDouble();
                count = reader.ReadInt32();
            }

            public void Write(System.IO.BinaryWriter writer)
            {
                writer.Write(mul);
                writer.Write(count);
            }
        }*/

    public class TableFuncs
    {
        [SqlFunction(FillRowMethodName = "FillRow", TableDefinition = "squared_range int")]
        public static IEnumerable SqrRange(SqlInt32 begin, SqlInt32 end)
        {
            for (int i = begin.Value; i <= end.Value; ++i)
                yield return i * i;
        }

        public static void FillRow(object row, out int squared_range) => squared_range = (int)row;
    }

    public class StoredProcedures
    {
        [SqlProcedure]
        public static void CopyFlights(string table)
        {
            using (SqlConnection connection = new SqlConnection("context connection=true"))
            {
                connection.Open();
                SqlCommand command = new SqlCommand("select * into " + table + " from PF where year(FlightDate) = year(getdate());", connection);
                command.ExecuteNonQuery();
            }
        }
    }
}

public class Triggers
{
    [SqlTrigger]
    public static void AlterHandler()
    {
        SqlTriggerContext triggerContext = SqlContext.TriggerContext;

        if (triggerContext.TriggerAction == TriggerAction.Delete)
            SqlContext.Pipe.Send("Deleting records from this table is forbidden");
        if (triggerContext.TriggerAction == TriggerAction.Insert)
        {
            SqlConnection connection = new SqlConnection("context connection=true"))
            {
                connection.Open();
                SqlCommand command = new SqlCommand("select * into " + table + " from PF where year(FlightDate) = year(getdate());", connection);
                command.ExecuteNonQuery();

            }

    }
}

/*
    
    [System.Serializable]
    [SqlUserDefinedType(Format.UserDefined, IsByteOrdered = true, MaxByteSize = 8000)]
    public class Flight : IBinarySerialize, INullable
    {
        public System.DateTime FlightDate;
        public string name, sex;

        public Human() => name = sex = "";

        public int age_at(SqlDateTime dateTime)
        {
            int years = dateTime.Value.Year - birth_date.Year;
            int months = dateTime.Value.Month - birth_date.Month;
            if (months < 0)
                --years;
            else if (months == 0)
            {
                int days = dateTime.Value.Day - birth_date.Day;
                if (days < 0)
                    --years;
            }
            return years;
        }

        public void Read(System.IO.BinaryReader r)
        {
            int year = r.ReadInt32(), month = r.ReadInt32(), day = r.ReadInt32();
            birth_date = new System.DateTime(year, month, day);
            name = r.ReadString();
            sex = r.ReadString();
        }

        public void Write(System.IO.BinaryWriter w)
        {
            w.Write(birth_date.Year);
            w.Write(birth_date.Month);
            w.Write(birth_date.Day);
            w.Write(name);
            w.Write(sex);
        }

        public static Human Null => new Human();

        public bool IsNull => false;


        public override string ToString()
        {
            System.Text.StringBuilder builder = new System.Text.StringBuilder();
            builder.Append(birth_date);
            builder.Append(";");
            builder.Append(name);
            builder.Append(";");
            builder.Append(sex);
            return builder.ToString();
        }

        [SqlMethod(OnNullCall = false)]
        public static Human Parse(SqlString s)
        {
            if (s.IsNull)
                return new Human();

            Human parsed = new Human();
            string[] data = s.Value.Split(";".ToCharArray());
            parsed.birth_date = System.DateTime.Parse(data[0]);
            parsed.name = data[1];
            parsed.sex = data[2];

            return parsed;
        }
    }
}

*/
