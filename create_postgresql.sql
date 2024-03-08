CREATE TABLE state (
  state_id int NOT NULL,
  state_name varchar(255) NOT NULL,
  state_code varchar(255) NOT NULL,
  PRIMARY KEY (state_id)
);

CREATE TABLE city (
  city_id int NOT NULL,
  city_name varchar(255) NOT NULL,
  city_code varchar(255) NOT NULL,
  PRIMARY KEY (city_id)
);

CREATE TABLE address (
  address_id int NOT NULL,
  street1 varchar(255) NOT NULL,
  street2 varchar(255),
  state_id int,
  city_id int,
  zip_code int NOT NULL,
  PRIMARY KEY (address_id),
  FOREIGN KEY (state_id) REFERENCES state(state_id),
  FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE hospital_type (
  hospital_type_id int NOT NULL,
  type varchar(255),
  has_er boolean,
  performs_surgeries boolean,
  PRIMARY KEY (hospital_type_id)
);

CREATE TABLE hospital (
  hospital_id int NOT NULL,
  name varchar(255) NOT NULL,
  address_id int,
  hospital_type_id int,
  number_of_beds int NOT NULL,
  phone varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  PRIMARY KEY (hospital_id),
  FOREIGN KEY (address_id) REFERENCES address(address_id),
  FOREIGN KEY (hospital_type_id) REFERENCES hospital_type(hospital_type_id)
);

CREATE TABLE appointment_type (
  appointment_type_id int NOT NULL,
  type varchar(255) NOT NULL,
  description varchar(255) NOT NULL,
  PRIMARY KEY (appointment_type_id)
);

CREATE TABLE appointment_status (
  appointment_status_id int NOT NULL,
  status varchar(255) NOT NULL,
  description varchar(255) NOT NULL,
  PRIMARY KEY (appointment_status_id)
);

CREATE TABLE diagnosis (
  diagnosis_code int NOT NULL,
  diagnosis varchar(255) NOT NULL,
  PRIMARY KEY (diagnosis_code)
);

CREATE TABLE sex (
  sex_id int NOT NULL,
  sex varchar(255) NOT NULL,
  PRIMARY KEY (sex_id)
);

CREATE TABLE marital_status (
  marital_status_id int NOT NULL,
  marital_status varchar(255) NOT NULL,
  PRIMARY KEY (marital_status_id)
);

CREATE TABLE ethnicity (
  ethnicity_id int NOT NULL,
  ethnicity varchar(255) NOT NULL,
  PRIMARY KEY (ethnicity_id)
);

CREATE TABLE nationality (
  nationality_id int NOT NULL,
  nationality varchar(255) NOT NULL,
  PRIMARY KEY (nationality_id)
);

CREATE TABLE person (
  person_id int NOT NULL,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  dob varchar(255) NOT NULL,
  phone varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  sex_id int,
  marital_status_id int,
  ethnicity_id int,
  nationality_id int,
  PRIMARY KEY (person_id),
  FOREIGN KEY (sex_id) REFERENCES sex(sex_id),
  FOREIGN KEY (marital_status_id) REFERENCES marital_status(marital_status_id),
  FOREIGN KEY (ethnicity_id) REFERENCES ethnicity(ethnicity_id),
  FOREIGN KEY (nationality_id) REFERENCES nationality(nationality_id)
);

CREATE TABLE blood_type (
  blood_type_id int NOT NULL,
  blood_type varchar(255),
  PRIMARY KEY (blood_type_id)
);

CREATE TABLE patient_vitals (
  patient_vitals_id int NOT NULL,
  height decimal(10, 3),
  weight decimal(10, 3),
  blood_pressure varchar(255),
  bmi decimal(10, 3),
  last_updated_at timestamp(3),
  PRIMARY KEY (patient_vitals_id)
);

CREATE TABLE patient (
  patient_id int NOT NULL,
  person_id int,
  blood_type_id int,
  PRIMARY KEY (patient_id),
  FOREIGN KEY (person_id) REFERENCES person(person_id),
  FOREIGN KEY (blood_type_id) REFERENCES blood_type(blood_type_id)
 );

CREATE TABLE department (
  department_id int NOT NULL,
  name varchar(255) NOT NULL,
  hospital_id int,
  phone varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  PRIMARY KEY (department_id),
  FOREIGN KEY (hospital_id) REFERENCES hospital(hospital_id)
);

CREATE TABLE employee (
  employee_id int NOT NULL,
  person_id int,
  department_id int,
  PRIMARY KEY (employee_id),
  FOREIGN KEY (person_id) REFERENCES person(person_id),
  FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE doctor (
  doctor_id int NOT NULL,
  employee_id int,
  specialty varchar(255) NOT NULL,
  office varchar(255) NOT NULL,
  PRIMARY KEY (doctor_id),
  FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE manufacturer (
  manufacturer_id int NOT NULL,
  name varchar(255) NOT NULL,
  PRIMARY KEY (manufacturer_id)
);

CREATE TABLE supplier (
  supplier_id int NOT NULL,
  name varchar(255) NOT NULL,
  phone varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  PRIMARY KEY (supplier_id)
);

CREATE TABLE medicine (
  medicine_id int NOT NULL,
  diagnosis_code int,
  name varchar(255) NOT NULL,
  manufacturer_id int,
  active_ingredient varchar(255) NOT NULL,
  price decimal(10, 3) NOT NULL,
  description varchar(255) NOT NULL,
  dose varchar(255) NOT NULL,
  supplier_id int,
  PRIMARY KEY (medicine_id),
  FOREIGN KEY (diagnosis_code) REFERENCES diagnosis(diagnosis_code),
  FOREIGN KEY (manufacturer_id) REFERENCES manufacturer(manufacturer_id),
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE prescription (
  prescription_id int NOT NULL,
  medicine_id int,
  prescribed_at timestamp(3) NOT NULL,
  duration varchar(255) NOT NULL,
  comments varchar(255),
  PRIMARY KEY (prescription_id),
  FOREIGN KEY (medicine_id) REFERENCES medicine(medicine_id)
);

CREATE TABLE blood_test (
  blood_test_id int NOT NULL,
  haemoglobin decimal(10, 3),
  WBC decimal(10, 3),
  platelets decimal(10, 3),
  MCV decimal(10, 3),
  PCV decimal(10, 3),
  RBC decimal(10, 3),
  MCH decimal(10, 3),
  MCHC decimal(10, 3),
  RDW decimal(10, 3),
  neutrophils decimal(10, 3),
  lymphocytes decimal(10, 3),
  monocytes decimal(10, 3),
  basophils decimal(10, 3),
  collected_at timestamp(3) NOT NULL,
  employee_id int,
  PRIMARY KEY (blood_test_id),
  FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE urinalysis (
  urinalysis_id int NOT NULL,
  pH decimal(10, 3),
  specific_gravity decimal(10, 3),
  glucose decimal(10, 3),
  protein decimal(10, 3),
  bilirubin decimal(10, 3),
  urobilinogen decimal(10, 3),
  blood decimal(10, 3),
  ketone decimal(10, 3),
  nitrite decimal(10, 3),
  leukocytes decimal(10, 3),
  ascorbic_acid decimal(10, 3),
  clarity varchar(255),
  color varchar(255),
  collected_at timestamp(3) NOT NULL,
  employee_id int,
  PRIMARY KEY (urinalysis_id),
  FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE lab (
  lab_id int NOT NULL,
  blood_test_id int,
  urinalysis_id int,
  PRIMARY KEY (lab_id),
  FOREIGN KEY (blood_test_id) REFERENCES blood_test(blood_test_id),
  FOREIGN KEY (urinalysis_id) REFERENCES urinalysis(urinalysis_id)
);

CREATE TABLE appointment (
  appointment_id int NOT NULL,
  appointment_type_id int,
  hospital_id int,
  created_at timestamp(3),
  scheduled_for timestamp(3),
  patient_concern varchar(255),
  patient_vitals_id int,
  patient_id int,
  doctor_id int,
  lab_id int,
  appointment_status_id int,
  PRIMARY KEY (appointment_id),
  FOREIGN KEY (appointment_type_id) REFERENCES appointment_type(appointment_type_id),
  FOREIGN KEY (hospital_id) REFERENCES hospital(hospital_id),
  FOREIGN KEY (patient_vitals_id) REFERENCES patient_vitals(patient_vitals_id),
  FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
  FOREIGN KEY (lab_id) REFERENCES lab(lab_id),
  FOREIGN KEY (appointment_status_id) REFERENCES appointment_status(appointment_status_id)
);

CREATE TABLE appointment_diagnosis (
  appointment_id int,
  diagnosis_code int,
  PRIMARY KEY (appointment_id, diagnosis_code),
  FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id),
  FOREIGN KEY (diagnosis_code) REFERENCES diagnosis(diagnosis_code)
);

CREATE TABLE appointment_prescription (
  appointment_id int,
  prescription_id int,
  PRIMARY KEY (appointment_id, prescription_id),
  FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id),
  FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id)
);

CREATE TABLE bill (
  bill_no int NOT NULL,
  appointment_id int,
  doctor_charge int,
  room_charge int,
  operation_charge int,
  nursing_charge int,
  lab_charge int,
  total_charge int NOT NULL,
  is_insurance_covered boolean,
  issued_at timestamp(3) NOT NULL,
  closed_at timestamp(3),
  PRIMARY KEY (bill_no),
  FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
);

CREATE TABLE admittance_reason (
  admittance_reason_id int NOT NULL,
  reason varchar(255) NOT NULL,
  description varchar(255) NOT NULL,
  PRIMARY KEY (admittance_reason_id)
);

CREATE TABLE admittance (
  admittance_id int NOT NULL,
  patient_id int,
  admitted_at timestamp(3) NOT NULL,
  discharged_at timestamp(3),
  room varchar(255) NOT NULL,
  hospital_id int,
  admittance_reason_id int,
  duration_in_days int,
  PRIMARY KEY (admittance_id),
  FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
  FOREIGN KEY (hospital_id) REFERENCES hospital(hospital_id),
  FOREIGN KEY (admittance_reason_id) REFERENCES admittance_reason(admittance_reason_id)
);
