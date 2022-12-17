-- Lab 6
-- jpino01
-- Dec 3, 2022

USE `BAKERY`;
-- BAKERY-1
-- Find all customers who did not make a purchase between October 5 and October 11 (inclusive) of 2007. Output first and last name in alphabetical order by last name.
-- select columns above 
select customers.FirstName, customers.LastName
-- from customers table
from customers
-- join receipts on customers.CId = receipts.Customer
where not exists (
    select *
    from receipts
    where receipts.SaleDate between "2007-10-05" and "2007-10-11" and customers.CId = receipts.Customer
    order by customers.LastName asc
    );


USE `BAKERY`;
-- BAKERY-2
-- Find the customer(s) who spent the most money at the bakery during October of 2007. Report first, last name and total amount spent (rounded to two decimal places). Sort by last name.
-- define a table to find the sum of all prices
with customerMoney as (
    -- select columns and do computations
    select customers.FirstName, customers.LastName, round(sum(goods.PRICE),2) as "MoneySpent"
    -- from joined tables below
    from customers
    join receipts on receipts.Customer = customers.CId
    join items on items.Receipt = receipts.RNumber
    join goods on goods.GId = items.Item
    where receipts.SaleDate between "2007-10-01" and "2007-10-31"
    -- group by customer id 
    group by customers.CId
)
-- select the columns below
select FirstName, LastName, MoneySpent
-- from new table created
from customerMoney
-- where money spent
where MoneySpent = (
    -- find max of money spent
    select max(MoneySpent)
    -- from new table
    from customerMoney
);


USE `BAKERY`;
-- BAKERY-3
-- Find all customers who never purchased a twist ('Twist') during October 2007. Report first and last name in alphabetical order by last name.

-- select columns
select customers.FirstName, customers.LastName
-- from customers table
from customers
-- find rows where select clause below is not true
where not exists(
    select *
    from receipts, items, goods
    where goods.Food = "Twist" and receipts.Customer = customers.CId and items.Receipt = receipts.RNumber and goods.GId = items.Item and receipts.SaleDate between "2007-10-01" and "2007-10-31"
)
-- sort by lastname 
order by customers.LastName asc;


USE `BAKERY`;
-- BAKERY-4
-- Find the baked good(s) (flavor and food type) responsible for the most total revenue.
-- define table with the WITH statement
with summary as (
    select goods.Flavor, goods.Food, sum(goods.Price) as "sumg"
    from goods, items
    where goods.GId = items.Item
    group by goods.Flavor, goods.Food
) 
-- dispaly Flavor and Food from summary 
select Flavor, Food from summary 
-- find the sumg where sumg is the max from summary
where sumg = ( 
    select
    max(sumg) from summary
);


USE `BAKERY`;
-- BAKERY-5
-- Find the most popular item, based on number of pastries sold. Report the item (flavor and food) and total quantity sold.
-- define new table to find total count of goods sold
with mostPopular as(
    -- select column and count up number of sold goods
    select goods.Flavor, goods.Food, count(*) as "TotalQty"
    -- joined tables
    from goods
    join items on items.Item = goods.GId
    -- group by distinct goods id
    group by goods.GId
)
-- select columns
select Flavor, Food, TotalQty
-- from new formed table
from mostPopular
-- find total quantity
where TotalQty = (
    -- select the max total quantity
    select max(TotalQty)
    -- from new table
    from mostPopular
);


USE `BAKERY`;
-- BAKERY-6
-- Find the date(s) of highest revenue during the month of October, 2007. In case of tie, sort chronologically.
-- define new table to find the sum (of prices) of all goods sold
with highestRevenue as (
    -- select column
    select receipts.SaleDate, sum(goods.Price) as "sumPrice"
    -- from joined tables below
    from receipts
    join items on items.Receipt = receipts.RNumber
    join goods on items.Item = goods.GId
    where receipts.SaleDate between "2007-10-01" and "2007-10-31"
    -- group by distinct sale dates
    group by receipts.SaleDate
)
-- select column
select SaleDate 
-- from new table formed
from highestRevenue
-- where sumPrice
where sumPrice = (
    -- is the max sumPrice
    select max(sumPrice)
    from highestRevenue
);


