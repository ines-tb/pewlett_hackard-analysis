# Pewlett Hackard Analysis
An Analysis of employees Retirement and Job Vacancies

#### Overview
Pewlett Hackard workforce has a large number of baby boomers that will be retiring in the upcoming years. For that reason, the company has decided to make an analysis to identify who would be retiring and hence which positions will be open and will need a replacement. Additionally, it has been required to provide the number of employees retiring per title and also, those who can participate in a new suggested mentorship program.

###### Resources
* Data Sources: _departments.csv_, _dept_emp.csv_, _dept_manager.csv_, _employees.csv_, _salaries.csv_ and _titles.csv_.
* Software: PostgreSQL 11, pgAdmin 4, Visual Studio Code 1.45.1.
---
#### Summary
For the analysis requested, given the six csv files containing the data, an ERD - Entity Relationship Diagram, has been built to understand the relations and dependencies among the data in order to build a database able to contain all the information.
  * ERD:
  ![ERD](./EmployeeDB.png?raw=true)

Once raw data has been imported to its corresponding table in the DB, several intermediate tables have been created to host the filtered data.

First, the table named "_retirement_info_" has the basic information (_emp_no, first_name, last_name_) for all employees "ready for retirement" (_i.e. born between 1952 and 1955_). 
```sql
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
```

However, as the company has employee data since its establishment, also employees who already left are included in previous table. Filtering the data to keep only current workers leads to the **_current_emp_** table. For that purpose, it has been used a left join to the _dept\_employees_ table.
```sql
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_employees AS de ON ri.emp_no = de.emp_no
where de.to_date = ('9999-01-01');
```
Some other combinations have been necessary to get auxiliary tables. E.g.:
* Retiring managers (_manager\_info_ table): 
  Inner joins of _dept_manager, departments_ and _current_emp_
* Retiring employees departments (_dept\_info_ table): 
  Inner joins of _current_emp_, _dept_employees_ and _department_

For the breakdown by title, an extra function is needed to discard duplicities due to title changes over the years.
First, we store the needed fields in _retirement_curr_info_ table:
```sql
SELECT ce.emp_no, ce.first_name, ce.last_name, ti.title, ti.from_date, sa.salary
INTO retirement_curr_info
FROM current_emp AS ce
INNER JOIN titles AS ti ON (ce.emp_no = ti.emp_no)
INNER JOIN salaries AS sa ON (ce.emp_no = sa.emp_no) 
```
Then, with a temporary table in memory ('_with_' command) to avoid storing that information, a partition ('_partition by_' command) to identify similar/same rows, order them by the date the title was changed and finally choose only the newest title (_'WHERE rnum = 1'_ clause), we have each employee only once with the last title attached:
```sql 
WITH identifiedDuplicates AS (
	SELECT emp_no, first_name, last_name, title, from_date, salary,
		row_number() OVER(
			PARTITION BY emp_no, first_name, last_name
			ORDER BY from_date DESC
		) AS rnum
	FROM retirement_curr_info
)
SELECT emp_no, first_name, last_name, title, from_date, salary
INTO retirement_curr_info_unique
FROM identifiedDuplicates 
WHERE rnum = 1
ORDER BY emp_no;
```
Finally, the mentorship analysis follows a similar logic, combining temporary tables, partitions and filtering the data by year of birth equals 1965:
```sql
WITH mentorship_candidates AS (
	SELECT e.emp_no, e.first_name, e.last_name, ti.title, ti.from_date, ti.to_date
	FROM employees AS e
	INNER JOIN titles AS ti ON e.emp_no = ti.emp_no
	INNER JOIN dept_employees AS de ON e.emp_no = de.emp_no
	WHERE e.birth_date BETWEEN '1965-01-01' AND '1965-12-31'
		and de.to_date = '9999-01-01'
),
identifiedDuplicates AS (
	SELECT emp_no, first_name, last_name, title, from_date, to_date,
		row_number() OVER(
			PARTITION BY emp_no, first_name, last_name
			ORDER BY from_date DESC
		) AS rnum
	FROM mentorship_candidates
)
SELECT emp_no, first_name, last_name, title, from_date, to_date
INTO retirement_mentor_emp
FROM identifiedDuplicates 
WHERE rnum =1
ORDER BY emp_no;
```


---

#### Analysis results


Querying **_current_emp_** to count retiring employees returns **33,118** as the number of people about to retire.
```sql
    SELECT COUNT(*) FROM current_emp;
   ```  

##### By department:
A breakdown by department (_retirement_dept_ table) indicates that while all of them will be impacted,  **Development** (d005), **Production** (d004) and **Sales** (d007) will have many more vacancies to fill.
```sql
    SELECT * FROM retirement_dept;
    SELECT * FROM departments;
   ```  
  * Retirement by department / Department table:
  ![RetirementDept](./media/retirement_dept.png?raw=true)

##### By Title:

The results given by querying the data by title are pretty expected with most of the ready for retirement people having the higher-level titles, except for management which are just two of the nine possible.
  * Retirement by title:
  ![RetirementTitle](./media/retirement_emp_title.png?raw=true)

**NOTE**: A previous query returned the number of 5 manager among the soon-to-be retired, however there are three former managers which do not hold that title any more, therefore only '_Sales_' and '_Research_' departments will actually see their leaders leaving.
* Manager_info table:
  ![ManagerInfo](./media/manager_info.png?raw=true)


##### Mentor program:
The requirement for the mentor program of having born in 1965, makes **1,549** of the employees elegible to participate and contribute to the continuity of the company after the mass exits in the coming years. (Table _retirement_mentor_emp_)

##### Limitations:
Quering the salaries table, it has been discovered that salaries have not been updated accordingly to raises and only entry salaries are stored. Therefore, no retiring packages, payslips or whether the company will save money or not with the people going, can be calculated with the provided data.


##### Next steps
Two suggestions would be recommended.
* Query and group the data already analyzed **by year of retirement**. 
* An extra query to know in **which department** the proposed **mentors** work.
  
As the data has been colected for employees from 1952 to 1955, we may encounter the situation to have a department in which ALL their employees are leaving on "the first wave" and if those departments are any of the most affected (Development, Production or Sales) even the mentor program could not be enough. Or even worse, maybe some departments do not have any mentorship program candidates among thier staff that can cover the missing knowledge after the exits.


