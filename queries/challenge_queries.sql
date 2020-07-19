--Number of Retiring Employees by Title
SELECT ce.emp_no, ce.first_name, ce.last_name, ti.title, de.from_date, sa.salary
INTO curr_retiring_info
FROM current_emp AS ce
INNER JOIN titles AS ti ON (ce.emp_no = ti.emp_no)
INNER JOIN salaries AS sa ON (ce.emp_no = sa.emp_no and ti.from_date=sa.from_date)
INNER JOIN dept_employees AS de ON (ce.emp_no = de.emp_no);

-- Clean duplicated employees from curr_retiring_info (Choose most recent title)
WITH identifiedDuplicates AS (
	SELECT emp_no, first_name, last_name, title, from_date, salary,
		row_number() OVER(
			PARTITION BY emp_no, first_name, last_name
			ORDER BY from_date DESC
		) AS rnum
	FROM curr_retiring_info
)
SELECT emp_no, first_name, last_name, title, from_date, salary
INTO unique_curr_retiring_info
FROM identifiedDuplicates 
WHERE rnum =1
ORDER BY emp_no