USE `BAKERY`;
-- BAKERY-7
-- Find the best-selling item(s) (by number of purchases) on the day(s) of highest revenue in October of 2007.  Report flavor, food, and quantity sold. Sort by flavor and food.
-- define new table
with bestSelling as (
    select goods.Flavor, goods.Food, count(*) as "qtySold", sum(goods.Price) as "totalRev"
    from goods
    join items on goods.GId = items.Item
    join receipts on items.Receipt = receipts.RNumber
    where receipts.SaleDate between "2007-10-01" and "2007-10-31"
    group by goods.GId, receipts.SaleDate
)
-- select columns
select Flavor, Food, qtySold
-- from newly formed table
from bestSelling
-- find max of summed revenues
where totalRev = (
    select max(totalRev)
    from bestSelling
);


USE `BAKERY`;
-- BAKERY-8
-- For every type of Cake report the customer(s) who purchased it the largest number of times during the month of October 2007. Report the name of the pastry (flavor, food type), the name of the customer (first, last), and the quantity purchased. Sort output in descending order on the number of purchases, then in alphabetical order by last name of the customer, then by flavor.
-- define new table
with allCake as (
    select goods.Flavor, goods.Food, customers.FirstName, customers.LastName, count(*) as "qtySold"
    from goods
    join items on goods.GId = items.Item
    join receipts on receipts.RNumber = items.Receipt
    join customers on receipts.Customer = customers.CId
    where goods.Food = "Cake" and receipts.SaleDate between "2007-10-01" and "2007-10-31"
    group by goods.Flavor, goods.Food, customers.CId
)
select Flavor, Food, FirstName, LastName, qtySold
from allCake as ac1
where qtySold = (
    select max(qtySold)
    from allCake as ac2
    -- create a correlation
    -- for everyone ac1 flavor find the max in the ac2 flavors that correlate
    where ac1.Flavor = ac2.Flavor
)
order by qtySold desc, LastName asc, Flavor asc;


USE `BAKERY`;
-- BAKERY-9
-- Output the names of all customers who made multiple purchases (more than one receipt) on the latest day in October on which they made a purchase. Report names (last, first) of the customers and the *earliest* day in October on which they made a purchase, sorted in chronological order, then by last name.

-- find all customers last purchase
with lastDay as (
    select LastName, FirstName, max(SaleDate) as "maxSaleDate", Customer as "c1"
    from customers
    join receipts on Customer = CId
    join items on Receipt = RNumber
    join goods on GId = Item
    group by Customer
),
-- find all customers first purchase
firstDay as (
    select min(SaleDate) as "minSaleDate", Customer as "c2"
    from customers
    join receipts on Customer = CId
    join items on Receipt = RNumber
    join goods on GId = Item
    group by Customer
)
-- select columns
select LastName, FirstName, minSaleDate
-- from tables below
from receipts
join lastDay on c1 = Customer and maxSaleDate = SaleDate
join firstDay on c2 = Customer
group by Customer
-- for each customer see if they made multiple purchases
having count(RNumber) > 1
-- sort by earliest day of purchase then by last name
order by minSaleDate, LastName;


USE `BAKERY`;
-- BAKERY-10
-- Find out if sales (in terms of revenue) of Chocolate-flavored items or sales of Croissants (of all flavors) were higher in October of 2007. Output the word 'Chocolate' if sales of Chocolate-flavored items had higher revenue, or the word 'Croissant' if sales of Croissants brought in more revenue.

