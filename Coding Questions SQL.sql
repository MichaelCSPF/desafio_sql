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
