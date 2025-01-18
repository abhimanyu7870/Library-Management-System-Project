-- ''''''''''''''''''''''''Library Management System Project''''''''''''''''''''''''''

-- '''''''''''''''''''''''''''Database Schema Setup'''''''''''''''''''''''''''''''''''''''''''
         -- CREATE DATABASE library_management
         -- Created tables for Branch, Employee, Members, Books, IssueStatus, ReturnStatus. Each tables consist of relevant columns and relationships between them.


-- Create table "Branch"
drop table if exists branch;
create table branch (
   branch_id      varchar(10) primary key,
   manager_id     varchar(10),
   branch_address varchar(30),
   contact_no     varchar(15)
);


-- Create table "Employee"
drop table if exists employees;
create table employees (
   emp_id    varchar(10) primary key,
   emp_name  varchar(30),
   position  varchar(30),
   salary    decimal(10,2),
   branch_id varchar(10),
   foreign key ( branch_id )
      references branch ( branch_id )
);


-- Create table "Members"
drop table if exists members;
create table members (
   member_id      varchar(10) primary key,
   member_name    varchar(30),
   member_address varchar(30),
   reg_date       date
);



-- Create table "Books"
drop table if exists books;
create table books (
   isbn         varchar(50) primary key,
   book_title   varchar(80),
   category     varchar(30),
   rental_price decimal(10,2),
   status       varchar(10),
   author       varchar(30),
   publisher    varchar(30)
);



-- Create table "IssueStatus"
drop table if exists issued_status;
create table issued_status (
   issued_id        varchar(10) primary key,
   issued_member_id varchar(30),
   issued_book_name varchar(80),
   issued_date      date,
   issued_book_isbn varchar(50),
   issued_emp_id    varchar(10),
   foreign key ( issued_member_id )
      references members ( member_id ),
   foreign key ( issued_emp_id )
      references employees ( emp_id ),
   foreign key ( issued_book_isbn )
      references books ( isbn )
);



-- Create table "ReturnStatus"
drop table if exists return_status;
create table return_status (
   return_id        varchar(10) primary key,
   issued_id        varchar(30),
   return_book_name varchar(80),
   return_date      date,
   return_book_isbn varchar(50),
   foreign key ( return_book_isbn )
      references books ( isbn )
);