-- created table for sum of all croissant foods
with saleCro as (
    select goods.Food, sum(Price) as "croCount"
    from goods
    join items on goods.GId = items.Item
    where goods.Food = "Croissant"
    group by goods.Food 
),
-- created table for sum of all chocolate foods
saleCho as (
    select goods.Flavor, sum(Price) as "chocCount"
    from goods
    join items on goods.GId = items.Item
    where goods.Flavor = "Chocolate"
    group by goods.Flavor
)
select
-- output chocolate or croissant depending on sum of price of both food types
case when croCount < chocCount
then 
    "Chocolate"
else
    "Croissant"
end
as "highestRevenue"
-- join two tables
from saleCro join saleCho;


USE `INN`;
-- INN-1
-- Find the most popular room(s) (based on the number of reservations) in the hotel  (Note: if there is a tie for the most popular room, report all such rooms). Report the full name of the room, the room code and the number of reservations.

with popRoom as (
    -- select columns and count up total number of rooms resereved
    select rooms.RoomName, rooms.RoomCode, count(*) as "NumberOfReservations"
    -- from joined tables below
    from rooms
    join reservations on reservations.Room = rooms.RoomCode
    -- group by distinct room code
    group by rooms.RoomCode
)
select RoomName, RoomCode, NumberOfReservations
from popRoom
where NumberOfReservations = (
    select max(NumberOfReservations)
    from popRoom
);


USE `INN`;
-- INN-2
-- Find the room(s) that have been occupied the largest number of days based on all reservations in the database. Report the room name(s), room code(s) and the number of days occupied. Sort by room name.
-- define new table to find all room occupancy numbers
with largestOcc as (
    select rooms.RoomName, rooms.RoomCode, datediff(Checkout, Checkin) as "Occupancy"
    from rooms
    join reservations on rooms.RoomCode = reservations.Room
    group by CODE
)
-- select columns
select RoomName, RoomCode, Occupancy
-- from new table
from largestOcc
-- where the column value
where Occupancy = (
    -- is the max (also from new table formed)
    select max(Occupancy)
    from largestOcc
);


USE `INN`;
-- INN-3
-- For each room, report the most expensive reservation. Report the full room name, dates of stay, last name of the person who made the reservation, daily rate and the total amount paid (rounded to the nearest penny.) Sort the output in descending order by total amount paid.
-- create a new table to find all rates of rooms
with expensiveRes as (
    select RoomName, Checkin, Checkout, LastName, Rate, (datediff(Checkout, Checkin) * Rate) as "Total"
    from rooms
    join reservations on RoomCode = Room
    group by CODE
)
-- select columns
select RoomName, Checkin, Checkout, LastName, Rate, Total
-- from newly created table
from expensiveRes as e1
-- find the max rates
where Total = (
    select max(Total)
    from expensiveRes as e2
    -- create a correlation
    -- for every e1 room row, find the max value in the e2 rows
    where e1.RoomName = e2.RoomName
)
order by Total desc;


USE `INN`;
-- INN-4
-- For each room, report whether it is occupied or unoccupied on July 4, 2010. Report the full name of the room, the room code, and either 'Occupied' or 'Empty' depending on whether the room is occupied on that day. (the room is occupied if there is someone staying the night of July 4, 2010. It is NOT occupied if there is a checkout on this day, but no checkin). Output in alphabetical order by room code. 
-- find all rooms that were occupied in the during july 4
with julyOccupied as (
    select RoomName, Room,
    -- case statment to find all rooms that were occupied during july 4
    case when (Checkin <= "2010-07-04" and Checkout > "2010-07-04")
    then 
        "Occupied" 
    else 
        "Empty"
    end
    as "OccupiedRooms"
    from rooms 
    join reservations on Room = RoomCode
),
-- find all occupants who stayed in room on july 4
occupiedIsTrue as (
    select RoomName, Room, OccupiedRooms
    from julyOccupied
    where OccupiedRooms = "Occupied"
    group by Room
)
-- select columns 
select rooms.RoomName, rooms.RoomCode, ifnull(OccupiedRooms, "Empty") as "Jul4Status"
-- from rooms table 
from rooms
-- left join with occupied table
-- for all null values found replace with empty
left join occupiedIsTrue on occupiedIsTrue.Room = rooms.RoomCode
group by rooms.RoomName, rooms.RoomCode, OccupiedRooms;


