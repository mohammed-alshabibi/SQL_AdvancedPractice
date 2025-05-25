create database JobApplicationSystem

use JobApplicationSystem

-- Trainees Table 
CREATE TABLE Trainees ( 
    TraineeID INT PRIMARY KEY, 
    FullName VARCHAR(100), 
    Email VARCHAR(100), 
    Program VARCHAR(50), 
    GraduationDate DATE 
); 

-- Job Applicants Table 
CREATE TABLE Applicants ( 
    ApplicantID INT PRIMARY KEY, 
    FullName VARCHAR(100), 
    Email VARCHAR(100), 
    Source VARCHAR(20), -- e.g., "Website", "Referral" 
    AppliedDate DATE 
);

-- Insert into Trainees 
INSERT INTO Trainees VALUES 
(1, 'Layla Al Riyami', 'layla.r@example.com', 'Full Stack .NET', '2025-04-30'), 
(2, 'Salim Al Hinai', 'salim.h@example.com', 'Outsystems', '2025-03-15'), 
(3, 'Fatma Al Amri', 'fatma.a@example.com', 'Database Admin', '2025-05-01');

-- Insert into Applicants 
INSERT INTO Applicants VALUES 
(101, 'Hassan Al Lawati', 'hassan.l@example.com', 'Website', '2025-05-02'), 
(102, 'Layla Al Riyami', 'layla.r@example.com', 'Referral', '2025-05-05'), -- same person as trainee 
(103, 'Aisha Al Farsi', 'aisha.f@example.com', 'Website', '2025-04-28'); 
--PART 1:
--List all unique people who either trained or applied for a job
select a.FullName,t.Email 
from Trainees t
cross join  Applicants a

--use union to avoid duplication
select fullname,email from Trainees
union 
select fullname,email from Applicants

--use UNION ALL.
select fullname,email from Trainees
union all
select fullname,email from Applicants
-- Observation: 
-- 'Layla Al Riyami' appears twice because she is both a trainee and an applicant.
-- UNION removes duplicates, UNION ALL includes them.
--people who are in both tables
select fullname from Trainees
intersect
select fullname from Applicants

--PART 2: DROP, DELETE, TRUNCATE Observation
-- only the row deleted 
delete from Trainees
where Program='Outsystems'
-- Observation: Row deleted. Table still exists.


-- truncate table application --> all data from table deleted
truncate table Applicants
-- Observation: All data removed instantly. No rollback possible in many systems.


--drop table applicants
drop table Applicants
-- Observation: Running SELECT on Applicants now causes an error: "Invalid object name."

--PART 3:Subqueries
-- Research:
-- 1. What is a subquery?
-- A subquery is a query nested inside another query, used in SELECT, FROM, or WHERE.
-- uses of subquerys 
--Where can we use subqueries?
--In SELECT: to return values for columns.
--In WHERE: to filter results.
--In FROM: to treat the subquery as a temporary table.

--Task:

--find all trainees whose emails appear in the applicants table using subquery inside WHERE
SELECT FullName, Email
FROM Trainees
WHERE Email IN (
    SELECT Email
    FROM Applicants
);
--DELETE -->Delete all applicants whose email matches someone in the trainees table
delete from applicants 
where Email in 
(select email from Trainees)

-- Part 4: Batch Script & Transactions


-- 4. What is a transaction?
-- A transaction is a group of SQL operations that are executed as a single unit.
-- B All commands succeed or all fail — no partial updates.
-- 5. Transaction Script
BEGIN TRANSACTION;

BEGIN TRY
    INSERT INTO Applicants VALUES (104, 'Zahra Al Amri', 'zahra.a@example.com', 'Referral', '2025-05-10');
    INSERT INTO Applicants VALUES (104, 'Error User', 'error@example.com', 'Website', '2025-05-11'); -- Duplicate
    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'Transaction failed. Rolled back.';
END CATCH;


-- Part 5: ACID Properties


-- Atomicity: All operations succeed or none do.
-- Example: Bank transfer. Deduct and deposit must both happen. If one fails, none should execute.

-- Consistency: Database moves from one valid state to another.
-- Example: After inserting a student, the FK to Department must still be valid.

-- Isolation: Concurrent transactions do not interfere.
-- Example: Two users booking tickets at once won't overwrite each other's data.

-- Durability: Once committed, the data stays even after crash.
-- Example: Your confirmed online order is still saved after a power cut.
