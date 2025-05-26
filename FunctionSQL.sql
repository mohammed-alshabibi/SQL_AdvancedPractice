--create function GetNo(@id int)
returns nvarchar(20)
as
Begin
Declare @DepId int
Declare @DepName nvarchar(20)
Declare @Fullname nvarchar(20)
select @DepName = dept_name from Department d,Student s where d.Dept_Id = s.Dept_Id
select @Fullname = st_Fname from Student where   St_Id=@id
return @depname
end 
go
select dbo.GetNo(1)
select * from Student
select * from Department
-- =========3.==================
create function GetNo1(@id int)
returns table

as
return(
	select dept_name,St_Fname+' ' +St_Lname as fullname 
	from Student s join
	Department d on d.Dept_Id =s.Dept_Id
	where St_Id = @id
)
go

select * from dbo.GetNo1(1)
-- ============4.==============
CREATE FUNCTION isNullname1(@id INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @first NVARCHAR(50)
    DECLARE @last NVARCHAR(50)

    SELECT 
        @first = st_fname, 
        @last = st_lname 
    FROM Student 
    WHERE St_Id = @id

    IF (@first IS NULL AND @last IS NULL)
        RETURN 'First name & last name are null'
    ELSE IF (@first IS NULL)
        RETURN 'First name is null'
    ELSE IF (@last IS NULL)
        RETURN 'Last name is null'
    
        RETURN 'First name & last name are not null'
END
GO

-- Example usage
SELECT dbo.isNullname1(14)
-- ===========5.==================
Create Function GetMangId(@id int)
returns table


as
return
(
select dept_manager,
)