USE `INN`;
-- INN-5
-- Find the highest-grossing month (or months, in case of a tie). Report the month name, the total number of reservations and the revenue. For the purposes of the query, count the entire revenue of a stay that commenced in one month and ended in another towards the earlier month. (e.g., a September 29 - October 3 stay is counted as September stay for the purpose of revenue computation). In case of a tie, months should be sorted in chronological order.
-- created table to calculate rate of all reservations
with reservationCost as (
    select Checkin, Checkout, (datediff(Checkout, Checkin) * Rate) as "Price"
    from reservations
),
-- created table to find total revenue for each month
monthlyCost as (
    select monthname(Checkin) as "Month", sum(Price) as "revenueMonth", count(*) as "numReservations"
    from reservationCost
    group by Month
)
-- select columns
select Month, numReservations, revenueMonth
-- from monthlyCost table
from monthlyCost
-- find revenueMonth with the max revenue 
where revenueMonth = (
    select max(revenueMonth)
    from monthlyCost
);


USE `STUDENTS`;
-- STUDENTS-1
-- Find the teacher(s) with the largest number of students. Report the name of the teacher(s) (last, first) and the number of students in their class.

-- define new table to find counts of students
with sumStudents as (
    select Last, First, count(*) as "nstudents"
    from teachers
    join list on list.classroom = teachers.classroom
    group by list.classroom
)
-- select columns
select Last, First, nstudents
-- from newly formed table
from sumStudents
-- where nstudents is max value
where nstudents = (
    select max(nstudents)
    from sumStudents
);


USE `STUDENTS`;
-- STUDENTS-2
-- Find the grade(s) with the largest number of students whose last names start with letters 'A', 'B' or 'C' Report the grade and the number of students. In case of tie, sort by grade number.
-- create new table to find count of students in each grade (with abc lastname)
with numStu as (
    select grade, count(*) as "ABCCount"
    from list
    where left(LastName, 1) = "A" or left(LastName, 1) ="B" or left(LastName, 1) ="C"
    group by grade
)
-- select columns
select grade, ABCCount
-- from newly formed table
from numStu
-- select max count of students out of all grades
where ABCCount = (
    select max(ABCCount)
    from numStu
)
order by grade asc;


USE `STUDENTS`;
-- STUDENTS-3
-- Find all classrooms which have fewer students in them than the average number of students in a classroom in the school. Report the classroom numbers and the number of student in each classroom. Sort in ascending order by classroom.
-- create new table to find count of students
with avgStud as (
    select list.classroom, count(*) as "ns"
    from list
    group by list.classroom
)
-- select columns
select avgStud.classroom, ns
-- from newly formed table
from avgStud
-- where number of students is less than average number of students
where ns < (
    select avg(ns)
    from avgStud
)
order by avgStud.classroom asc;


USE `STUDENTS`;
-- STUDENTS-4
-- Find all pairs of classrooms with the same number of students in them. Report each pair only once. Report both classrooms and the number of students. Sort output in ascending order by the number of students in the classroom.
with pairStu as (
select list.classroom as "classroom1", count(list.classroom) as "count1"
from list
group by list.classroom
)
select pairStu.classroom1,p2.classroom1, pairStu.count1
from pairStu
join pairStu as p2 on pairStu.count1 = p2.count1 and pairStu.classroom1 < p2.classroom1
order by count1 asc;


