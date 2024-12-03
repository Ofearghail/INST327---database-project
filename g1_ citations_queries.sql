USE g1_citations;

-- total_tickets_per_vehicle_make
CREATE VIEW total_tickets_per_vehicle_make AS
    SELECT 
        vehicle_make AS 'Vehicle Make',
        COUNT(vehicle_make) AS Number_of_Tickets
    FROM
        vehicles
            JOIN
        tickets USING (vehicle_id)
    GROUP BY vehicle_make
    HAVING Number_of_Tickets > 5;

-- violation_totals
CREATE VIEW violation_totals AS
    SELECT 
        violation_description,
        COUNT(violation_description) AS violation_quantity,
        CONCAT('$', FORMAT(SUM(fine_total),2)) AS total_fines
    FROM
        tickets
            JOIN
        (SELECT 
			ticket_number,
            violation_description,
			payment_total + amount_due AS fine_total
		 FROM 
			tickets
            JOIN payments using(ticket_number)
            join violations using(violation_code)
        ) as vioaltion_fines USING(ticket_number)
    GROUP BY violation_description
    Having SUM(fine_total) > 0
	ORDER BY violation_quantity DESC;

-- tickets_summary
CREATE VIEW tickets_summary AS
    SELECT 
        ticket_number,
        violation_description,
        ticket_queue AS ticket_status
    FROM
        tickets
            JOIN
        violations USING (violation_code)
            JOIN
        ticket_queue_types USING (queue_id)
    WHERE
        ticket_queue != 'Dismissed' AND ticket_queue != 'Warning'
    ORDER BY ticket_number; 

-- outstanding_payments
CREATE VIEW outstanding_payments AS
    SELECT 
        ticket_number, amount_due
    FROM
        tickets
            JOIN
        payments USING (ticket_number)
    WHERE
        amount_due > 0
    ORDER BY amount_due DESC;

-- violations_per_address
CREATE VIEW violations_per_address AS
    SELECT 
        violation_location,
        COUNT(DISTINCT ticket_number) AS total_violations
    FROM
        tickets
            JOIN
        locations USING (location_id)
            JOIN
        violations USING (violation_code)
    GROUP BY violation_location
    HAVING total_violations > 2
    ORDER BY total_violations DESC;
			
        
        
	
