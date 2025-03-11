1. Find names of instructors with salary greater than that of some (at least one) instructor in the Computer Science department.
	Using self-join:
	select distinct A.name from instructor A, instructor B
		where A.salary > B.salary and B.dept_name = 'Comp. Sci.';

	Using some:
	select name from instructor where
		salary > some (select salary from instructor where dept_name = 'Comp. Sci.');

	Using exists:
	select name from instructor 
		exists (
			select * from instructor A 
				where salary > A.salary and A.dept_name = 'Comp. Sci.'
				);

	Using aggregation:
	select name from instructor where
		salary > (select min(salary) from instructor
				where dept_name = 'Comp. Sci.');

	Using with:
	with minsalary(value) as (select min(salary) from instructor
				where dept_name = 'Comp. Sci.')
	select name from instructor, minsalary where
		salary > minsalary.value;


2 Find all instructors earning the highest salary (there may be more than one with the same salary).
	Using self-join:
	select * from instructor where id not in (
		select A.id from instructor A, instructor B where A.salary < B.salary
		);

	Using all:
	select * from instructor where salary >= all (select salary from instructor);

	Using exists:
	select * from instructor A where not exists (select * from instructor where salary > A.salary);

	Using aggregation:
	select * from instructor where salary = (select max(salary) from instructor);

	Using with:
	with maxsalary(value) as (select max(salary) from instructor)
	select * from instructor, maxsalary where salary = maxsalary.value; 