USE `STUDENTS`;
-- STUDENTS-5
-- For each grade with more than one classroom, report the grade and the last name of the teacher who teaches the classroom with the largest number of students in the grade. Output results in ascending order by grade.
-- create a new table to count number of classrooms
with countClasses as (
   select list.grade, count(distinct teachers.classroom) as "NumClassrooms"
   from teachers
   join list on teachers.classroom = list.classroom
   group by list.grade
),
-- create a table to count the students taught by each teacher
studentsTaught as (
    select list.grade, teachers.Last, count(*) as "students"
    from list
    join teachers on list.classroom = teachers.classroom
    group by teachers.Last, list.grade
),
moreThanOne as (
    select *
    from studentsTaught
    where grade in (
        select grade
        from countClasses
        where NumClassrooms > 1
    )
)
select grade, Last
from moreThanOne as mto1
where students = (
    select max(students)
    from moreThanOne as mto2
    where mto1.grade = mto2.grade
)
order by grade asc;


USE `CSU`;
-- CSU-1
-- Find the campus(es) with the largest enrollment in 2000. Output the name of the campus and the enrollment. Sort by campus name.

-- select columns
select campuses.Campus, enrollments.Enrolled
-- from joined tables below
from campuses
join enrollments on campuses.Id = enrollments.CampusId
-- get rows based on condition below
where enrollments.Year = 2000 and enrollments.Enrolled = (
    select max(enrollments.Enrolled)
    from enrollments
    where enrollments.Year = 2000
);


USE `CSU`;
-- CSU-2
-- Find the university (or universities) that granted the highest average number of degrees per year over its entire recorded history. Report the name of the university, sorted alphabetically.

-- define table to find sums of all campus' degrees
with highestDeg as (
    select campuses.Campus, sum(degrees) as "totalDeg"
    from campuses
    join degrees on Id = CampusId
    group by Id
)
select Campus
from highestDeg
-- find the MAX from total degree
where totalDeg = (
    select max(totalDeg)
    from highestDeg
);


USE `CSU`;
-- CSU-3
-- Find the university with the lowest student-to-faculty ratio in 2003. Report the name of the campus and the student-to-faculty ratio, rounded to one decimal place. Use FTE numbers for enrollment. In case of tie, sort by campus name.
-- define a new table to get the student to facult ratio 
with sfRatio as (
    select campuses.Campus, round( ( sum(enrollments.FTE) / sum(faculty.FTE) ), 1) as "StudentFacultyRatio"
    from campuses
    join faculty on faculty.CampusId = campuses.Id
    join enrollments on enrollments.CampusId = campuses.Id
    -- in 2003
    where enrollments.Year = 2003 and faculty.Year = 2003 
    group by campuses.Id
)
-- select columns from new table
select Campus, StudentFacultyRatio
from sfRatio
-- find the MIN value
where StudentFacultyRatio = (
    select min(StudentFacultyRatio)
    from sfRatio
);


USE `CSU`;
-- CSU-4
-- Among undergraduates studying 'Computer and Info. Sciences' in the year 2004, find the university with the highest percentage of these students (base percentages on the total from the enrollments table). Output the name of the campus and the percent of these undergraduate students on campus. In case of tie, sort by campus name.
-- define new table with percent of CS students to total enrolled
with csStu as (
    select disciplines.Id, sum(discEnr.Ug), campuses.Campus , ( (sum(discEnr.Ug / enrollments.Enrolled)) * 100 ) as "PercentCS"
    from campuses
    join discEnr on campuses.Id = discEnr.CampusId
    join disciplines on disciplines.Id = discEnr.Discipline
    join enrollments on enrollments.CampusId = campuses.Id
    where disciplines.Name = "Computer and Info. Sciences" and discEnr.Year = 2004 and enrollments.Year = 2004
    group by disciplines.Id, campuses.Campus, enrollments.Enrolled
)
-- select columns
select Campus, PercentCS
-- from new table 
from csStu
-- find max percent of CS students
where PercentCS = (
    select max(PercentCS)
    from csStu
);


