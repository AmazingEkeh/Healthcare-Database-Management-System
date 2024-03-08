-- PROGRAMMING PART 1
-- PART 1 (1)(a)
SELECT * FROM Doctor;

-- -- PART 1 (1)(b)
-- Add a new column 'room_number' to the 'Doctor' column
ALTER TABLE Doctor
ADD COLUMN room_number VARCHAR(3);

-- Update the 'room_number' column by extracting the first 3 characters from the 'office' column
UPDATE Doctor
SET room_number = SUBSTRING(office FROM 1 FOR 3);

-- Check the updated table
SELECT * FROM Doctor;

-- PART 1 (1)(c)
-- Add a new column 'building_code' to the 'Doctor' column
ALTER TABLE Doctor
ADD COLUMN building_code CHAR(1);

-- Update the 'building_code' column by extracting the last characters from the 'office' column
UPDATE Doctor
SET building_code = SUBSTRING(office FROM LENGTH(office) FOR 1);

-- Check the updated table
SELECT * FROM Doctor;

-- PART 1 (1)(c)
SELECT * FROM Doctor;



-- PART 1 (3)(a)
-- Check the 'appointment' table
SELECT * FROM appointment;

-- Create a sequence for the 'appointment_id' column
-- Execute the subquery to get the starting value
DO $$ 
DECLARE
  starting_value INT;
BEGIN 
  EXECUTE 'SELECT COALESCE(MAX(appointment_id), 1) FROM appointment' INTO starting_value;
  EXECUTE 'CREATE SEQUENCE appointment_id_seq START WITH ' || starting_value || ' INCREMENT BY 1'; 
END $$;

-- Set the default value for the 'appointment_id' column using the sequence
ALTER TABLE appointment
ALTER COLUMN appointment_id SET DEFAULT nextval('appointment_id_seq');

-- Retrieve information about the sequence
SELECT * FROM information_schema.sequences WHERE sequence_name = 'appointment_id_seq';


-- PART 1 (3)(b)
-- Demonstrate sequence by inserting two new records into the appointment table
-- Check the 'appointment' and 'patient' table to understand the tables
SELECT * FROM appointment;
SELECT * FROM patient;
-- Select an existing patient and inserting an appointment for the patient.
SELECT patient_id FROM patient WHERE patient_id = 10;
INSERT INTO appointment (appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, patient_vitals_id, 
						 patient_id, doctor_id, lab_id, appointment_status_id)
VALUES ('1', '21', CURRENT_TIMESTAMP, '2023-06-22 11:00:00', 'Follow-up for anorexia treatment', '34', 
		'10', '7', NULL, '4');

-- Check the 'person' table and insert my details in the 'person' table
SELECT * FROM person;
INSERT INTO person(person_id, first_name, last_name, dob, phone, email, sex_id, marital_status_id, ethnicity_id, nationality_id)
VALUES ('121', 'Amazing', 'Ekeh', '1996-06-13', '617-222-2222', 'amazinge@bu.edu', '2', '1', '1', '1');
-- Check if my record was successfully inserted
SELECT * FROM person;

-- Inserting myself as a patient
INSERT INTO patient(patient_id, person_id, blood_type_id)
VALUES ('54', '121', '1');
-- Check if my record was successfully inserted
SELECT * FROM patient;

-- Inserting an appointment for myself
SELECT patient_id FROM patient WHERE patient_id = 54;
INSERT INTO appointment (appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, patient_vitals_id, 
						 patient_id, doctor_id, lab_id, appointment_status_id)
VALUES ('1', '21', CURRENT_TIMESTAMP, '2023-06-22 14:00:00', 'General check-up', '35', '54', '1', NULL, '4');
-- Check the 'appointment' table to know if the two records were successfully inserted
SELECT * FROM appointment;




-- PART 1 (4)
-- Create the 'doctor_review' table
CREATE TABLE doctor_review (
	review_id SERIAL PRIMARY KEY,
	doctor_id INT,
	patient_id INT,
	review_date DATE DEFAULT CURRENT_DATE NOT NULL,
	rating CHAR(1) CHECK (rating IN ('A', 'B', 'C', 'D', 'E')),
	patient_review TEXT,
	CONSTRAINT fk_doctor_review_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),	
	CONSTRAINT fk_doctor_review_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
	-- To enforce one review per patient per doctor, I will use a composite unique constraint as seen below
	CONSTRAINT uq_patient_doctor_review UNIQUE (doctor_id, patient_id)
);
-- Check the 'doctor_review' table
SELECT * FROM doctor_review;


-- PART 1 (5)(a)
-- Inserting three records according to assignment instructions.
INSERT INTO doctor_review(doctor_id, patient_id, review_date, rating, patient_review)
VALUES 
	('1', '54', CURRENT_DATE, 'A', 'My doctor has great experience and listened to my compliants.'),
	('7', '10', DEFAULT, 'E', 'Doctor seemed unsound and inexperienced.'),
	('6', '31', '2024-01-18', 'C', 'Doctor was okay, but the room smelt damp.');
	
