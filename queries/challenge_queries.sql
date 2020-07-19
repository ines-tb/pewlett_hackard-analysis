--Number of Retiring Employees by Title
SELECT ce.emp_no, ce.first_name, ce.last_name, ti.title, de.from_date, sa.salary
INTO curr_retiring_info
FROM current_emp AS ce
INNER JOIN titles AS ti ON (ce.emp_no = ti.emp_no)
INNER JOIN salaries AS sa ON (ce.emp_no = sa.emp_no and ti.from_date=sa.from_date)
INNER JOIN dept_employees AS de ON (ce.emp_no = de.emp_no);
