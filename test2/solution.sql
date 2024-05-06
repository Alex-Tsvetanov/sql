use real_estate_database;

-- задача 1
drop view if exists monthlyDeals;
create view monthlyDeals as
select 
	customers.name as customer_name, customers.phone,
    properties.location, properties.area, properties.price,
    employees.name as employee_name
from deals
join ads on ads.id = deals.ad_id
join actions on actions.id = ads.action_id
join properties on properties.id = ads.property_id
join customers on customers.id = properties.customer_id
join employees on employees.id = deals.employee_id
where 
	month(deals.dealDate) = month(now()) and
    actions.actionType <> "buying" and
    properties.area > 100
order by properties.price DESC;

-- test
select * from monthlyDeals;

-- задача 2
drop procedure if exists commisionPayment;
delimiter $
create procedure commisionPayment(month int, year int)
paymentProcedure: begin
	declare dealPrice float;
    declare dealEmployeeId int;
    declare dealCommission float;
    declare avgDealCommission float default 0;
    declare totalDealCommission float default 0;
    declare totalDealCount int default 0;
    declare commissionMonthlyBonus float default 0.15;
    declare moreDeals bool default true;
	declare dealsCursor cursor for select 
			properties.price,
			employees.id
		from deals
		join ads on ads.id = deals.ad_id
		join actions on actions.id = ads.action_id
		join properties on properties.id = ads.property_id
		join customers on customers.id = properties.customer_id
		join employees on employees.id = deals.employee_id
        where
			month(deals.dealDate) = month and
			year(deals.dealDate) = year and
            actions.actionType = "for sale";
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET moreDeals = false;
	open dealsCursor;
	start transaction;
		DROP TEMPORARY TABLE if exists commisions;
		CREATE TEMPORARY TABLE commisions(
		  employeeId INT primary key, 
		  commision float
		);
        
		processDeals: LOOP
			FETCH dealsCursor INTO dealPrice, dealEmployeeId;
			
			IF moreDeals = false THEN 
				LEAVE processDeals;
			END IF;
			
            if dealPrice < 100000 then
				set dealCommission = 2 * dealPrice / 100;
			else
				set dealCommission = 3 * dealPrice / 100;
			end if;
            
            set totalDealCommission = totalDealCommission + dealCommission;
            set totalDealCount = totalDealCount + 1;
            
            INSERT INTO commisions(employeeId, commision) VALUES (dealEmployeeId, dealCommission) ON DUPLICATE KEY UPDATE commision=commision+dealCommission;
		END LOOP;
        
        set avgDealCommission = totalDealCommission / totalDealCount;
        
        update commisions
        set commision = commision + 5 * avgDealCommission / 100
        order by commision desc
        limit 3; # първите 3 +5%
        -- if ROW_COUNT() <> 3 then
		-- 	select 
		-- 	rollback;
        --     leave paymentProcedure;
		-- end if;
        
        update commisions
        set commision = commision + 5 * avgDealCommission / 100
        order by commision desc
        limit 2; # първите 2 +още 5% (общо 10)
        -- if ROW_COUNT() <> 2 then
		-- 	rollback;
        --     leave paymentProcedure;
		-- end if;
        
        update commisions
        set commision = commision + 5 * avgDealCommission / 100
        order by commision desc
        limit 1; # първия 1 +още 5% (общо 15)
        -- if ROW_COUNT() <> 1 then
		-- 	rollback;
        --     leave paymentProcedure;
		-- end if;
        
        insert into salaryPayments(salaryAmount, monthlyBonus, yearOfPayment, monthOfPayment, dateOfPayment, employee_id)
        select AVG(sp.salaryAmount) as salaryAmount,
			ifnull(commision, 0) as monthlyBonus,
            year as yearOfPayment, 
            month as monthOfPayment, 
            now() as dateOfPayment, 
            employees.id as employee_id
        from employees
        LEFT join salaryPayments as sp on sp.employee_id = employees.id
        LEFT join commisions on commisions.employeeId = sp.employee_id
        group by employees.id;
    commit;
end $
delimiter ;

call commisionPayment(4, 2024);
select * from salaryPayments;

select AVG(sp.salaryAmount) as salaryAmount,
			ifnull(commision, 0) as monthlyBonus,
            2024 as yearOfPayment, 
            4 as monthOfPayment, 
            now() as dateOfPayment, 
            employees.id as employee_id
        from employees
        LEFT join salaryPayments as sp on sp.employee_id = employees.id
        LEFT join commisions on commisions.employeeId = sp.employee_id
        group by employees.id;