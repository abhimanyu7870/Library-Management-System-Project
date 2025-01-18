# Library Management System using PostgreSQL--

## Project Overview**

**Project Title**: Library Management System
**Level**: Intermediate
**Database**: `library_management`

This project aimed to develop a functional Library Management System using PostgreSQL. Through this project, I gained practical experience in database design, data manipulation, and advanced SQL querying. I learned to create and manage database tables, perform CRUD operations, and execute complex SQL queries effectively.


## Objective**

This SQL project aims to design, implement, and analyze a basic Library Management System.
The primary objectives are to:

* **Design and implement a relational database schema** for the library, including tables for branches, employees, members, books, issued books, and returned books.
* **Demonstrate proficiency in SQL DDL and DML operations:**
    * Create, read, update, and delete data within the database tables.
    * Utilize SQL joins to retrieve and analyze data from multiple tables.
* **Apply advanced SQL concepts:**
    * Implement CTAS (Create Table As Select) for data summarization.
    * Utilize subqueries and stored procedures to perform complex data analysis.
* **Analyze and report on library data:**
    * Generate reports on book issuance, member activity, branch performance, and other key metrics.
    * Gain insights into library operations and identify areas for improvement.


## Database Schema Setup**
-- This script defines the database schema for a Library Management System.
-- It includes tables for branches, employees, members, books, issued books, and returned books.

-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY ( branch_id ) REFERENCES branch ( branch_id )
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

-- Create table "IssuedStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY ( issued_member_id ) REFERENCES members ( member_id ),
    FOREIGN KEY ( issued_emp_id ) REFERENCES employees ( emp_id ),
    FOREIGN KEY ( issued_book_isbn ) REFERENCES books ( isbn )
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY ( return_book_isbn ) REFERENCES books ( isbn )
);

## Data Exploration and Validation**
-- These queries are used to initially explore and validate the data in the tables.

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

## CRUD Operations**

-- Query 1: Create a New Book Record
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
SELECT * FROM issued_status
WHERE issued_id = 'IS121'; -- Check the record to be deleted
DELETE FROM issued_status
WHERE issued_id = 'IS121';
select * from issued_status;

-- Query 4: Retrieve All Books Issued by a Specific Employee
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Query 5: List Members Who Have Issued More Than One Book
SELECT
    isu.issued_emp_id,
    e.emp_name,
    COUNT(*)
FROM issued_status as isu
JOIN
employees as e
ON e.emp_id = isu.issued_emp_id
GROUP BY isu.issued_emp_id, e.emp_name
HAVING COUNT(isu.issued_emp_id) > 1;

## CTAS (Create Table As Select) Operation**

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
SELECT * FROM book_summary;

-- Data Searching Operations

-- Query 7: Retrieve All Books in a History Category:
SELECT * FROM books
WHERE category = 'History';

-- Query 8: Find Total Rental Income by Category of issued book:
SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM books as b
JOIN
issued_status as isu
ON isu.issued_book_isbn = b.isbn
GROUP BY 1;

-- Query 9: List Members Who Registered in the Last 180 Days:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Query 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees as e1
JOIN
branch as b
ON e1.branch_id = b.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id;

-- Query 11: Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE books_price_greater_than_seven
AS
SELECT * FROM Books
WHERE rental_price > 7;
SELECT * FROM books_price_greater_than_seven;

-- Query 12: Retrieve the List of Books Not Yet Returned
SELECT
    DISTINCT isu.issued_book_name
FROM issued_status as isu
LEFT JOIN
return_status as rs
ON isu.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

## Advanced SQL Operations**

-- Query 13: Identify Members with Overdue Books
SELECT
    isu.issued_member_id,
    m.member_name,
    bk.book_title,
    isu.issued_date,
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
ORDER BY 1;

-- Query 14: Update Book Status on Return
-- (This section includes sample data insertion and a stored procedure for
-- updating book status on return)
-- Refer to the original response for the complete code.

-- Query 15: Branch Performance Report
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
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT
                        DISTINCT issued_member_id
                    FROM issued_status
                    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    );

SELECT * FROM active_members;

-- Query 17: Find Employees with the Most Book Issues Processed
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

-- Query 18: Identify Members Issuing High-Risk Books

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


## Reports

**1. Database Schema:**

* **Tables:**
    * **branch:** Stores branch-related information (branch_id, manager_id, branch_address, contact_no).
    * **employees:** Stores employee details (emp_id, emp_name, position, salary, branch_id).
    * **members:** Stores member information (member_id, member_name, member_address, reg_date).
    * **books:** Stores book details (isbn, book_title, category, rental_price, status, author, publisher).
    * **issued_status:** Records information about issued books (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id).
    * **return_status:** Records information about returned books (return_id, issued_id, return_book_name, return_date, return_book_isbn).

* **Relationships:**
    * **employees** table has a foreign key referencing the `branch_id` in the **branch** table.
    * **issued_status** table has foreign keys referencing `members`, `employees`, and `books` tables.
    * **return_status** table has a foreign key referencing the `books` table.

**2. Data Analysis & Findings**

* **Book Categories:** The code includes queries to retrieve books in specific categories (e.g., 'History').
* **Employee Salaries:** The code demonstrates how to retrieve employee information, including their salary and branch details.
* **Member Registration Trends:** The code includes a query to list members who registered within the last 180 days.
* **Issued Books:**
    * The code retrieves information about books issued by a specific employee.
    * It also identifies members who have issued more than one book.

**3. Summary Reports**

* **Branch Performance Report:** The code generates a report for each branch, summarizing the number of books issued, returned, and the total revenue generated.
* **Book Summary:** The code creates a summary table using CTAS (Create Table As Select) to show the number of times each book has been issued.

**4. Advanced SQL Operations**

* **Overdue Books:** The code identifies members with overdue books by calculating the difference between the issue date and the current date.
* **Book Status Updates:** The code demonstrates a stored procedure to update the book status to "yes" when a book is returned.
* **Member Activity:** The code identifies members who have issued books more than twice with the status "damaged."

## Learning Outcomes

* **Data Definition Language (DDL):**
    * Creating tables with appropriate data types and constraints.
    * Establishing relationships between tables using foreign keys.
* **Data Manipulation Language (DML):**
    * Performing CRUD operations (Create, Read, Update, Delete) on data within the tables.
* **Advanced SQL Queries:**
    * Using JOIN clauses for data retrieval and relationships.
    * Employing GROUP BY, HAVING, and ORDER BY clauses for data aggregation and analysis.
    * Utilizing subqueries and window functions for more complex data retrieval.
    * Creating and using stored procedures for efficient and reusable code.
* **Data Analysis and Reporting:** Generating reports and insights based on the extracted data, such as identifying trends, analyzing performance, and identifying areas for improvement.

**Developed By:** Abhimanyu Kumar
**Date:** 19-01-2025

This README provides a comprehensive overview of the project, focusing on the key learning outcomes and highlighting the practical applications of the SQL code.

-- Thank You for reviewing this Library Management System project!

-- For further you can connect with me on LinkedIn: (https://www.linkedin.com/in/abhimanyu7870/)