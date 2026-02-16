# Library-Circulation-Management-System-MySQL
Library Management System built on MySQL using normalized relational schema design, primary and foreign key constraints, CRUD operations, stored procedures, CTAS, CTEs, and transactional logic. Implements circulation workflows, overdue analytics, fine computation, and branch-level performance reporting.

---
### ERD Diagram 
<img width="1227" height="798" alt="Screenshot 2026-02-16 220430" src="https://github.com/user-attachments/assets/f98cc081-7423-42a2-98ac-67c0ac043ea5" />

---

#### Creating Branch Table 
```sql
Create Table Branch  
(
branch_id varchar(10) PRIMARY KEY ,	
manager_id 	varchar(10),	
branch_address varchar(55),
contact_no varchar(10)
);
```
#### Creating Employees Table
```sql
Create Table Employees
(
emp_id varchar(10) PRIMARY KEY,
emp_name varchar(25),
position varchar(15),
salary int,
branch_id varchar(10)  #FK
);
```
#### Creating Books table
```sql
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
```
#### Creating Members table
```sql
Create Table Members
(
member_id varchar(15) PRIMARY KEY,
member_name varchar(20),
member_address varchar(75),
reg_date date
);
```
####  Creating issued_status table
```sql
Create Table issued_status
(
issued_id 	varchar(15) PRIMARY KEY,
issued_member_id varchar(15), #FK 
issued_book_name varchar(75),
issued_date	date,
issued_book_isbn	varchar(30), #FK
issued_emp_id varchar(20)   #FK
);
```
####  Creating return_status table
```sql
Create Table return_status
(
return_id varchar(15) PRIMARY KEY,
issued_id varchar(15),
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(20)
);
```
---
#### Adding Foreign Key 
```sql
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
```
---