-- Check the 'doctor_review' table
SELECT * FROM doctor_review;

-- PART 1 (5)(b)
-- Create a view accoording to the instructions given.
CREATE VIEW doctor_patient_review_view AS
SELECT
	CONCAT(person_patient.first_name, ' ', person_patient.last_name) AS patient_name,
	CONCAT(person_doctor.first_name, ' ', person_doctor.last_name) AS doctor_name,
	doctor_review.review_date,
	doctor_review.rating,
	doctor_review.patient_review AS comment
FROM
	doctor_review
JOIN patient ON doctor_review.patient_id = patient.patient_id
JOIN person AS person_patient ON patient.person_id = person_patient.person_id
JOIN doctor ON doctor_review.doctor_id = doctor.doctor_id
JOIN employee ON doctor.employee_id = employee.employee_id
JOIN person AS person_doctor ON employee.person_id = person_doctor.person_id;

-- Select the review I added for myself as a patient
SELECT * FROM doctor_patient_review_view WHERE patient_name = 'Amazing Ekeh';


-- PART 1 (5)(c)
-- Inserting a statement that attempts to insert a review violating the rating check constraint.
INSERT INTO doctor_review(doctor_id, patient_id, review_date, rating, patient_review)
VALUES('7', '54', CURRENT_DATE, 'F', 'Doctor was great.');


-- PART 1 (5)(d)
-- Update statement to change a specific patient's review for a specific doctor.
UPDATE doctor_review
SET patient_review = 'The doctor was sound.'
WHERE doctor_id = 7
	AND patient_id = 10;
	
-- Run the view above to verify your results
SELECT * FROM doctor_patient_review_view WHERE patient_name = 'Matthew Harris';


-- PART 1 (5)(e)
-- Delete Statement for a patient's review for a specific doctor.
DELETE FROM doctor_review
WHERE doctor_id = 7
	AND patient_id = 10;
	
-- Run the view above to verify your results
SELECT * FROM doctor_patient_review_view;

-- Run the view above to verify your results
SELECT * FROM doctor_patient_review_view WHERE patient_name = 'Matthew Harris';




-- PART 2 (6)
-- Select statement to list appointment information
SELECT
    -- Extracting date and time separately
    DATE(appointment.scheduled_for) AS appointment_date,
    TO_CHAR(appointment.scheduled_for, 'HH24:MI:SS') AS appointment_time,

    -- Combine patient first and last names
    CONCAT(person_patient.last_name, ', ', person_patient.first_name) AS patient_name,

    -- Hospital name
    hospital.name,

    -- Combine doctor first and last names
    CONCAT(person_doctor.last_name, ', ', person_doctor.first_name) AS doctor_name,

    -- MCV value from blood_test (accounting for appointments without lab tests)
    COALESCE(lab.blood_test_id, NULL) AS mcv_value,

    -- Patient concern from appointment
    appointment.patient_concern

FROM
    appointment

-- Joining patient-related tables
JOIN patient ON appointment.patient_id = patient.patient_id
JOIN person AS person_patient ON patient.person_id = person_patient.person_id

-- Joining doctor-related tables
JOIN doctor ON appointment.doctor_id = doctor.doctor_id
JOIN employee ON doctor.employee_id = employee.employee_id
JOIN person AS person_doctor ON employee.person_id = person_doctor.person_id

-- Joining hospital
JOIN hospital ON appointment.hospital_id = hospital.hospital_id

-- Left joining lab and blood_test (not every appointment has a lab)
LEFT JOIN lab ON appointment.lab_id = lab.lab_id
LEFT JOIN blood_test ON lab.blood_test_id = blood_test.blood_test_id

-- Filtering by appointment type description
WHERE appointment.appointment_type_id IN (
    SELECT appointment_type_id
    FROM appointment_type
    WHERE patient_concern = 'General check-up'
)

-- Sorting by appointment date and time, and then patient name
ORDER BY appointment.scheduled_for, patient_name;




-- PART 1 (7)
-- Let us first identify appointments that do not have a related prescription
SELECT
    appointment.appointment_id,
    appointment.scheduled_for,
    CONCAT(person.first_name, ' ', person.last_name) AS patient_name,
    doctor.office AS doctor_office,
    hospital.name,
    diagnosis.diagnosis
FROM
    appointment