USE `CSU`;
-- CSU-5
-- For each year between 1997 and 2003 (inclusive) find the university with the highest ratio of total degrees granted to total enrollment (use enrollment numbers). Report the year, the name of the campuses, and the ratio. List in chronological order.
-- create new table to find ratio 
with highRatio as (
    select degrees.Year, campuses.Campus, ( max((degrees.degrees) / (enrollments.Enrolled)) ) as "DPE"
    from campuses
    join degrees on degrees.CampusId = campuses.Id
    join enrollments on enrollments.CampusId = campuses.Id
    -- join on degrees.Year and enrollments.Year are equal
    where (degrees.Year between 1997 and 2003) and (enrollments.Year between 1997 and 2003) and enrollments.Year = degrees.Year
    group by campuses.Campus, enrollments.Year, degrees.Year
)
-- select columns
select Year, Campus, DPE
-- from hr1 table
from highRatio as hr1
-- where DPE is the max
where DPE = (
    select max(DPE)
    from highRatio as hr2
    -- create a correlation
    -- for everyone hr1 Year find the max in the hr2 Years that correlate
    where hr1.Year = hr2.Year
)
order by hr1.Year;


USE `CSU`;
-- CSU-6
-- For each campus report the year of the highest student-to-faculty ratio, together with the ratio itself. Sort output in alphabetical order by campus name. Use FTE numbers to compute ratios and round to two decimal places.
-- create table to find ratio
with campusSF as (
    select campuses.Campus, enrollments.Year, round(sum(enrollments.FTE) / sum(faculty.FTE), 2) as "Ratio"
    from campuses
    join enrollments on campuses.Id = enrollments.CampusId
    join faculty on campuses.Id = faculty.CampusId
    -- join on enrollments.Year and faculty.Year are equal
    where enrollments.Year = faculty.Year
    group by campuses.Campus, enrollments.Year, faculty.FTE, enrollments.FTE
)
-- select columns
select Campus, Year, Ratio
-- from csf1 table
from campusSF as csf1
-- find max Ratio
where Ratio = (
    select max(Ratio)
    from campusSF as csf2
    -- create a correlation (like for loop)
    -- for every csf1 campus that correlates to the csf2 campus find the max ratio of each campus
    where csf1.Campus = csf2.Campus
)
order by Campus asc;


USE `CSU`;
-- CSU-7
-- For each year for which the data is available, report the total number of campuses in which student-to-faculty ratio became worse (i.e. more students per faculty) as compared to the previous year. Report in chronological order.

with worseRatio as (
    select campuses.Campus, faculty.Year, sum(faculty.FTE) / sum(enrollments.FTE) as "ratio"
    from campuses
    join faculty on faculty.CampusId = campuses.Id
    join enrollments on enrollments.CampusId = campuses.Id and enrollments.Year = faculty.Year
    group by faculty.Year, campuses.Campus
)
select Year, count(*) as "Campuses"
from worseRatio as wr1
where ratio < (
    select max(ratio)
    from worseRatio as wr2
    where wr1.Campus = wr2.Campus and wr1.Year = wr2.Year + 1
)
group by Year
order by Year asc;


USE `MARATHON`;
-- MARATHON-1
-- Find the state(s) with the largest number of participants. List state code(s) sorted alphabetically.

-- create new table to find number of participants by state
with largestP as (
    select State, count(*) "numP"
    from marathon
    group by State
)
-- select column
select State
-- from new table created
from largestP
-- find the MAX of nump
where numP = (
    select max(numP)
    from largestP
);


USE `MARATHON`;
-- MARATHON-2
-- Find all towns in Rhode Island (RI) which fielded more female runners than male runners for the race. Include only those towns that fielded at least 1 male runner and at least 1 female runner. Report the names of towns, sorted alphabetically.

-- define new table
with rhRunners as (
    -- select columns and do computations
    select State, Town, sum(Sex = "M") as "maleRunners", sum(Sex = "F") as "femaleRunners"
    from marathon
    where State = "RI" 
    group by Town
    -- for grouped data follow constraints below
    having maleRunners < FemaleRunners and maleRunners != 0 and femaleRunners != 0
)
-- select column
select Town
-- from new table
from rhRunners
order by Town asc;


