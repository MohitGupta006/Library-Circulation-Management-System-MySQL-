# PROJECT TASK 
#CRUD Operations
# Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

Insert Into books (isbn, book_title, category, rental_price, status, author, publisher)
Values( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
Select * From books;

#Task 2: Update an Existing Member's Address

UPDATE members
SET member_address ='125 Main St'
WHERE member_id = 'C101';
Select * From Members;

#Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

Delete From issued_status
WHERE   issued_id =   'IS121';
Select * From issued_status;

#Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'
SELECT * FROM issued_status
where issued_emp_id = 'E101'

#Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
     issued_emp_id,
     Count(*)
FROM issued_status
GROUP BY 1
HAVING Count(*) > 1

#Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
#joining books and issued_status table on the basis of isbn
Select * 
FROM books as b 
JOIN 
issued_status as ist
ON 
ist.issued_book_isbn = b.isbn

Create Table book_counts
Select 
b.isbn,
b.book_title,
Count(ist.issued_id) as no_issued 
FROM books as b 
JOIN 
issued_status as ist
ON 
ist.issued_book_isbn = b.isbn
Group By 1,2;

#Task 7. Retrieve All Books in a Specific Category: 'Classic'
Select * From books
WHERE category = 'Classic'

#Task 8: Find Total Rental Income by each Category:

# join books and issued_status as to find a total rental income as to find how many times a book have been issued to find the correct rental icome 
Select * 
FROM books as b 
JOIN 
issued_status as ist
ON 
ist.issued_book_isbn = b.isbn 

Select 
b.category,
sum(b.rental_price) as Total_Income,
Count(*) as no_issued
FROM books as b 
JOIN 
issued_status as ist
ON 
ist.issued_book_isbn = b.isbn 
GROUP BY 1

# Task 9: List Members Who Registered in the Last 180 Days:

SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 DAY;

INSERT into members ( member_id ,member_name ,member_address ,reg_date)
values
('C130','Trump', '128 Washington DC', '2026-01-02'),
('C140','Modi', '125 New Delhi', '2025-12-30');

#List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id

#Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7:
Create Table expensive_books
Select * From books
WHERE rental_price > 7

#Task 12: Retrieve the List of Books Not Yet Returned
Select 
Distinct issued_book_name
FROM issued_status as ist 
LEFT JOIN 
return_status as rs 
on 
ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL 


