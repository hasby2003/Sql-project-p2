SQL PROJECT P2 part 2


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;


/*Task 13: Identify Members with Overdue Books 
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.
on this task, you should display 4 column with each column is in a different table, so to do this task you should join 4 table on your database.
isseued_status = members = books = return_status
filter books which is return 
overdue > 30
*/
select 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	rs.return_date,
	current_date - ist.issued_date as over_dues_days
from issued_status as ist
join 
members as m
	on m.member_id = ist.issued_member_id
join
books as bk
	on bk.isbn = ist.issued_book_isbn
left join
return_status as rs
	on rs.issued_id = ist.issued_id
where 
	rs.return_date is null
	and
	(current_date - ist.issued_date) > 30
order by 1


/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "yes " when they are returned (based on entries in the return_status table).
*/
-- to do this task you should use 'procedure.' procedure can make it possible to perform a syntax repeatedly without rewriting the syntax. 
-- procedure syntax is:
create or replace procedure procedure_name (write your paramater with data type) -- parameter is optional depend on your need, 
language plpgsql
as $$

declare -- ini optional, all variable

begin 
	-- all your logic and code/isi dari prcedure tersebut
end;
$$
-- perlu diingat bahwa dalam pembuatan procedure tiap kali selesai membuat satu pernyataan harus selalu diakhiri dengan tanda ';'

-- let's use this 
create or replace procedure add_return_records(p_return_id varchar(10), p_issued_id varchar(10), p_book_quality varchar(15))
language plpgsql
as $$
declare
	v_isbn varchar (50);
	v_book_name varchar (50);
begin
	insert into return_status(return_id, issued_id, return_date, book_quality) -- 2. dimasukan ke sini
	values
	(p_return_id, p_issued_id, current_date, p_book_quality); -- 1. yang akan diisi oleh user
	
	select 
		issued_book_isbn,
		issued_book_name
		into
		v_isbn,
		v_book_name
	from issued_status
	where issued_id = p_issued_id;
	
	update books
	set status = 'yes'
	where isbn = v_isbn;
raise notice 'Thank you for returning book %', v_book_name; -- untuk memunculkan kalimat setelah data dimasukan

end;
$$

call add_return_records('RS138', 'IS135', 'Good') -- example: to use procedure you should write this syntax and entry the value of parameter

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

select * from branch

select * from issued_Status

select * from employees


create table branch_report
as
select 
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as number_book_issued,
	count(rs.return_id) as number_of_book_return,
	sum(bk.rental_price) as total_revenue
from issued_Status as ist
join
	employees as e
on e.emp_id = ist.issued_emp_id
join 
	branch as b
on b.branch_id = b.branch_id
left join 
	return_status as rs
on rs.issued_id = ist.issued_id
join 
	books as bk
on ist.issued_book_isbn = bk.isbn
group by 1, 2

select * from branch_report


/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.
*/
-- on this case you can use 'sub querry' to find the member who issued the book at least 6 month on issued_status table.

create table active_members
as
select * from members
where
	member_id in (select 
						distinct issued_member_id
					from issued_Status
					where 
						issued_date > current_date - interval '6 month');
select * from active_members;


/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/

select * from issued_status;
select * from employees;

select 
	emp.emp_name,
	ist.issued_emp_id,
	count(ist.issued_book_name) as no_book_issued,
	b.*
from issued_status as ist
join
	employees as emp
on ist.issued_emp_id = emp.emp_id
join 
	branch as b
on emp.branch_id = b.branch_id 
group by 1, 2, 4
order by count(ist.issued_book_name) desc
limit 3;



/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
*/
select * from members;
select * from issued_status;
select * from return_status;
select * from books;

select
	m.member_name,
	ist.issued_book_name as title,
	rs.return_date as date_book_damaged,
	rs.book_quality as book_condition
from issued_status as ist
join
	members as m
on ist.issued_member_id = m.member_id
join 
	return_status as rs
on ist.issued_id = rs.issued_id
where rs.book_quality = 'Damaged';


select * from books;
select * from issued_status;

/* Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance or return. 
the procedure as fungtion as follows:

1. the stored procedure should take the book_id as an imput parameter. the procedure should first check if the book is available (status = 'yes').
2. if the book available, it should be issued, and the status in the books table should be updated to 'no'.
3. if the book is not available (status = 'no'), the procedure should return an eror message indicating that the book is curently not available. 
*/


select * from books;
select * from issued_status;


create or replace procedure issue_book(p_issued_id varchar(10), p_issued_member_id varchar(30), P_issued_book_isbn varchar(30), p_issued_emp_id varchar(10))
language plpgsql
as $$

declare
	v_status varchar(10);
	
begin
	select 
		status -- checking if book is available
		into
		v_status
	from books
	where isbn = p_issued_book_isbn; 
	
	if v_status = 'yes' then 

	insert into issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		values (p_issued_id, p_issued_member_id, current_date, P_issued_book_isbn, p_issued_emp_id);

		update books
			set status = 'no'
		where isbn = p_issued_book_isbn;
		
		raise notice 'Book record successfully for book isbn : %', P_issued_book_isbn;
	else
		raise notice 'Sorry to inform you the book you have request is unavailable book_isbn : %', P_issued_book_isbn;
	end if;
end
$$

call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

call issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

select *
from books
where isbn = '978-0-375-41398-8'


/*Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
description: write CTAS querry to create a new table that lists each member and the books they have issued but not returned within 30 days.
the table should include: the number of overdue books, the total fines, which each days calculated at $ 0.50. the number of books issued by
each member. the resulting table should show: member_id, number of overdue and books total fines.
*/

select * from members;
select * from return_status;
select * from issued_status;


create table overdue_book_fines
as (select
		m.member_id,
		m.member_name,
		rs.return_date - ist.issued_date as number_of_overdue,
		sum(rs.return_date - ist.issued_date) * 0.50 as total_fines
	from members as m
	join 
		issued_status as ist
	on m.member_id = ist.issued_member_id
	join 
		return_status as rs 
	on ist.issued_id = rs.issued_id
	where rs.return_date - ist.issued_date >30
	group by 1,3
	order by m.member_name asc);


select * from overdue_book_fines;