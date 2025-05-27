CREATE DATABASE SchoolDB;
GO

USE SchoolDB;
GO

-- Main table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Grade NVARCHAR(50)
);

-- Log table for inserts
CREATE TABLE StudentInsertLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT,
    Action NVARCHAR(50),
    TimeStamp DATETIME
);

-- Log table for updates
CREATE TABLE GradeChangeLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT,
    OldGrade NVARCHAR(50),
    NewGrade NVARCHAR(50),
    TimeStamp DATETIME
);
INSERT INTO Students (StudentID, Name, Grade)
VALUES
(1, N'Ahmed Ali', N'Grade 1'),
(2, N'Sara Mohammed', N'Grade 2'),
(3, N'Yousef Khaled', N'Grade 3');

--Create a Trigger to Prevent Deletion
CREATE TRIGGER PreventStudentDeletion
ON Students
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Deleting student records is not allowed.';
    ROLLBACK;
END;
-- Try to Delete a Record (Test the Trigger)
DELETE FROM Students WHERE StudentID = 2;
--Confirm Data Is Still There
SELECT * FROM Students;
--===============================
--Insert Sample Data into StudentInsertLog
INSERT INTO StudentInsertLog (StudentID, Action, TimeStamp)
VALUES 
(101, 'INSERTED', GETDATE()),
(102, 'INSERTED', GETDATE()),
(103, 'INSERTED', GETDATE());

--Insert Sample Data into GradeChangeLog
INSERT INTO GradeChangeLog (StudentID, OldGrade, NewGrade, TimeStamp)
VALUES
(101, 'Grade 1', 'Grade 2', GETDATE()),
(102, 'Grade 2', 'Grade 3', GETDATE()),
(103, 'Grade 3', 'Grade 4', GETDATE());



--INSTEAD OF INSERT – Prevent inserting students without names
CREATE TRIGGER ValidateStudentInsert
ON Students
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Name IS NULL OR LTRIM(RTRIM(Name)) = '')
    BEGIN
        RAISERROR(' Student name cannot be empty.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        INSERT INTO Students (StudentID, Name, Grade)
        SELECT StudentID, Name, Grade FROM inserted;
    END
END;
--AFTER INSERT – Log every new student
CREATE TRIGGER LogStudentInsert
ON Students
AFTER INSERT
AS
BEGIN
    INSERT INTO StudentInsertLog (StudentID, Action, TimeStamp)
    SELECT StudentID, 'INSERTED', GETDATE() FROM inserted;
END;

--INSTEAD OF UPDATE – Prevent setting Grade to invalid value
CREATE TRIGGER ValidateGradeUpdate
ON Students
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Grade IS NULL OR Grade = '')
    BEGIN
        RAISERROR(' Grade cannot be empty.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        UPDATE Students
        SET Name = i.Name,
            Grade = i.Grade
        FROM Students s
        JOIN inserted i ON s.StudentID = i.StudentID;
    END
END;
--AFTER UPDATE – Log grade changes
CREATE TRIGGER LogGradeChange
ON Students
AFTER UPDATE
AS
BEGIN
    INSERT INTO GradeChangeLog (StudentID, OldGrade, NewGrade, TimeStamp)
    SELECT d.StudentID, d.Grade, i.Grade, GETDATE()
    FROM deleted d
    JOIN inserted i ON d.StudentID = i.StudentID
    WHERE d.Grade <> i.Grade;
END;

--Test the Triggers

--Try to insert student with empty name (should fail):
INSERT INTO Students (StudentID, Name, Grade)
VALUES (1, '', 'Grade 1');

--Insert a valid student:
INSERT INTO Students (StudentID, Name, Grade)
VALUES (4, 'Ali Hassan', 'Grade 2');

--Try to update grade to empty (should fail):
UPDATE Students SET Grade = '' WHERE StudentID = 2;

--Valid grade update:
UPDATE Students SET Grade = 'Grade 3' WHERE StudentID = 2;
