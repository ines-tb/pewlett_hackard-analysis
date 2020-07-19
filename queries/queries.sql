rollback;

-- Employees born between 1952 and 1955
SELECT first_name, last_name
FROM employees
where birth_date BETWEEN '1952-01-01' and '1955-12-31';

-- Employees born in 1952
SELECT first_name, last_name
FROM employees
where birth_date BETWEEN '1952-01-01' and '1952-12-31';

-- Employees born in 1953
SELECT first_name, last_name
FROM employees
where birth_date BETWEEN '1953-01-01' and '1953-12-31';

-- Employees born in 1954
SELECT first_name, last_name
FROM employees
where birth_date BETWEEN '1954-01-01' and '1954-12-31';

-- Employees born in 1955
SELECT first_name, last_name
FROM employees
where birth_date BETWEEN '1955-01-01' and '1955-12-31';

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
	
-- Number of employees retiring (ALL born between 1952-1955)
SELECT count(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
	
-- Save results to a table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
select * from retirement_info;

-- ********************************************************************
-- Recreate new table for retiring employees (ALL born between 1952-1955)
drop table retirement_info;
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
select * from retirement_info;

-- Joining departments and dept_manager tables
SELECT d.dept_name,
	dm.emp_no,
	dm.from_date,
	dm.to_date
FROM departments AS d
INNER JOIN dept_manager AS dm ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info AS ri
LEFT JOIN dept_employees AS de ON ri.emp_no = de.emp_no;

-- Current employers working and born between 1952-1955
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_employees AS de ON ri.emp_no = de.emp_no
where de.to_date = ('9999-01-01');
select * from current_emp;

-- Current retiring employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO retirement_dept
FROM current_emp AS ce
LEFT JOIN dept_employees AS de ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
select * from retirement_dept;

-- ********************************************************************
-- ADDITIONAL LISTS

-- 1. Employee information:
SELECT * from salaries
order by to_date desc;

SELECT e.emp_no, e.first_name, e.last_name, e.gender, s.salary, de.to_date
INTO emp_info
FROM employees AS e
INNER JOIN salaries AS s ON (e.emp_no = s.emp_no)
INNER JOIN dept_employees AS de ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01');
select * from emp_info;

-- 2. Management:
SELECT dm.dept_no, d.dept_name, dm.emp_no, ce.last_name, ce.first_name, dm.from_date, dm.to_date
INTO manager_info
FROM dept_manager AS dm
INNER JOIN departments AS d ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp AS ce ON (dm.emp_no = ce.emp_no);

-- 3. Department Retirees
SELECT ce.emp_no, ce.first_name, ce.last_name, d.dept_name
INTO dept_info
FROM current_emp AS ce
INNER JOIN dept_employees AS de ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d ON (de.dept_no = d.dept_no);

-- *****************************************************************
-- Department retiring employees
SELECT ri.emp_no, ri.first_name, ri.last_name, d.dept_name
FROM retirement_info AS ri
INNER JOIN dept_employees AS de ON (ri.emp_no = de.emp_no)
INNER JOIN departments AS d ON (de.dept_no = d.dept_no);

-- Sales and Development departments retiring employees
SELECT ri.emp_no, ri.first_name, ri.last_name, d.dept_name
FROM retirement_info AS ri
INNER JOIN dept_employees AS de ON (ri.emp_no = de.emp_no)
INNER JOIN departments AS d ON (de.dept_no = d.dept_no)
where d.dept_name in ('Sales','Development');