JOIN patient ON appointment.patient_id = patient.patient_id
JOIN doctor ON appointment.doctor_id = doctor.doctor_id
LEFT JOIN appointment_prescription ON appointment.appointment_id = appointment_prescription.appointment_id
LEFT JOIN prescription ON appointment_prescription.prescription_id = prescription.prescription_id
LEFT JOIN medicine ON prescription.medicine_id = medicine.medicine_id
LEFT JOIN diagnosis ON medicine.diagnosis_code = diagnosis.diagnosis_code
LEFT JOIN hospital ON appointment.hospital_id = hospital.hospital_id
JOIN person ON patient.person_id = person.person_id  -- Linking patient to person for full name
WHERE
appointment_prescription.appointment_id IS NULL;

-- Add test data for an appointment with a prescription
INSERT INTO appointment_prescription (appointment_id, prescription_id)
VALUES ('603', '31');

-- Re-run the first query to see the updated results, including the test data    SELECT
    appointment.appointment_id,
    appointment.scheduled_for,
    CONCAT(person.first_name, ' ', person.last_name) AS patient_name,
    doctor.office AS doctor_office,
    hospital.name,
    diagnosis.diagnosis
FROM
    appointment
JOIN patient ON appointment.patient_id = patient.patient_id
JOIN doctor ON appointment.doctor_id = doctor.doctor_id
LEFT JOIN appointment_prescription ON appointment.appointment_id = appointment_prescription.appointment_id
LEFT JOIN prescription ON appointment_prescription.prescription_id = prescription.prescription_id
LEFT JOIN medicine ON prescription.medicine_id = medicine.medicine_id
LEFT JOIN diagnosis ON medicine.diagnosis_code = diagnosis.diagnosis_code
LEFT JOIN hospital ON appointment.hospital_id = hospital.hospital_id
JOIN person ON patient.person_id = person.person_id  -- Linking patient to person for full name
WHERE
    appointment_prescription.appointment_id IS NULL;
	
	
-- PART 3 (8)
SELECT
    employee.employee_id,
    person.first_name,
    person.last_name,
    department.name,
    hospital.name,
    COUNT(blood_test.blood_test_id) AS blood_tests_count
FROM
    employee
JOIN person ON employee.person_id = person.person_id
JOIN department ON employee.department_id = department.department_id
JOIN hospital ON department.hospital_id = hospital.hospital_id
JOIN blood_test ON employee.employee_id = blood_test.employee_id
GROUP BY
    employee.employee_id,
    person.first_name,
    person.last_name,
    department.name,
    hospital.name
HAVING
    COUNT(blood_test.blood_test_id) >= 5;
	
-- PART 3 (9)
SELECT
    CONCAT(person.last_name, ', ', person.first_name) AS doctor_name,
    appointment.appointment_type_id,
    EXTRACT(MONTH FROM appointment.scheduled_for) AS appointment_month,
    COUNT(appointment.appointment_id) AS total_appointments
FROM
    doctor
JOIN employee ON doctor.employee_id = employee.employee_id
JOIN person ON employee.person_id = person.person_id
JOIN appointment ON doctor.doctor_id = appointment.doctor_id
GROUP BY
    doctor.doctor_id,
    person.last_name,
    person.first_name,
    appointment.appointment_type_id,
    EXTRACT(MONTH FROM appointment.scheduled_for)
ORDER BY
    doctor.doctor_id,
    appointment_month,
    appointment.appointment_type_id;
	
	
-- PART 4 (10)
SELECT
    person.marital_status_id,
    person.ethnicity_id,
    COUNT(appointment.appointment_id) AS total_appointments
FROM
    person
JOIN patient ON person.person_id = patient.person_id
JOIN appointment ON patient.patient_id = appointment.patient_id
GROUP BY
ROLLUP(person.marital_status_id, person.ethnicity_id);

-- PART 4 (11)
WITH age_groups AS (
    SELECT
        patient.patient_id,
        CASE
            WHEN EXTRACT(YEAR FROM AGE(current_date, TO_DATE(person.dob, 'YYYY-MM-DD'))) <= 17 THEN 'Child'
            WHEN EXTRACT(YEAR FROM AGE(current_date, TO_DATE(person.dob, 'YYYY-MM-DD'))) BETWEEN 18 AND 59 THEN 'Adult'
            ELSE 'Senior'
        END AS age_group,
        lab.urinalysis_id
    FROM
        patient
    JOIN person ON patient.person_id = person.person_id
    JOIN appointment ON patient.patient_id = appointment.patient_id
    JOIN lab ON appointment.lab_id = lab.lab_id
    WHERE
        lab.urinalysis_id IS NOT NULL
)

SELECT
    age_group,
    RANK() OVER (ORDER BY AVG(urinalysis_id) DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY AVG(urinalysis_id) DESC) AS dense_rank,
    COUNT(patient_id) AS patient_count
FROM
    age_groups
GROUP BY
    age_group
ORDER BY
rank;


