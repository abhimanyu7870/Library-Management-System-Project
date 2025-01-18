
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


-- '''''''''''''''''''''''''''Project Query''''''''''''''''''''''''''''''''''

-- ''''''''''''''''''''''''''''CRUD Operations'''''''''''''''''''''''''
        -- Create: Inserted sample records into the books table.
        -- Read: Retrieved and displayed data from various tables.
        -- Update: Updated records in the members table.
        -- Delete: Removed records from the issued_status table.

-- Query 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Query 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;


-- Query 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121'; -- to check which record to be deleted

DELETE FROM issued_status
WHERE issued_id = 'IS121';
select * from issued_status;


-- Query 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


-- Query 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    isu.issued_emp_id,
     e.emp_name,
     COUNT(*)
FROM issued_status as isu
JOIN
employees as e
ON e.emp_id = isu.issued_emp_id
GROUP BY isu.issued_emp_id, 2 -- we can put name and serial number by which we select
HAVING COUNT(isu.issued_emp_id) > 1

-- '''''''''''''''''''''CTAS(Create Table as Select) Operation''''''''''''''''''''''

-- Query 6: Create Summary Tables: Used CTAS to generate new tables based on query results each book and total book_issued_count

CREATE TABLE book_summary
AS    
SELECT 
    b.isbn,
    b.book_title,
    COUNT(isu.issued_id) as no_issued
FROM books as b
JOIN
issued_status as isu
ON isu.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM
book_summary;

-- '''''''''''''''''''''''''Data Searching Operations''''''''''''''''''''''''''

-- Query 7. Retrieve All Books in a History Category:

SELECT * FROM books
WHERE category = 'History'
    
-- Query 8: Find Total Rental Income by Category of issued book:

SELECT
    b.category,
	isu.issued_book_name,
    SUM(b.rental_price),
    COUNT(*)
FROM books as b
JOIN
issued_status as isu
ON isu.issued_book_isbn = b.isbn
GROUP BY 1,2;


-- Query 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'   
    

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C218', 'sam', '145 Main St', '2024-12-01'),
('C219', 'john', '133 Main St', '2024-11-01'); -- while inserting record please check the date



-- Query 10:List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees as e1
JOIN  
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id


-- Query 11:  Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7;

SELECT * FROM 
books_price_greater_than_seven


-- Query 12: Retrieve the List of Books Not Yet Returned

SELECT 
    DISTINCT isu.issued_book_name
FROM issued_status as isu
LEFT JOIN
return_status as rs
ON isu.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

----- After this insert data or run the library_alter_data_query sql file then start Query 13


-- '''''''''''''''''Advanced SQL Operations'''''''''''

/*
Query 13:
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the issued_member_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 

SELECT 
    isu.issued_member_id,
    m.member_name,
    bk.book_title,
    isu.issued_date,
    -- rs.return_date,
    CURRENT_DATE - isu.issued_date as overdues_days
FROM issued_status as isu
JOIN 
members as m
    ON m.member_id = isu.issued_member_id
JOIN 
books as bk
ON bk.isbn = isu.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = isu.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - isu.issued_date) > 30
ORDER BY 1


/*    
Query 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

-- Manual Steps to update book status record

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';
-- IS104

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

-- 
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', CURRENT_DATE, 'Good');
SELECT * FROM return_status
WHERE issued_id = 'IS130';


-- Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function add 3 parameter while calling
-- rerurn_id
-- issued_id
-- book_quality
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');



/*
Query 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books;

SELECT * FROM return_status;

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(isu.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as isu
JOIN 
employees as e
ON e.emp_id = isu.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = isu.issued_id
JOIN 
books as bk
ON isu.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;



-- Query 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;


SELECT * FROM active_members;
 
-- Query 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


SELECT 
    e.emp_name,
    b.*,
    COUNT(isu.issued_id) as no_book_issued
FROM issued_status as isu
JOIN
employees as e
ON e.emp_id = isu.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2;

/*
Query 18: Identify Members Issuing High-Risk Books**
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.
*/

SELECT
	m.member_id,
	m.member_name,
	isu.issued_book_name,
	COUNT(*)
FROM return_status AS rs
JOIN issued_status AS isu ON rs.issued_id = isu.issued_id
JOIN members AS m ON m.member_id = isu.issued_member_id
WHERE rs.book_quality = 'Damaged'
GROUP BY 1, 3
HAVING COUNT(*) > 2;
