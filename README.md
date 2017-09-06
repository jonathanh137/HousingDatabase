# Rental Management System

The system is designed to assist the rental manager to keep track of rental properties and lease agreements using a relational database for data and transaction management.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

1. setup Oracle database
2. logon to Oracle server

### Installing

1. Execute SQL commands from project_createtable.sql
```
SQL> start <Path/project_createtable.sql> or SQL> @<Path/project_createtable.sql>
```
2. Execute SQL commands from project_createtrigger.sql

## Running the tests

1. Create several test transaction functions by copying and pasting into command line from project_transactions.sql  (Only the ones that start with CREATE OR REPLACE PROCEDURE)
```
CREATE OR REPLACE PROCEDURE NewLease(RentNo IN LeaseAgreement.RentNo%type,Name IN LeaseAgreement.RentName%type,HomeP IN LeaseAgreement.HomePhone%type,WorkP IN LeaseAgreement.WorkPhone%type,ConName IN LeaseAgreement.ContactName%type,SDate IN LeaseAgreement.StartDate%type,EDate IN LeaseAgreement.EndDate%type,Deposit IN LeaseAgreement.DepAmount%type,Rent IN LeaseAgreement.RentAmount%type)
AS
BEGIN
INSERT INTO LEASEAGREEMENT VALUES(RentNo,Name,HomeP,WorkP,ConName,SDate,EDate,Deposit,Rent);
END;
/
show errors;
```
*This block creates a function that will create a new lease with the given parameters.*

2. Insert test values from project_values.sql separately indicated from newline or comments.
```
INSERT INTO BRANCH VALUES(34232,7678934,'800 Main Street','SF',94116);
INSERT INTO BRANCH VALUES(45321,7685734,'201 Post Street','SF',94116);
INSERT INTO BRANCH VALUES(63452,7445734,'521 1st Street','SJ',95112);
INSERT INTO EMPLOYEE VALUES(6577,34232,'Jerry',3874115,'31-JAN-10','Manager');
INSERT INTO EMPLOYEE VALUES(6273,45321,'Dom',4349825,'31-MAR-10','Manager');
INSERT INTO EMPLOYEE VALUES(5632,63452,'Sam',9845435,'01-FEB-10','Manager');
INSERT INTO EMPLOYEE VALUES(6341,34232,'Bill',3842171,'03-APR-12','Manager');
```
*This block shows that only one manager can be in charge of one branch.* 

3. Execute some created functions. Examples in project_values.sql.
```
execute NewLease(32434,'Bob',7646452,6546322,'Larry','14-JAN-16','21-JUL-16',900.00,63.13);
```