-- PART 5 (12)
WITH HospitalAvgCharges AS (
    SELECT
        hospital.name AS hospital_name,
        hospital.address_id,
        AVG(bill.operation_charge) AS avg_operation_charge
    FROM
        hospital
    JOIN appointment ON hospital.hospital_id = appointment.hospital_id
    JOIN bill ON appointment.appointment_id = bill.appointment_id
    GROUP BY
        hospital.name, hospital.address_id
)

SELECT
    hospital_name,
    address_id,
    avg_operation_charge
FROM
    HospitalAvgCharges
ORDER BY
    avg_operation_charge DESC
LIMIT 3;


-- PART 5 (13)
SELECT
    s.supplier_id,
    s.name AS supplier_name,
    m1.name AS expensive_drug1,
    m1.manufacturer_id AS manufacturer_id_expensive_drug1,
    m2.name AS expensive_drug2,
    m2.manufacturer_id AS manufacturer_id_expensive_drug2
FROM
    supplier s
JOIN (
    SELECT
        m.supplier_id,
        m.name,
        m.manufacturer_id,
        ROW_NUMBER() OVER (PARTITION BY m.supplier_id ORDER BY m.price DESC) AS row_num
    FROM
        medicine m
) m1 ON s.supplier_id = m1.supplier_id AND m1.row_num = 1
LEFT JOIN (
    SELECT
        m.supplier_id,
        m.name,
        m.manufacturer_id,
        ROW_NUMBER() OVER (PARTITION BY m.supplier_id ORDER BY m.price DESC) AS row_num
    FROM
        medicine m
) m2 ON s.supplier_id = m2.supplier_id AND m2.row_num = 2;




-- PROGRAMMING PART 2
-- PROBLEM 1(a)
-- Created an ERD table using draw.io

