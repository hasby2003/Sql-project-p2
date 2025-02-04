-- library management system

-- creating table

-- library management system

-- creating table

create table branch(
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_address varchar(55),
	contact_no varchar(20)
);

alter table branch --bertujuan untuk menambah limit varchar jika pada pembuatal table sebelumnya ternyata limit varchar kurang
alter column contact_no type varchar(20); -- pada tahap ini masukan column yang akan diubah dan limit varchar yang akan diubah


create table employees (
	emp_id varchar(10) primary key,
	emp_name varchar(25),
	position varchar(25),
	salary int,
	branch_id varchar(25) -- foreign key
);

create table books(
	isbn varchar(20) primary key,
	book_title varchar(75),
	category varchar(20),
	rental_price float,
	status varchar(15),
	author varchar(35),
	publisher varchar(55)
);

alter table books
alter column category type varchar(20);


create table members (
	member_id varchar(20) primary key,
	member_name varchar(25),
	member_address varchar(75),
	reg_date date
);

create table issued_status(
	issued_id varchar(10) primary key,
	issued_member_id varchar(10), -- Foreign key
	issued_book_name varchar(75),
	issued_date	date,
	issued_book_isbn varchar(25), -- foreign key
	issued_emp_id varchar(10) -- foreign key
);


create table return_status(
	return_id varchar(10) primary key,
	issued_id varchar(10), -- foreign key
	return_book_name varchar(75),
	return_date date,
	return_book_isbn varchar(20)
);


-- database modeling
-- foreign key (foreign key is a primary key in another table)

alter table issued_status --table awal yang terdapat primary key dari data lain
add constraint fk_members --nama table yang terdapat primary key
foreign key (issued_member_id) --kolom yang merupakan primary key dari data laim yang ada pada table awal
references members(member_id); --table yang berisi primary key tersebut

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn) --disini antara nama kolom yang menjadi primary key di table awal dan di reference tidak sama (tidak mesti selalu sama, yang penting apa yang dimuat dalam table tersebut sama datanya sama)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

--Project task begin
-- Task 1: create a new book record -- "978-1-60129-", 'To kill Mockingbird', 'Classic', '6.00', 'yes', 'Harper le', 'J.B Lippincott & co.')"
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values 
('978-1-60129-2', 'To kill Mockingbird', 'Classic', 6.00, 'yes', 'Harper le', 'J.B Lippincott & co');

--Task 2: Updating an existing members addres
update members
set member_address = '125 Main St'
where member_id = 'C101';

--Task 3: delete record from the issued status table -- objective delete the record with issued_id = 'IS104' from the issued_status table
delete 
from issued_status
where issued_id = 'IS104'

--Task 4: retrieve all books issued by a specific employee -- objective: select all books issued by the employee with emp_id = 'E101'
select *
from issued_status
where issued_emp_id = 'E101'

--Task 5: List member who have issued more than one book -- objective: use group by to find member who have issued more than one book
select
	issued_emp_id,
	count (issued_id) as total_book_issued
from issued_status
group by issued_emp_id
having count(issued_id)>1
--Task 6: create summary tables: used CTAS to generate new tables based on querry result - each book and total book_issued
--pada task ini kita diperinatahkan untuk membuat resume table baru yang memuat setiap buku dan total book_issued
create table book_cnts -- step tujuh: buat select tadi menjadi sebuah table baru
as
select --
	b.isbn, -- step empat: masukan column yang akan ada di table baru tersebut
	b.book_title,
	count(ist.issued_id) as no_issued -- gunakan ini untuk menentukan jumlah issued (total_issued)
from books as b --step pertama: masukan dulu table awal yang akan di join dengan table lain, gunakan as
join-- step kedua: masukan table yang akan di join, gunakan as
issued_status as ist
on ist.issued_book_isbn = b.isbn -- step tiga: masukan column kunci yang akan menghubungkan kedua table (kolom yang isi datanya sama antara kedua table)
group by 1, 2; --step enam: masukan table tersebut akan digolongkan berdasarkan apa

select * from book_cnts


-- Task 7: retrieve all books in specific category
select * from books
where category = 'Classic'


-- Task 8: find total rental income by category (hitung jumlah pendapatan tiap category)
select
	category, -- masukan column yang akan menjadi urutan
	sum(rental_price), --masukan jumlah dari total harga, namun lihat kembali dalam table books hanya ada daftar harga, sedangkan daftar berapa kali buku dengan category tersebut ada di table issued_status
	count(*) -- ditujukan untuk menghitung berapa kali buku dari tiap category dibeli
from books as b
join -- masukan table issued_status karena hanya di table itu ada keterangan berapakali buku dari tiap category dikeluarkan
issued_status as ist
on ist.issued_book_isbn = b.isbn -- masukan column kunci yang akan menghubungkan kedua table
group by 1;


-- Task 9: list the member who registered in the last 180 days (list member yang registrasi selama 180 terakhir)
select * from members
where reg_date >= current_date - interval '180 days' -- pada syntax tersebut dimaksudkan bahwa: data hari ini dikurangi interval '180 hari'


-- Task 10: list employee with their brench manager and their branch details (step nya sama kayak task 6)
select
	e1.*,
	b.branch_id,
	e2.emp_name as manager
from employees as e1 
join 
	branch as b
on e1.branch_id = b.branch_id
join 
	employees as e2
on b.manager_id = e

-- Task 11: create a table of books with rental price above a certain treshold 7USD
create table book_price_greater_than_seven
as
select *
from books
where rental_price > 7

select * from book_price_greater_than_seven


-- Task 12: retrieve the list book not yet returned
select 
	distinct ist.issued_book_name
from issued_status as ist
left join 
return_status as rst
on ist.issued_id = rst.issued_id
where rst.return_id is null


