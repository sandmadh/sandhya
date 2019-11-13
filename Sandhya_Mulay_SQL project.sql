/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT 	distinct name,membercost
FROM 		facilities 
WHERE 	membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT 	distinct name
FROM 		facilities 
WHERE 	membercost = 0





/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 	facid as FacilityId
		,name as Facility
		,membercost	as MemberFee
		,monthlymaintenance	as Maintenance
FROM 		Facilities
WHERE 	membercost > 0  
AND		membercost < (monthlymaintenance*20/100  )


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT 	*
FROM 		Facilities
WHERE		facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 	name	as Facility
		,monthlymaintenance as Maintenance
		,(CASE	WHEN monthlymaintenance < 100 then 'CHEAP'
          			WHEN monthlymaintenance > 100 then 'EXPENSIVE'
          			ELSE NULL END ) As Label
FROM 		Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 	firstname as FirstName
		,surname as LastName
FROM 		`Members`
where		joindate = (select	max(joindate)
                    	from		`Members`) 




/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Select	name
		,concat ( firstname ,' ', surname ) as nameOfMember
from		Bookings bk ,Facilities fc , Members mb
where 	bk.facid = fc.facid
and		fc.name like 'Tennis%'
and 		bk.memid = mb.memid 
and 		mb.memid > 0 
group by 	name, nameOfMember
order by name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT	name
		,concat (firstname ,' ' ,surname ) as nameOfMember
		,(case when bk.memid != 0 then (slots * membercost)
			  when bk.memid = 0 then (slots * guestcost)
           		  else 0 END)  as cost
FROM 	Bookings bk, Facilities fc, Members mb
where	substr(trim(starttime),1,10) = '2012-09-14'
and 	bk.facid = fc.facid
and 	bk.memid = mb.memid
and 	(((bk.memid =0) and (fc.guestcost * bk.slots >30))
        or((bk.memid !=0) and (fc.membercost *bk.slots >30)))
order by name,nameOfMember


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select *
from	(SELECT	name as Name
			,concat (firstname ,' ' ,surname ) as nameOfMember
			,(case when bk.memid != 0 then (slots * membercost)
			  	when bk.memid = 0 then (slots * guestcost)
              		else 0 END)  as cost

			FROM 	Bookings bk, Facilities fc, Members mb
			where	substr(trim(starttime),1,10) = '2012-09-14'
			and 	bk.facid = fc.facid
		and 	bk.memid = mb.memid) sub
where	cost >30
order by sub.Name,sub.nameOfMember



/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select *
from	(SELECT	name as Name
		,sum((case when bk.memid != 0 then (slots * membercost)
			  when bk.memid = 0 then (slots * guestcost)
              else 0 END))  as revenue
		FROM 	Bookings bk, Facilities fc, Members mb
		where	bk.facid = fc.facid
		and 	bk.memid = mb.memid
        group by name) sub
where 	sub.revenue < 1000
order by sub.revenue