-- PROBLEM 1 (b)
-- History table DDL
-- Creating an 'appointment history' table with redundancies
CREATE TABLE appointment_history(
	appointment_history_id SERIAL PRIMARY KEY,
	appointment_id INT REFERENCES appointment(appointment_id),
	appointment_type_id INT REFERENCES appointment_type(appointment_type_id),
    hospital_id INT REFERENCES hospital(hospital_id),
	created_at TIMESTAMP, 
    scheduled_for TIMESTAMP, 
    patient_concern CHAR(255), 
    patient_vitals_id INT REFERENCES patient_vitals(patient_vitals_id),
    patient_id INT REFERENCES patient(patient_id),
    doctor_id INT REFERENCES doctor(doctor_id),
    lab_id INT REFERENCES lab(lab_id),
    appointment_status_id INT REFERENCES appointment_status(appointment_status_id),
	hospital_name CHAR(255), -- denormalized column
	change_type TEXT, -- this stores the type of change that occurred during operations, whether "update", "insert", or "delete".
	change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Check if the 'appointment_history' table was successfully created
SELECT * FROM appointment_history;

-- Initial population of the 'appointment_history' table
INSERT INTO appointment_history (
    appointment_id,
    appointment_type_id,
    hospital_id,
    created_at,
    scheduled_for,
    patient_concern,
    patient_vitals_id,
    patient_id,
    doctor_id,
    lab_id,
    appointment_status_id,
    hospital_name,
    change_type,
    change_timestamp
)
SELECT
    a.appointment_id,
    a.appointment_type_id,
    a.hospital_id,
    a.created_at,
    a.scheduled_for,
    a.patient_concern,
    a.patient_vitals_id,
    a.patient_id,
    a.doctor_id,
    a.lab_id,
    a.appointment_status_id,
    h.name,
    'Initial Insert', -- Since this is the initial insertion
    NOW() -- Change timestamp for the initial insert
FROM
    appointment a
    LEFT JOIN hospital h ON a.hospital_id = h.hospital_id;

-- Check to see if the table has now been populated.
SELECT * FROM appointment_history;




-- PROBLEM 2 (a)
-- Implement a trigger that prevents deletion from the appointment_history table using error handling logic
-- Create the trigger function
CREATE OR REPLACE FUNCTION prevent_deletion_appointment_history()
RETURNS TRIGGER AS $$
BEGIN
	RAISE EXCEPTION 'Deletions are prohibited in the appointment_history table.';
END;
$$ LANGUAGE plpgsql;

-- Trigger to prevent deletion from the appointment_history table
CREATE TRIGGER trigger_prevent_deletion_appointment_history
BEFORE DELETE ON appointment_history
FOR EACH ROW
EXECUTE FUNCTION prevent_deletion_appointment_history();

-- PROBLEM 2 (b)
-- Test case: demonstrate that you can’t delete a record from the history table
DELETE FROM appointment_history WHERE appointment_history_id = 2;





-- PROBLEM 3 (a)
-- Implement a trigger that maintains the appointment based on the transactions made to the appointment table.   
-- To consider insert, update and delete transactions
-- To keep track of updates, I will create a an appointment_audit table
-- Implement appointment_audit table for update history
CREATE TABLE appointment_audit (
	appointment_audit_id SERIAL PRIMARY KEY,
	appointment_id INT REFERENCES appointment(appointment_id),
	modified_column_name TEXT,
	old_value TEXT,
	new_value TEXT,
	change_date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger function to handle insertions, deletions, and updates
CREATE OR REPLACE FUNCTION modify_appointment_history()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
		INSERT INTO appointment_history (
			appointment_id,
    		appointment_type_id,
			hospital_id,
			created_at,
			scheduled_for,
			patient_concern,
			patient_vitals_id,
			patient_id,
			doctor_id,
			lab_id,
			appointment_status_id,
			hospital_name,
			change_type,
			change_timestamp
		)
		VALUES (
			NEW.appointment_id,
    		NEW.appointment_type_id,
			NEW.hospital_id,
			NEW.created_at,
			NEW.scheduled_for,
			NEW.patient_concern,
			NEW.patient_vitals_id,
			NEW.patient_id,
			NEW.doctor_id,
			NEW.lab_id,
			NEW.appointment_status_id,
			(SELECT h.name FROM hospital h WHERE hospital_id = NEW.hospital_id),
			CASE 
				WHEN TG_OP = 'INSERT' THEN 'Insert'
				WHEN TG_OP = 'DELETE' THEN 'Delete'
			END,
			NOW()
		);
	
	-- To update into the appointment_history table
	ELSEIF TG_OP = 'UPDATE' THEN
        IF NEW.appointment_type_id IS DISTINCT FROM OLD.appointment_type_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'appointment_type_id', OLD.appointment_type_id::TEXT, NEW.appointment_type_id::TEXT, NOW());
        END IF;

        IF NEW.hospital_id IS DISTINCT FROM OLD.hospital_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'hospital_id', OLD.hospital_id::TEXT, NEW.hospital_id::TEXT, NOW());
        END IF;

        IF NEW.created_at IS DISTINCT FROM OLD.created_at THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'created_at', OLD.created_at::TEXT, NEW.created_at::TEXT, NOW());
        END IF;

        IF NEW.scheduled_for IS DISTINCT FROM OLD.scheduled_for THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'scheduled_for', OLD.scheduled_for::TEXT, NEW.scheduled_for::TEXT, NOW());
        END IF;
		
		IF NEW.patient_concern IS DISTINCT FROM OLD.patient_concern THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'patient_concern', OLD.patient_concern::TEXT, NEW.patient_concern::TEXT, NOW());
        END IF;
		
		IF NEW.patient_vitals_id IS DISTINCT FROM OLD.patient_vitals_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'patient_vitals_id', OLD.patient_vitals_id::TEXT, NEW.patient_vitals_id::TEXT, NOW());
        END IF;
		
		IF NEW.patient_id IS DISTINCT FROM OLD.patient_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'patient_id', OLD.patient_id::TEXT, NEW.patient_id::TEXT, NOW());
        END IF;
		
		IF NEW.doctor_id IS DISTINCT FROM OLD.doctor_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'doctor_id', OLD.doctor_id::TEXT, NEW.doctor_id::TEXT, NOW());
        END IF;
		
		IF NEW.lab_id IS DISTINCT FROM OLD.lab_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'lab_id', OLD.lab_id::TEXT, NEW.lab_id::TEXT, NOW());
        END IF;
		
		IF NEW.appointment_status_id IS DISTINCT FROM OLD.appointment_status_id THEN
            INSERT INTO appointment_audit (appointment_id, modified_column_name, old_value, new_value, change_date_time)
            VALUES (NEW.appointment_id, 'appointment_status_id', OLD.appointment_status_id::TEXT, NEW.appointment_status_id::TEXT, NOW());
        END IF;
		
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for insertions, deletions, and updates
CREATE TRIGGER trigger_modify_appointment_history
AFTER INSERT OR DELETE OR UPDATE ON appointment
FOR EACH ROW
EXECUTE FUNCTION modify_appointment_history();

-- Show what the history looks like before each of the following test operations.
SELECT * FROM appointment_history;
SELECT * FROM appointment_audit;

-- Demonstrate an insert
INSERT INTO appointment (appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, patient_vitals_id, 
						 patient_id, doctor_id, lab_id, appointment_status_id)
VALUES ('2', '21', CURRENT_TIMESTAMP, '2024-06-22 12:00:00', 'Follow-up on sprained ankle. ', '34', '54', '1', NULL, '1');
-- Check if the insertion was successful
SELECT * FROM appointment;

-- Test case for insertion to see if the operation was successful
SELECT 
	ah.*,
	p.first_name, 
	p.last_name
FROM appointment_history ah
LEFT JOIN patient pa ON ah.patient_id = pa.patient_id
LEFT JOIN person p ON pa.person_id = p.person_id
WHERE ah.patient_id = 54;