### CRUD Operations
#### Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```sql
Insert Into books (isbn, book_title, category, rental_price, status, author, publisher)
Values( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
Select * From books;
```
#### Task 2: Update an Existing Member's Address
```sql
UPDATE members
SET member_address ='125 Main St'
WHERE member_id = 'C101';
Select * From Members;
```
#### Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
Delete From issued_status
WHERE   issued_id =   'IS121';
Select * From issued_status;
```
#### Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'
```sql
SELECT * FROM issued_status
where issued_emp_id = 'E101'
```
#### Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
```sql
SELECT
     issued_emp_id,
     Count(*)
FROM issued_status
GROUP BY 1
HAVING Count(*) > 1
```
#### Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt** joining books and issued_status table on the basis of isbn
```sql
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
```
#### Task 7. Retrieve All Books in a Specific Category: 'Classic'
```sql
Select * From books
WHERE category = 'Classic'
```
---
#### Task 8: Find Total Rental Income by each Category:

##### join books and issued_status as to find a total rental income as to find how many times a book have been issued to find the correct rental icome
```sql
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
```
#### Task 9: List Members Who Registered in the Last 180 Days:
```sql
SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 DAY;

INSERT into members ( member_id ,member_name ,member_address ,reg_date)
values
('C130','Trump', '128 Washington DC', '2026-01-02'),
('C140','Modi', '125 New Delhi', '2025-12-30');
```
#### Task 10: List Employees with Their Branch Manager's Name and their branch details:
```sql
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
```
#### Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7:
```sql
Create Table expensive_books
Select * From books
WHERE rental_price > 7
```
#### Task 12: Retrieve the List of Books Not Yet Returned
```sql
Select 
Distinct issued_book_name
FROM issued_status as ist 
LEFT JOIN 
return_status as rs 
on 
ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL 
```
---
 
-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
 -- SELECT * from issued_status

```sql
INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 day,  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 day,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');
```
#### Adding new column in return_status
```sql
ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;
```
---

#### Task 13: Identify Members with Overdue Books Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
```sql
-- issued_status == members == books == return_status 
Select 
ist.issued_member_id,
m.member_name,
bk.book_title,
ist.issued_date,
rs.return_date,
current_date - ist.issued_date as over_dues_days
 FROM issued_status as ist 
JOIN 
members as m
ON 
m.member_id = ist.issued_member_id
JOIN 
books as bk 
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs 
ON rs.issued_id = ist.issued_id
WHERE 
   rs.return_date IS null
   AND 
   (current_date - ist.issued_date) > 30 
ORDER BY member_name
```
---
#### Task 14: Update Book Status on Return
#### Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
```sql
-- Store Procedure 
DROP PROCEDURE IF EXISTS add_return_records;
DELIMITER //
DROP PROCEDURE IF EXISTS add_return_records;

DELIMITER //

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(15), 
    IN p_issued_id VARCHAR(15),
    IN p_book_quality VARCHAR(15)
)
BEGIN

    DECLARE v_isbn VARCHAR(20);
    DECLARE v_bookname VARCHAR(75);

    -- Fetch book details
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_bookname
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Insert return record
    INSERT INTO return_status
    (return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Update book status
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Confirmation message
    SELECT CONCAT('Thank You For Returning The Book: ', v_bookname) AS message;

END //

DELIMITER ;

-- Testing FUNCTION add_return_records

-- issued_id = IS135
-- ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling functions
CALL add_return_records('RS138', 'IS135', 'Good');
```
---
#### Task 15: Branch Performance Report Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
```sql
Create table branch_report
Select 
b.branch_id,
b.manager_id,
count(ist.issued_id) as number_book_issued,
count(rs.return_id) as num_book_return,
sum(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON
e.emp_id = ist.issued_emp_id
JOIN 
branch as b 
ON 
e.branch_id = b.branch_id
LEFT JOIN 
return_status as rs
ON 
rs.issued_id = ist.issued_id
JOIN 
books as bk
ON 
bk.isbn = ist.issued_book_isbn
GROUP BY 1,2
```
---
#### Task 16: CTAS: Create a Table of Active Members Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.
```sql
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL 2 month
                    )
;

SELECT * FROM active_members;
```
---
#### Task 17: Find Employees with the Most Book Issues Processed Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
```sql
Select 
e.emp_name,
b.*,
count(ist.issued_id) as no_book_issued
FROM issued_status as ist 
JOIN 
employees as e 
ON
ist.issued_emp_id = e.emp_id
JOIN branch as b
ON b.branch_id = e.branch_id
GROUP BY 1,2
```
---
#### Task 18: Identify Members Issuing High-Risk Books Write a query to identify members who have return books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

```sql
Select 
m.member_name,
ist.issued_book_name,
count(*) AS damaged_count
 FROM issued_status as ist 
LEFT JOIN return_status as rs
ON 
rs.issued_id = ist.issued_id
JOIN 
members as m	
ON 
ist.issued_member_id = m.member_id
WHERE rs.book_quality = 'Damaged'

GROUP BY 1 , 2 
HAVING COUNT(*)>2;
```
---
#### Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
```sql
DROP PROCEDURE IF EXISTS issue_book;
DELIMITER //

CREATE PROCEDURE issue_book(IN p_issued_id VARCHAR(15) ,
							IN p_issue_member_id VARCHAR (15),
                            IN p_issued_book_isbn VARCHAR (20),
                            IN p_issued_emp_id VARCHAR(10))

BEGIN 
 
 DECLARE v_status VARCHAR(10);
 
 SELECT 
      status INTO v_status
	  FROM books
 WHERE isbn = p_issued_book_isbn;

IF v_status = 'yes' THEN 
INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
VALUES (p_issued_id, p_issue_member_id, CURRENT_DATE ,  p_issued_book_isbn, p_issued_emp_id);

   -- Update book status
    UPDATE books
      SET status = 'no'
    WHERE isbn = p_issued_book_isbn;


 SELECT CONCAT('Books record added successfully for book isbn : %', p_issued_book_isbn) AS message;
 
ELSE
  SELECT CONCAT('Thank You for requesting sorry to inform u that book u have requested is currently unavailable: %',  p_issued_book_isbn ) AS message;
  END IF;
END

//
DELIMITER ;

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```
---
#### Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines. Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
```sql
Create table overdue_fines
SELECT 
    i.issued_member_id AS member_id,

    -- Number of overdue books
    COUNT(i.issued_id) AS overdue_books,

    -- Total fine calculation
    SUM(
        DATEDIFF(CURRENT_DATE, i.issued_date) - 30
    ) * 0.50 AS total_fines,

    -- Total books issued by member
    COUNT(i.issued_id) AS total_books_issued

FROM issued_status i

LEFT JOIN return_status r
    ON i.issued_id = r.return_id

WHERE r.return_id IS NULL
    AND DATEDIFF(CURRENT_DATE, i.issued_date) > 30

GROUP BY i.issued_member_id;
```
---