USE `MARATHON`;
-- MARATHON-3
-- For each state, report the gender-age group with the largest number of participants. Output state, age group, gender, and the number of runners in the group. Report only information for the states where the largest number of participants in a gender-age group is greater than one. Sort in ascending order by state code, age group, then gender.
-- define new table to count number of runners
with gaGroup as (
    select State, AgeGroup, Sex, count(*) as "RunnerCount"
    from marathon
    group by State, AgeGroup, Sex
)
-- select columns
select State, AgeGroup, Sex, RunnerCount
-- from new table
from gaGroup as ga1
-- find the max count for each state (formed a correlation)
where RunnerCount = (
    select max(runnerCount)
    from gaGroup as ga2
    -- formed correlation
    -- for ga1 (table) State row values, find max for values for ga2 rows (with corresponding state value)
    where ga1.State = ga2.State and runnerCount > 1
)
-- sort by condition below
order by State asc, AgeGroup asc, Sex asc;


USE `MARATHON`;
-- MARATHON-4
-- Find the 30th fastest female runner. Report her overall place in the race, first name, and last name. This must be done using a single SQL query (which may be nested) that DOES NOT use the LIMIT clause. Think carefully about what it means for a row to represent the 30th fastest (female) runner.
-- select columns
select Place, FirstName, LastName -- , row_number() over() as "RowNum"
-- from nested select
from (
    -- select columns and create a row counter
    select Place, FirstName, Sex, LastName, row_number() over() as "RowNum"
    -- from marathon table
    from marathon
    -- filter females
    where Sex = "F"
    -- order by place in race
    order by Place
) t
-- find row where rowNum is equal to 30 (30th place)
where RowNum = 30;


USE `MARATHON`;
-- MARATHON-5
-- For each town in Connecticut report the total number of male and the total number of female runners. Both numbers shall be reported on the same line. If no runners of a given gender from the town participated in the marathon, report 0. Sort by number of total runners from each town (in descending order) then by town.

-- define new table to find male and feamle runners
with conTable as (
    select Town, sum(case when Sex = "M" then 1 else 0 end) as "Men", sum(case when Sex = "F" then 1 else 0 end) as "Women", count(*) as "Total"
    from marathon
    -- in state of Connecticut
    where State = "CT"
    group by State, Town
    -- sort by condition below
    order by Total desc, Town asc
)
-- select columns
select Town, Men, Women
-- from new table
from conTable;


USE `KATZENJAMMER`;
-- KATZENJAMMER-1
-- Report the first name of the performer who never played accordion.

-- select column
select Band.FirstName
-- from band table
from Band
-- select where value DOES NOT exist
where not exists (
    select *
    from Instruments
    -- find all instances of accordion AND join on above table with lower table
    where Instrument = "accordion" and Band.Id = Instruments.Bandmate
);


USE `KATZENJAMMER`;
-- KATZENJAMMER-2
-- Report, in alphabetical order, the titles of all instrumental compositions performed by Katzenjammer ("instrumental composition" means no vocals).

-- select columns
select Title 
-- from songs
from Songs
-- select titles where condition DOES NOT exist
where not exists (
    -- select all columns
    select *
    -- from vocals
    from Vocals
    -- join inner table with outer table
    where Vocals.Song = Songs.SongId
)
order by Title asc;


USE `KATZENJAMMER`;
-- KATZENJAMMER-3
-- Report the title(s) of the song(s) that involved the largest number of different instruments played (if multiple songs, report the titles in alphabetical order).
-- create a new table to find count of instruments played for each song
with largestInst as (
    select Title, count(*) as "numInst"
    from Songs
    join Instruments on Songs.SongId = Instruments.Song
    group by Title
)
-- select columns
select Title
-- from newly formed table
from largestInst
-- find max numInst
where numInst = (
    -- select the max count of instruments (for songs)
    select max(numInst)
    from largestInst
)
order  by Title asc;


