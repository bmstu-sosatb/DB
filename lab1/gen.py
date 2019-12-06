from faker import Faker
from faker.providers import person
from faker.providers import company
from faker.providers import address
from faker.providers import date_time
import random
from datetime import time

fake = Faker()
fake.add_provider(person)
fake.add_provider(company)
fake.add_provider(address)
fake.add_provider(date_time)
N = 1000

def create_passengers():
    passport = []
    f = open("passengers.csv", "w")

    for i in range(N):
        pn = random.randint(100000000, 999999999)
        while (pn in passport):
            pn = random.randint(100000000, 999999999)
        passport.append(pn)
        line = "{0},{1},{2},{3}\n".format(i+1, fake.first_name(), fake.last_name(), pn)
        f.write(line)

    f.close()

def create_airports():
    num = 0
    cities = []
    amount = []
    while (num < N):
        city = fake.city()
        while (city in cities):
            city = fake.city()
        cities.append(city)
        am = random.randint(1, 3)
        if (num + am > N):
            am = N - num
        amount.append(am)
        num += am
    f = open("airports.csv", "w")
    k = 1
    for i in range(len(cities)):
        airports = []
        for j in range(amount[i]):
            airport = fake.street_name()
            while (airport in airports):
                airport = fake.street_name()
            line = "{0},{1},{2}\n".format(k, airport, cities[i])
            k += 1
            f.write(line)

    f.close()

def fortime(d):
    if (d >= 0 and d <= 9):
        return "0"+str(d)
    return str(d)

def create_flights():
    flights = []
    f = open("flights.csv", "w")
    for i in range(N):
        flnum = random.randint(10000, 99999)
        while (flnum in flights):
            flnum = random.randint(10000, 99999)
        flights.append(flnum)
        apdep = random.randint(1,1000)
        apar = random.randint(1,1000)
        while (apar == apdep):
            apar = random.randint(1, 1000)
        artime = time()
        deptime = fake.time_object()
        dh = random.randint(1, 15)
        dm = random.randint(0, 60)
        #print((deptime.hour + dh) % 24, deptime.hour + dh, dh)
        artime = artime.replace(hour=((deptime.hour + dh) % 24), minute=((deptime.minute + dm) % 60))
        line = "{0},{1},{2},{3},{4},{5}\n".format(flnum, apdep, apar, fortime(deptime.hour) + ":" + fortime(deptime.minute), fortime(artime.hour) + ":" + fortime(artime.minute), fake.company())
        f.write(line)

    f.close()

def create_pf():
    f = open("pf.csv", "w")
    for i in range(N):
        line = "{0},{1},{2}\n".format(random.randint(1,1000), random.randint(1,1000), fake.date_between(start_date = "-3y", end_date = "+1y"))
        f.write(line)

    f.close()

if __name__ == "__main__":
    '''create_passengers()
    create_airports()
    create_flights()
    create_pf()'''


