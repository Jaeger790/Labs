--Section B Write a SQL code that creates the tables to hold your report sections. 

CREATE TABLE detailed_report(
    rental_date TIMESTAMP WITHOUT TIME ZONE,
    title VARCHAR(255),
    rental_id BIGINT
);

CREATE TABLE summary_report(
    rental_id BIGINT,
    film_title VARCHAR(255),
    rental_month text
);


--Section C Write a SQL query that will extract the raw data needed for the Detailed section of your report from the source database and verify the data’s accuracy.

INSERT INTO detailed_report(
    rental_date,
    title,
    rental_id
)
SELECT ren.rental_date AS rental_month, 
       fil.title AS film_title,
       ren.rental_id AS rental_count
FROM rental AS ren 
JOIN inventory AS inv 
   ON ren.inventory_id = inv.inventory_id 
JOIN film AS fil 
   ON inv.film_id = fil.film_id 
GROUP BY ren.rental_date,
         fil.title
ORDER BY rental_month,
         rental_count DESC;


--Section D Write code for function(s) that perform the transformation(s) you identified in part A4.
CREATE FUNCTION update_summary() 
RETURNS TRIGGER 
LANGUAGE PLPGSQL 
AS $$
BEGIN
    DELETE FROM summary_report;
    INSERT INTO summary_report
        SELECT COUNT(rental_id) as rental_count, title as film_title, TO_CHAR(rental_date,'Month-YYYY') as rental_month
    FROM detailed_report
    GROUP BY film_title, rental_month
    ORDER BY rental_month, rental_count DESC;
    RETURN NEW;
    END; $$

--Section E Write a SQL code that creates a trigger on the detailed table of the report that will continually update the summary table
CREATE TRIGGER update_summary_report
AFTER INSERT ON detailed_report
FOR EACH STATEMENT
EXECUTE PROCEDURE update_summary();



--Section F  Create a stored procedure that can be used to refresh the data in both your detailed and summary tables.
CREATE PROCEDURE refresh_reports()
LANGUAGE plpgsql
AS $$
BEGIN
DELETE FROM detailed_report;
INSERT INTO detailed_report(
    rental_date,
    title,
    rental_id
)
SELECT ren.rental_date AS rental_month, 
       fil.title,
       ren.rental_id
FROM rental AS ren 
JOIN inventory AS inv 
   ON ren.inventory_id = inv.inventory_id 
JOIN film AS fil 
   ON inv.film_id = fil.film_id 
GROUP BY ren.rental_date,
         fil.title,
         ren.rental_id;
END;$$

--Confirm PROCEDURE & Trigger Works works

CALL refresh_reports();
SELECT * FROM detailed_report;
SELECT * FROM summary_report;


