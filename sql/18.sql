/*
 * Compute the total revenue for each film.
 * The output should include another new column "revenue percent" that shows the percent of total revenue that comes from the current film and all previous films.
 * That is, the "revenue percent" column is 100*"total revenue"/sum(revenue)
 *
 * HINT:
 * The `to_char` function can be used to achieve the correct formatting of your percentage.
 * See: <https://www.postgresql.org/docs/current/functions-formatting.html#FUNCTIONS-FORMATTING-EXAMPLES-TABLE>
 */
SELECT
rank,
title,
revenue,
"total revenue",
CASE
    WHEN 100 * "total revenue" / SUM(revenue) OVER () = 100
        THEN to_char(100 * "total revenue" / SUM(revenue) OVER (), 'FM000.00')
    ELSE
        to_char(100 * "total revenue" / SUM(revenue) OVER (), 'FM00.00')
END AS "percent revenue"
FROM (
    SELECT
    RANK() OVER (ORDER BY revenue DESC) AS rank,
    title,
    revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC) AS "total revenue"
    FROM (
        SELECT f.title, COALESCE(SUM(p.amount),0.00) AS revenue
        FROM film f
        LEFT JOIN inventory i ON f.film_id = i.film_id
        LEFT JOIN rental r ON i.inventory_id = r.inventory_id
        LEFT JOIN payment p ON r.rental_id = p.rental_id
        GROUP BY f.title
    ) t
) t2
ORDER BY rank, title;
