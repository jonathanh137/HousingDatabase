/*List of rental properties available for a specific branch(where the name of the branch is entered as input), along with the manager’s name*/
CREATE OR REPLACE PROCEDURE BranchProps(BranchNum IN Employee.BranchNo%type)
AS	
	Manager VARCHAR(20);
	CURSOR large_cur IS
	SELECT RentNo,RentalProp.Street ||', '|| RentalProp.City ||', '|| RentalProp.Zip Address,RoomNo,MonthlyRent,Status,AvailDate FROM Employee, RentalProp
	WHERE BranchNum = BranchNo AND SuperId=EmpId;
	result_rec large_cur%rowtype;
BEGIN
	IF NOT large_cur%ISOPEN THEN
		OPEN large_cur;
	END IF;
	SELECT Name INTO Manager FROM Employee
	where BranchNum=BranchNo AND JobDes='Manager';
LOOP
	FETCH large_cur INTO result_rec;
	EXIT WHEN large_cur%NOTFOUND;
	dbms_output.put_line('RentNo:'||result_rec.RentNo||', Address:'||result_rec.Address||', # of room(s):'||result_rec.RoomNo||', MonthlyRent:'||result_rec.MonthlyRent||', Status:'||result_rec.Status||', AvailDate:'||result_rec.AvailDate);
END LOOP;
dbms_output.put_line(Manager||' is Manager of Branch '||BranchNum);
close large_cur;
END;
/
show errors;

/*List of supervisors and the properties (with addresses) they supervise*/
SELECT SuperId,RentNo,Street||','||City||','||Zip Address FROM RentalProp;

/*List of rental properties by a specific owner(where the owner’s name is entered as input),listed in a GreenField branch(the branch name is input)*/
CREATE OR REPLACE PROCEDURE OwnerProps(Owner IN PropOwner.Name%type,BranchNum IN Employee.BranchNo%type)
AS	
	CURSOR large_cur IS
	SELECT RentNo,RentalProp.Street ||', '|| RentalProp.City ||', '|| RentalProp.Zip Address,RoomNo,MonthlyRent,Status,AvailDate FROM Employee,RentalProp,PropOwner
	WHERE BranchNum = BranchNo AND SuperId=EmpId AND Owner=PropOwner.name AND RentalProp.PropOwnerId=PropOwner.PropOwnerId;
	result_rec large_cur%rowtype;
BEGIN
	IF NOT large_cur%ISOPEN THEN
		OPEN large_cur;
	END IF;
LOOP
	FETCH large_cur INTO result_rec;
	EXIT WHEN large_cur%NOTFOUND;
	dbms_output.put_line('RentNo:'||result_rec.RentNo||', Address:'||result_rec.Address||', # of room(s):'||result_rec.RoomNo||', MonthlyRent:'||result_rec.MonthlyRent||', Status:'||result_rec.Status||', AvailDate:'||result_rec.AvailDate);
END LOOP;
close large_cur;
END;
/
show errors;

/*List of properties available, where the properties should satisfy the criteria (city, no of rooms and/or range for rentgiven as input)*/
CREATE OR REPLACE PROCEDURE AvailProps(Place IN RentalProp.City%type,RoomNum IN RentalProp.RoomNo%type,MinRent IN RentalProp.MonthlyRent%type, MaxRent IN RentalProp.MonthlyRent%type)
AS	
	CURSOR large_cur IS
	SELECT RentNo,Street||', '||City||', '||Zip Address,RoomNo,MonthlyRent,Status,AvailDate FROM RentalProp
	WHERE (Status='available') AND (RoomNum=RoomNo OR Place=City OR (MonthlyRent >= MinRent AND MonthlyRent <= MaxRent)); 
	result_rec large_cur%rowtype;
BEGIN
	IF NOT large_cur%ISOPEN THEN
		OPEN large_cur;
	END IF;
LOOP
	FETCH large_cur INTO result_rec;
	EXIT WHEN large_cur%NOTFOUND;
	dbms_output.put_line('RentNo:'||result_rec.RentNo||', Address:'||result_rec.Address||', # of Room(s):'||result_rec.RoomNo||', MonthlyRent:'||result_rec.MonthlyRent||', Status:'||result_rec.Status||', AvailDate:'||result_rec.AvailDate);
END LOOP;
close large_cur;
END;
/
show errors;

/*Number of properties available for rent by branch*/
SELECT BranchNo,COUNT(*) FROM EMPLOYEE NATURAL JOIN RENTALPROP
WHERE EmpId=SuperId AND status='available'
GROUP BY BranchNo;

/*Create  a  lease  agreement*/
CREATE OR REPLACE PROCEDURE NewLease(RentNo IN LeaseAgreement.RentNo%type,Name IN LeaseAgreement.RentName%type,HomeP IN LeaseAgreement.HomePhone%type,WorkP IN LeaseAgreement.WorkPhone%type,ConName IN LeaseAgreement.ContactName%type,SDate IN LeaseAgreement.StartDate%type,EDate IN LeaseAgreement.EndDate%type,Deposit IN LeaseAgreement.DepAmount%type,Rent IN LeaseAgreement.RentAmount%type)
AS
BEGIN
INSERT INTO LEASEAGREEMENT VALUES(RentNo,Name,HomeP,WorkP,ConName,SDate,EDate,Deposit,Rent);
END;
/
show errors;

/*Show a lease agreement for a renter (name is entered as input)*/
CREATE OR REPLACE PROCEDURE RenterLease(Renter IN LeaseAgreement.RentName%type)
AS
	CURSOR large_cur IS
	SELECT * FROM LeaseAgreement
	WHERE RentName=Renter; 	
	result_rec large_cur%rowtype;
BEGIN
	IF NOT large_cur%ISOPEN THEN
		OPEN large_cur;
	END IF;
LOOP
	FETCH large_cur INTO result_rec;
	EXIT WHEN large_cur%NOTFOUND;
	dbms_output.put_line('RentNo:'||result_rec.RentNo||', Renter:'||result_rec.RentName||', Home Phone:'||result_rec.HomePhone||', Work Phone:'||result_rec.WorkPhone||', Contact Name:'||result_rec.ContactName||', Start Date:'||result_rec.StartDate||', End Date:'||result_rec.EndDate||', Deposit Amount:'||result_rec.DepAmount||', Rent Amount:'||result_rec.RentAmount);
END LOOP;
close large_cur;
END;
/
show errors;

/*Show the renters who rented more than one rental property*/
SELECT RentName,COUNT(*) FROM LEASEAGREEMENT
GROUP BY RENTNAME,HOMEPHONE
HAVING COUNT(*) > 1; 

/*Show  the  average  rent  for  properties  in a  town  (name  of  the  town  is  entered  as  input)*/
CREATE OR REPLACE PROCEDURE AverageRent(Place IN RentalProp.City%type)
AS
	avgamount NUMBER(10,2); 
BEGIN
	SELECT AVG(MonthlyRent) INTO avgamount FROM RentalProp
	WHERE City=Place;
	dbms_output.put_line('The average rent in '||Place||' is '||avgamount);
END;
/
show errors;

/*Show the names and addresses of properties whose leases will expire in next two months (from the current date)*/
SELECT RentNo, Street||','||City||','||Zip Address FROM LEASEAGREEMENT NATURAL JOIN RENTALPROP
WHERE EndDate-SYSDATE<=60 AND EndDate-SYSDATE>=1;
