#Library Management System 

# Creating Branch Table 
Create Table Branch  
(
branch_id varchar(10) PRIMARY KEY ,	
manager_id 	varchar(10),	
branch_address varchar(55),
contact_no varchar(10)
);

# Creating Employees Table 
Create Table Employees
(
emp_id varchar(10) PRIMARY KEY,
emp_name varchar(25),
position varchar(15),
salary int,
branch_id varchar(10)  #FK
);

# Creating Books table

Create Table Books
(
isbn varchar(20) PRIMARY KEY,
book_title varchar(75),
category varchar(15),
rental_price float,
status varchar(10),
author varchar(35),
publisher varchar(55)
);

# Creating Members table

Create Table Members
(
member_id varchar(15) PRIMARY KEY,
member_name varchar(20),
member_address varchar(75),
reg_date date
);

#  Creating issued_status table
Create Table issued_status
(
issued_id 	varchar(15) PRIMARY KEY,
issued_member_id varchar(15), #FK 
issued_book_name varchar(75),
issued_date	date,
issued_book_isbn	varchar(30), #FK
issued_emp_id varchar(20)   #FK
);

#  Creating return_status table
Create Table return_status
(
return_id varchar(15) PRIMARY KEY,
issued_id varchar(15),
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(20)
);

# Adding Foreign Key 
Alter Table issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

Alter Table issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

Alter Table issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

Alter Table employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

Alter Table return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);