-- Test case to demonstrate an update
UPDATE appointment
SET patient_concern = 'Eye examination'
WHERE appointment_id = 603;
-- Check if this update is reflected in the 'appointment_audit' table.
SELECT * FROM appointment_audit;

-- Test case to demonstrate a deletion
DELETE FROM appointment
WHERE appointment_id = 604
	AND patient_concern = 'General check-up';




-- PROBLEM 4 (a)
-- Implement a user defined function which checks if the doctor is working at a specific hospital 
-- Query to identify the hospital associated with a specific doctor
SELECT hospital.name
FROM doctor
JOIN employee ON doctor.employee_id = employee.employee_id
JOIN department ON employee.department_id = department.department_id
JOIN hospital ON department.hospital_id = hospital.hospital_id
WHERE doctor.doctor_id = 6;
--Check to see what the 'hospital_id' for 'Pine Crest Medical Center' is
SELECT hospital_id
FROM hospital h
WHERE h.name = 'Pine Crest Medical Center';

-- Create the user-defined function
CREATE OR REPLACE FUNCTION doctor_hospital_input_parameter_match(doctor_id_param INTEGER, hospital_id_param INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    matched_hospital_id INTEGER;
    v_doctor_id INTEGER;
BEGIN
    -- Assign the parameter value to a local variable
    v_doctor_id := doctor_id_param;

    -- Check if the doctor is associated with the provided hospital
    SELECT department.hospital_id
    INTO matched_hospital_id
    FROM doctor
    JOIN employee ON doctor.employee_id = employee.employee_id
    JOIN department ON employee.department_id = department.department_id
    WHERE doctor.doctor_id = v_doctor_id;

    -- Return true (1) if there's a match, false (0) otherwise
    RETURN COALESCE(matched_hospital_id = hospital_id_param, FALSE);
END;
$$ LANGUAGE plpgsql;

-- Let's try to use the function
SELECT doctor_hospital_input_parameter_match (6, 25);


-- PROBLEM 4 (b)
-- Run a query (b) to show the data.
-- This query shows the relationships between doctors, employees, and departments
SELECT 
    d.doctor_id,
    p.first_name || ' ' || p.last_name AS doctor_name,
    e.employee_id,
    p.first_name || ' ' || p.last_name AS employee_name,
    dep.department_id,
    dep.hospital_id
FROM 
    doctor d
JOIN 
    employee e ON d.employee_id = e.employee_id
JOIN 
    department dep ON e.department_id = dep.department_id
JOIN 
    person p ON e.person_id = p.person_id;

-- Test a doctor and hospital combo that matches
SELECT doctor_hospital_input_parameter_match(11, 22);

-- Test a doctor and hospital combo that does not match
SELECT doctor_hospital_input_parameter_match(13, 25);




-- PROBLEM 5 (a)
-- Firstly, generate a series of hourly time slots for the specified day
SELECT generate_series('2024-03-07'::date, '2024-03-07'::date + INTERVAL '1 day' * 5, INTERVAL '1 hour') AS time_slots;

-- Query to filter out weekends and non-working hours
SELECT * 
FROM generate_series('2024-03-07'::date, '2024-03-07'::date + INTERVAL '1 day' * 5, INTERVAL '1 hour') AS time_slots
WHERE EXTRACT(ISODOW FROM time_slots) < 6 and EXTRACT(HOUR FROM time_slots) >= 9 AND EXTRACT(HOUR FROM time_slots) <= 16;

-- Then check for existing appointments
SELECT time_slots, appointment.scheduled_for
FROM generate_series('2024-03-07'::date, '2024-03-07'::date + INTERVAL '1 day' * 5, INTERVAL '1 hour') AS time_slots
LEFT JOIN appointment ON time_slots = DATE_TRUNC('hour', scheduled_for) AND doctor_id = 11;

-- Identify the first available time slot
SELECT time_slots
FROM generate_series('2024-03-07'::date, '2024-03-07'::date + INTERVAL '1 day' * 5, INTERVAL '1 hour') AS time_slots
LEFT JOIN appointment ON time_slots = DATE_TRUNC('hour', scheduled_for) AND doctor_id = 11
WHERE EXTRACT(ISODOW FROM time_slots) < 6 AND EXTRACT(HOUR FROM time_slots) >= 9 AND EXTRACT(HOUR FROM time_slots) <= 16
  AND appointment.appointment_id IS NULL
ORDER BY time_slots
LIMIT 1;

-- Code to create function from the logic above
-- Create a user-defined function to find the next available time slot
CREATE OR REPLACE FUNCTION find_next_available_time_slot(doctor_id_param INTEGER, specified_date TIMESTAMP)
RETURNS TIMESTAMP AS $$
DECLARE
    next_available_slot TIMESTAMP;
BEGIN
    -- Calculate the next available slot based on the specified date and doctor's schedule
    SELECT 
        COALESCE(MIN(avail_slot), specified_date + INTERVAL '9 hours') INTO next_available_slot
    FROM (
        SELECT 
            time_slots + INTERVAL '1 hour' AS avail_slot
        FROM 
            generate_series(specified_date::date, specified_date::date + INTERVAL '1 day' * 5, INTERVAL '1 hour') AS time_slots
        WHERE 
            EXTRACT(ISODOW FROM time_slots) < 6
            AND EXTRACT(HOUR FROM time_slots) >= 9 
            AND EXTRACT(HOUR FROM time_slots) <= 16
            AND NOT EXISTS (
                SELECT 1
                FROM appointment a
                WHERE DATE_TRUNC('hour', a.scheduled_for) = time_slots
                AND a.doctor_id = doctor_id_param
            )
    ) AS available_slots
    LIMIT 1;

    RETURN next_available_slot;
END;
$$ LANGUAGE plpgsql;

-- Test the function with doctor_id = 11 and specified date = '2024-03-07 13:30:00'
SELECT find_next_available_time_slot(11, '2024-03-07 13:30:00') AS next_available_slot;



---- PROBLEM 5 (c)
-- Test cases
-- Current Appointments for "Amazing Ekeh":
SELECT a.*, p.first_name || ' ' || p.last_name AS patient_name, p.first_name || ' ' || p.last_name AS doctor_name
FROM appointment a
JOIN patient pa ON a.patient_id = pa.patient_id
JOIN person p ON pa.person_id = p.person_id
JOIN doctor d ON a.doctor_id = d.doctor_id
WHERE p.first_name = 'Amazing' AND p.last_name = 'Ekeh'
ORDER BY a.scheduled_for;


-- Test Case: Requested Time Slot is Available
SELECT find_next_available_time_slot(
    (SELECT doctor_id
     FROM doctor
     JOIN employee ON doctor.employee_id = employee.employee_id
     JOIN person ON employee.person_id = person.person_id
     WHERE person.first_name = 'Matthew' AND person.last_name = 'Wilson' 
	 LIMIT 1),
    '2024-03-07 10:00:00'
) AS next_available_slot;


-- Test Case: Requested Time Slot is Taken, Next Time Offered
-- Assuming there's already an appointment for Dr. Matthew Wilson on '2023-04-26 12:15:00'
-- This will find the next available time slot for Dr. Johnson after '2023-04-26 12:15:00'
SELECT find_next_available_time_slot(
    (SELECT doctor_id
     FROM doctor
     JOIN employee ON doctor.employee_id = employee.employee_id
     JOIN person ON employee.person_id = person.person_id
     WHERE person.first_name = 'Matthew' AND person.last_name = 'Wilson' 
	 LIMIT 1),
    '2023-04-26 12:15:00'
) AS next_available_slot_after_taken;

-- Test Case: Requested Day is Not Available, Suggest Next Day
-- Assuming all slots for '2024-03-08' are taken
-- This will suggest the next available slot for Dr. Johnson on '2024-03-09'
SELECT find_next_available_time_slot(
    (SELECT doctor_id
     FROM doctor
     JOIN employee ON doctor.employee_id = employee.employee_id
     JOIN person ON employee.person_id = person.person_id
     WHERE person.first_name = 'Matthew' AND person.last_name = 'Wilson' 
	 LIMIT 1),
    '2023-06-21 15:45:00'
) AS next_available_slot;




-- PROBLEM 6
-- Create a stored procedure to insert records into the appointment table
CREATE OR REPLACE PROCEDURE insert_appointment(
    appointment_type_id INT, hospital_id INT, scheduled_for TIMESTAMP, 
	patient_concern TEXT, patient_vitals_id INT, patient_id INT, doctor_id INT, lab_id INT, appointment_status_id INT
)
LANGUAGE PLpgSQL
AS $$
BEGIN
	INSERT INTO appointment (appointment_type_id, hospital_id, created_at, scheduled_for, patient_concern, patient_vitals_id, 
						 patient_id, doctor_id, lab_id, appointment_status_id)
	VALUES (appointment_type_id, hospital_id, CURRENT_TIMESTAMP, scheduled_for, patient_concern, patient_vitals_id, 
						 patient_id, doctor_id, lab_id, appointment_status_id);
END;
$$;

-- Example call to the stored procedure
CALL insert_appointment(
	3, 25, '2024-06-25 10:00:00'::TIMESTAMP, 'Follow-up after routine check-up', 34, 54, 1, NULL, 4);
-- Check if the insertion was successful
SELECT * FROM appointment WHERE patient_concern = 'Follow-up after routine check-up';




-- PROBLEM 7 
-- Created two new functions to help or support in the creation of the updated stored procedure
-- Created the 'is_patient_registered' function
CREATE OR REPLACE FUNCTION is_patient_registered(patient_id_param INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM patient WHERE patient_id = patient_id_param);
END;
$$ LANGUAGE plpgsql;

-- Created the 'get_default_appointment_status' function
CREATE OR REPLACE FUNCTION get_default_appointment_status()
RETURNS INTEGER AS $$
BEGIN
    -- You can return a specific appointment status ID here
    RETURN 1;  -- Adjust the value based on your actual appointment status IDs
END;
$$ LANGUAGE plpgsql;


-- Updated stored procedure
CREATE OR REPLACE PROCEDURE create_patient_appointment(
    IN patient_id_param INT,
    IN specified_date_param TIMESTAMP,
    IN patient_concern_param TEXT,
    IN appointment_type_id_param INT,
    IN hospital_id_param INT,
    IN doctor_id_param INT
)
LANGUAGE PLpgSQL
AS $$
DECLARE
    available_slot TIMESTAMP;
BEGIN
    -- Check if the patient exists in the system
    IF NOT is_patient_registered(patient_id_param) THEN
        RAISE EXCEPTION 'Please register with the hospital network before booking appointments.';
    END IF;

    -- Check if the desired time is available
	available_slot := find_next_available_time_slot(doctor_id_param, specified_date_param);
	IF available_slot IS NULL OR available_slot = specified_date_param THEN
    	RAISE EXCEPTION 'Time slot not available. Please select another time.';
	END IF;


    -- Check if the doctor works at the selected hospital
    IF NOT doctor_hospital_input_parameter_match(doctor_id_param, hospital_id_param) THEN
        RAISE EXCEPTION 'The selected doctor does not work at the selected hospital.';
    END IF;

    -- Validate appointment business rules
    IF specified_date_param < CURRENT_TIMESTAMP OR specified_date_param > CURRENT_TIMESTAMP + INTERVAL '3 months' THEN
        RAISE EXCEPTION 'Appointments cannot be made more than 3 months in advance or less than 1 hour in advance.';
    END IF;

    -- Insert the appointment
    INSERT INTO appointment (
        appointment_type_id,
        hospital_id,
        created_at,
        scheduled_for,
        patient_concern,
        patient_vitals_id,
        patient_id,
        doctor_id,
        lab_id,
        appointment_status_id
    )
    VALUES (
        appointment_type_id_param,
        hospital_id_param,
        CURRENT_TIMESTAMP,  -- Auto-fill the created at date and time
        specified_date_param,
        patient_concern_param,
        NULL,  -- Auto-fill NULL for patient_vitals_id
        patient_id_param,
        doctor_id_param,
        NULL,  -- Auto-fill NULL for lab_id
        get_default_appointment_status()  -- Assign a relevant status
    );
END;
$$;


-- Test case
-- Create variables with necessary values
DO $$ 
DECLARE 
    patient_id_var INT;
    specified_date_var TIMESTAMP;
    patient_concern_var TEXT;
    appointment_type_id_var INT;
    hospital_id_var INT;
    doctor_id_var INT;
BEGIN
    -- Assign values for test cases
    patient_id_var := (SELECT patient_id FROM patient WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Amazing' AND last_name = 'Ekeh'));
    specified_date_var := CURRENT_TIMESTAMP + INTERVAL '1 day';  -- Schedule for a valid time (more than 1 hour in advance)
    patient_concern_var := 'General Checkup';
    appointment_type_id_var := 2;  -- appointment_type_id
    hospital_id_var := 21;  -- hospital_id
    doctor_id_var := 7;  -- actual doctor_id

    -- Test Case 1: Valid Appointment Creation for Specific Patient (Yourself)
    CALL create_patient_appointment(
        patient_id_var,
        specified_date_var,
        patient_concern_var,
        appointment_type_id_var,
        hospital_id_var,
        doctor_id_var
    );

    -- Test Case 2: Verify Appointment for Yourself in the Database
    PERFORM
        appointment.appointment_id,
        appointment.appointment_type_id,
        appointment.hospital_id,
        appointment.created_at,
        appointment.scheduled_for,
        appointment.patient_concern,
        appointment.patient_vitals_id,
        appointment.patient_id,
        appointment.doctor_id,
        appointment.lab_id,
        appointment.appointment_status_id,
        person.first_name AS patient_fname,
        person.last_name AS patient_lname
    FROM
        appointment
    JOIN
        patient ON appointment.patient_id = patient.patient_id
    JOIN
        person ON patient.person_id = person.person_id
    WHERE
        person.first_name = 'Amazing' AND person.last_name = 'Ekeh';
END $$;

-- Check if this was successfully inserted
SELECT * from appointment where patient_id = 54;


