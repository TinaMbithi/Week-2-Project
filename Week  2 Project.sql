USE stud_db;

show tables;

CREATE VIEW new_student_deatils AS
SELECT pd.stud_name, sd.stud_ID, sd.stud_email, cd.phone_number
FROM personal_details as pd 
JOIN school_details as sd on pd.stud_ID=sd.stud_ID
JOIN contact_details as cd on pd.phone_number=cd.phone_number;


CREATE VIEW full_stud_details AS
SELECT pd.national_ID,pd.stud_ID,pd.stud_name,pd.phone_number,pd.age,pd.gender,
sd.current_home_county,sd.secondary_school_county,sd.residence,sd.stud_email,
cd.next_of_kin_name,cd.next_of_kin_relation,cd.next_of_kin_contacts,
fd.sem_fee,fd.fee_paid,fd.stud_name AS financial_stud_name
FROM personal_details AS pd
JOIN school_details AS sd ON pd.stud_ID = sd.stud_ID
JOIN contact_details AS cd ON pd.phone_number = cd.phone_number
JOIN financial_details AS fd ON pd.stud_ID = fd.stud_ID;

UPDATE financial_details
SET stud_name = (
SELECT stud_name 
FROM personal_details 
WHERE personal_details.stud_ID = financial_details.stud_ID
AND stud_name IS NULL
);


ALTER TABLE financial_details
ADD COLUMN fee_cleared BOOLEAN DEFAULT FALSE;

UPDATE financial_details
SET fee_cleared = TRUE
WHERE fee_paid >= sem_fee;

CREATE VIEW financial_details_view AS
SELECT * FROM financial_details;

CREATE VIEW fee_cleared AS
SELECT pd.national_ID, pd.stud_name
FROM personal_details AS pd
JOIN financial_details AS fd ON pd.stud_ID = fd.stud_ID
WHERE fd.fee_cleared = TRUE;

CREATE VIEW total_fee_balance AS
SELECT SUM(fee_paid) AS total_fees_paid,
SUM(sem_fee - fee_paid) AS total_current_deficit
FROM financial_details;

CREATE VIEW home_county_count AS
SELECT current_home_county,COUNT(*) AS student_count
FROM school_details
GROUP BY current_home_county;

CREATE VIEW secondary_school_count AS
SELECT sd.secondary_school_county,
COUNT(CASE WHEN pd.gender = 'Male' THEN 1 END) AS male_count,
COUNT(CASE WHEN pd.gender = 'Female' THEN 1 END) AS female_count
FROM personal_details pd
JOIN school_details AS sd ON pd.stud_ID = sd.stud_ID
GROUP BY sd.secondary_school_county;

CREATE VIEW kin_percentage AS
SELECT (SUM(CASE WHEN next_of_kin_relation = 'Mother' THEN 1 END) * 100.0 / COUNT(*)) AS mother_percentage,
(SUM(CASE WHEN next_of_kin_relation = 'Father' THEN 1 END) * 100.0 / COUNT(*)) AS father_percentage
FROM contact_details;
