## desafio_sql

Identify projects that are at risk for going overbudget. A project is considered to be overbudget if the cost of all employees assigned to the project is greater than the budget of the project.


You'll need to prorate the cost of the employees to the duration of the project. For example, if the budget for a project that takes half a year to complete is $10K, then the total half-year salary of all employees assigned to the project should not exceed $10K. Salary is defined on a yearly basis, so be careful how to calculate salaries for the projects that last less or more than one year.


Output a list of projects that are overbudget with their project name, project budget, and prorated total employee expense (rounded to the next dollar amount).


HINT: to make it simpler, consider that all years have 365 days. You don't need to think about the leap years.


## codigo sql:

WITH gasto_projeto AS (
    SELECT 
        p.project_id, 
        SUM(e.salary / 365) AS custo_diario
    FROM linkedin_employees e
    INNER JOIN linkedin_emp_projects p 
        ON e.id = p.emp_id
    GROUP BY p.project_id
),
duracao_projeto AS (
    SELECT 
        lp.id AS project_id,
        lp.title, 
        lp.budget, 
        (lp.end_date::date - lp.start_date::date) AS duracao_dias
    FROM linkedin_projects lp
),
custo_prorateado AS (
    SELECT 
        d.project_id,
        d.title, 
        d.budget,
        ROUND(
            d.duracao_dias * g.custo_diario
        ) AS prorated_expenses
    FROM duracao_projeto d
    INNER JOIN gasto_projeto g
        ON d.project_id = g.project_id
)
SELECT 
    title, 
    budget, 
    CEILING(prorated_expenses) AS prorated_employee_expense
FROM custo_prorateado
WHERE prorated_expenses > budget
ORDER BY title ASC;
