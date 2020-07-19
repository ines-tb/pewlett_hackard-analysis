
-- *******************************************************************************
-- Technical Analysis Deliverable 1: Number of Retiring Employees by Title
-- *******************************************************************************

-- Add title, from_date and salary to the current retiring employees
SELECT ce.emp_no, ce.first_name, ce.last_name, ti.title, ti.from_date, sa.salary
INTO retirement_curr_info
FROM current_emp AS ce
INNER JOIN titles AS ti ON (ce.emp_no = ti.emp_no)
INNER JOIN salaries AS sa ON (ce.emp_no = sa.emp_no)

-- Clean duplicated employees from curr_retiring_info (Choose most recent title)
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
WHERE rnum =1
ORDER BY emp_no;

-- Number of titles retiring
SELECT count(DISTINCT title) AS titles_count
INTO retirement_no_titles
FROM retirement_curr_info_unique;
SELECT * FROM retirement_no_titles;

-- Number of retiring employees with each title
SELECT COUNT(emp_no) AS emp_count, title
INTO retirement_emp_title
FROM retirement_curr_info_unique
GROUP BY title;
SELECT * FROM retirement_emp_title;

-- List of current employees born between Jan. 1, 1952 and Dec. 31, 1955
SELECT *
FROM retirement_curr_info_unique;


-- *******************************************************************************
-- Technical Analysis Deliverable 2: Mentorship Eligibility
-- *******************************************************************************

-- Mentorship eligibility: Current employees born in 1965
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
