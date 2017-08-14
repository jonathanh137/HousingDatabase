CREATE TABLE BRANCH(BranchNo INTEGER PRIMARY KEY,BranchPhone INTEGER,Street VARCHAR(20),City VARCHAR(20),Zip INTEGER);

CREATE TABLE EMPLOYEE(EmpId INTEGER PRIMARY KEY,BranchNo INTEGER,Name VARCHAR(20),Phone INTEGER,StartDate DATE,JobDes VARCHAR(10), 
CONSTRAINT EMPLOYEE_cons1 CHECK (JobDes in ('Manager','Supervisor','Staff')),
CONSTRAINT EMPLOYEE_fkey FOREIGN KEY(BranchNo) REFERENCES Branch(BranchNo));

CREATE TABLE PropOwner(PropOwnerId VARCHAR(20) PRIMARY KEY,Name VARCHAR(20),Street VARCHAR(20),City VARCHAR(20),Zip INTEGER,Phone INTEGER,Fee NUMBER(15,2));

CREATE TABLE RentalProp(RentNo INTEGER PRIMARY KEY,PropOwnerId VARCHAR(20),Street VARCHAR(20),City VARCHAR(20),Zip INTEGER,RoomNo INTEGER,MonthlyRent NUMBER(10,2),Status VARCHAR(15),AvailDate DATE,SuperId INTEGER,
CONSTRAINT RentalProp_cons1 CHECK (Status in ('available','not-available','leased')),
CONSTRAINT RentalProp_fkey1 FOREIGN KEY(SuperId) REFERENCES Employee(EmpId),
CONSTRAINT RentalProp_fkey2 FOREIGN KEY(PropOwnerId) REFERENCES PropOwner(PropOwnerId));

CREATE TABLE LeaseAgreement(RentNo INTEGER,RentName VARCHAR(20),HomePhone INTEGER,WorkPhone INTEGER,ContactName VARCHAR(20),StartDate DATE,EndDate DATE, DepAmount NUMBER(10,2),RentAmount NUMBER(10,2),
CONSTRAINT lease_fkey FOREIGN KEY(RentNo) REFERENCES RentalProp(RentNo) ON DELETE CASCADE,
CONSTRAINT lease_cons1 CHECK (EndDate-StartDate <= 366 AND EndDate-StartDate >= 182),
CONSTRAINT lease_cons2 CHECK (DepAmount >= RentAmount));