USE `KATZENJAMMER`;
-- KATZENJAMMER-4
-- Find the favorite instrument of each performer. Report the first name of the performer, the name of the instrument, and the number of songs on which the performer played that instrument. Sort in alphabetical order by the first name, then instrument.

-- create new table to find counts of all instruments played by band members 
with favInst as (
    select Firstname, Instrument, count(*) as "num"
    from Band
    join Instruments on Band.Id = Instruments.Bandmate
    group by Firstname, Instrument
)
-- select columns
select Firstname, Instrument, num
-- from new table (correlation)
from favInst as fi1
-- select favorite (max) instrument played for each band member
where num = (
    select max(num)
    from favInst as fi2
    -- created a correlation
    -- for each band member in fi1, find the max value for row values of that particular band member in fi2
    where fi1.Firstname = fi2.Firstname
)
order by Firstname asc, Instrument asc;


USE `KATZENJAMMER`;
-- KATZENJAMMER-5
-- Find all instruments played ONLY by Anne-Marit. Report instrument names in alphabetical order.
-- create table to find all instruments of anne marit
with anneInstr as (
    select Instruments.Instrument, Band.Firstname
    from Instruments
    join Band on Band.Id = Instruments.Bandmate
    where Band.Firstname = "Anne-Marit"
    group by Instruments.Instrument
)
-- select instruments 
select Instrument
-- from anne marit table
from anneInstr
-- find instruments that were not played by other band members
where Instrument not in (
    select distinct Instruments.Instrument
    from Band
    join Instruments on Band.Id = Instruments.Bandmate
    -- find instruments played by all other band members (excluding anne marit)
    where Band.Firstname != "Anne-Marit"
)
-- sort by instrument in ascending order
order by Instrument asc;


USE `KATZENJAMMER`;
-- KATZENJAMMER-6
-- Report, in alphabetical order, the first name(s) of the performer(s) who played the largest number of different instruments.

with diffInst as (
    select Firstname, count(distinct Instrument) as "countInst"
    from Band
    join Instruments on Band.Id = Instruments.Bandmate
    group by Firstname
)
select Firstname
from diffInst as di1
where countInst = (
    select max(countInst)
    from diffInst as di2
    -- where di1.Firstname = di2.Firstname
);


USE `KATZENJAMMER`;
-- KATZENJAMMER-7
-- Which instrument(s) was/were played on the largest number of songs? Report just the names of the instruments, sorted alphabetically (note, you are counting number of songs on which an instrument was played, make sure to not count two different performers playing same instrument on the same song twice).
-- create table to count number of songs an instrument was played
-- ex. banjo was played 14 times in all songs
with largSongs as (
    select Instruments.Instrument, count(distinct Instruments.Song) as "numInstruments"
    from Instruments
    join Songs on SongId = Instruments.Song
    group by Instruments.Instrument
)
-- select instrument column
select Instrument
-- from largSongs table
from largSongs
-- find numInstruments max value
where numInstruments = (
    select max(numInstruments)
    from largSongs
);


USE `KATZENJAMMER`;
-- KATZENJAMMER-8
-- Who spent the most time performing in the center of the stage (in terms of number of songs on which she was positioned there)? Return just the first name of the performer(s), sorted in alphabetical order.

-- create table to count number of band members who were positioned in center during performance
with mostCenter as (
    select Band.Firstname, count(*) as "centerPosition"
    from Band
    join Performance on Band.Id = Performance.Bandmate
    where Performance.StagePosition = "center"
    group by Band.Id
)
-- select firstname column
select Firstname
-- from most center table
from mostCenter
-- find max count of band members who were positioned in the center
where centerPosition = (
    select max(centerPosition)
    from mostCenter
)
-- sort by firstname in ascending order
order by Firstname asc;


