/*Supervisor can only have <3 Props*/
CREATE OR REPLACE TRIGGER SuperVisorLimit
FOR INSERT OR UPDATE
ON RENTALPROP
COMPOUND TRIGGER

 /* Declaration Section*/
v_MAX_PREREQS CONSTANT INTEGER := 3;
     v_CurNum INTEGER := 1;	
	 v_cno INTEGER;

 --ROW level
BEFORE EACH ROW IS
BEGIN
	v_cno := :NEW.SuperId;
END BEFORE EACH ROW;

 --Statement levelSELECT * FROM RENTALPROP;
AFTER STATEMENT IS
BEGIN
SELECT COUNT(*) INTO v_CurNum FROM RENTALPROP 
		WHERE SuperId = v_cno Group by SuperId;
		
		IF v_CurNum  > v_MAX_PREREQS THEN
			RAISE_APPLICATION_ERROR(-20000,'This supervisor has 3 rental properties already');
		END IF;
END AFTER STATEMENT;
 END ;
/
SHOW ERRORS;


/*One Manager per branch*/
CREATE OR REPLACE TRIGGER MANAGERLIMIT
FOR INSERT OR UPDATE
ON Employee
COMPOUND TRIGGER
 /* Declaration Section*/
v_MAX_PREREQS CONSTANT INTEGER := 1;
     v_CurNum INTEGER;	
	 v_cno INTEGER;

 --ROW level
BEFORE EACH ROW IS
BEGIN
	v_cno := :NEW.BranchNo;
END BEFORE EACH ROW;

 --Statement levelSELECT * FROM EMPLOYEE;
AFTER STATEMENT IS
BEGIN
    SELECT COUNT(*) INTO v_CurNum FROM Employee 
		WHERE BranchNo = v_cno AND JobDes='Manager' Group by BranchNo;
		IF v_CurNum  > v_MAX_PREREQS THEN
			RAISE_APPLICATION_ERROR(-20001,'Already have one manager in this branch');
		END IF;
END AFTER STATEMENT;
END;
/
show errors;

/*update rentalprop status when lease agreement added*/
CREATE OR REPLACE TRIGGER Statuschange_trig
BEFORE INSERT ON LEASEAGREEMENT
FOR EACH ROW
DECLARE
	v_Avail VARCHAR(15);
BEGIN
	BEGIN
		SELECT STATUS INTO v_Avail FROM RentalProp
		WHERE RentNo=:NEW.RentNo;
		EXCEPTION
			WHEN no_data_found THEN
		DBMS_OUTPUT.put_line('Property not found');
	END;
	IF v_Avail in ('not-available','leased') THEN
		RAISE_APPLICATION_ERROR(-20500,'Property not available');
	ELSE
		UPDATE RentalProp
		set status = 'leased'
		where RentalProp.RentNo=:NEW.RentNo;
		DBMS_OUTPUT.put_line('Property leased');
	END IF;
END;
/
show errors;


/*Increase RentAmount by 10% if 6-month rent*/
CREATE OR REPLACE TRIGGER Min_Rent_Increase
BEFORE INSERT ON LeaseAgreement
FOR EACH ROW
DECLARE
	Amount NUMBER(10,2);
BEGIN
	BEGIN
		SELECT MonthlyRent INTO Amount FROM RentalProp
		WHERE RentalProp.RentNo=:NEW.RentNo;
	END;
	IF :NEW.EndDate - :NEW.StartDate = 182 THEN
		:NEW.RentAmount := Amount*1.1;
	ELSE
		:NEW.RentAmount := Amount;
	END IF;		
END Min_Rent_Increase;
/
Show Errors;

/*Deleting LeaseAgreement make Available*/
CREATE OR REPLACE TRIGGER DelAvail_Trig
AFTER DELETE
ON LeaseAgreement
FOR EACH ROW
BEGIN
	UPDATE RentalProp
	SET Status='available',
	MonthlyRent=:OLD.RentAmount*1.1
	WHERE RentNo=:OLD.RentNo;
END;
/
show errors;

/*Check if RentalProp has a real supervisor*/
CREATE OR REPLACE TRIGGER RealSuper_Trig
AFTER INSERT
ON RentalProp
FOR EACH ROW
DECLARE
	Job VARCHAR(10);
BEGIN
	BEGIN
		SELECT JobDes INTO Job FROM Employee
		WHERE EmpId=:NEW.SuperId;
	END;
	IF Job != 'Supervisor' THEN
		RAISE_APPLICATION_ERROR(-20501,'Id does not belong to a supervisor');
	END IF;
END;
/
show errors;

/*Update fee in PropOwner*/
CREATE OR REPLACE TRIGGER FeeUpdate_Trig
AFTER INSERT OR DELETE
ON RENTALPROP
DECLARE
	CURSOR stats IS
	SELECT PropOwnerId,COUNT(*) prop FROM RENTALPROP
	GROUP BY PropOwnerId;
BEGIN
	FOR v_rec in stats LOOP
		UPDATE PROPOWNER
		set Fee=400*v_rec.prop
		where PropOwnerId=v_rec.PropOwnerId;
	END LOOP;
END;
/
show errors;

/*Set fee to 0 for New PropOwner*/
CREATE OR REPLACE TRIGGER NewPropOwnerFee_trig
BEFORE INSERT
ON PROPOWNER
FOR EACH ROW
BEGIN
	:NEW.Fee := 0;
END;
/
show errors;

