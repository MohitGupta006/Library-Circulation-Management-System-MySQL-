
-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
 -- SELECT * from issued_status


INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 day,  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 day,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;

/*
 Task 13: Identify Members with Overdue Books
 Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
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

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
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

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 6 months.
*/

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

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
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

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have return books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

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


/*Task 19: Stored Procedure Objective:
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/



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


/*Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.
The table should include: The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/
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




