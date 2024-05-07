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
            
            INSERT INTO commisions(employeeId, commision) VALUES (dealEmployeeId, dealCommission) 
            ON DUPLICATE KEY UPDATE commision=commision+dealCommission;
            
            -- -------------- INSERT INTO salaryPayments(salaryAmount, monthlyBonus, yearOfPayment, monthOfPayment, dateOfPayment, employee_id)
            -- -------------- VALUES (0, dealCommission, year(now()), month(now()), now(), dealEmployeeId) 
            -- -------------- ON DUPLICATE KEY UPDATE monthlyBonus=monthlyBonus+dealCommission;
		END LOOP;
        
        set avgDealCommission = totalDealCommission / totalDealCount;
	    -- select avg(commision) into avgDealCommission from commisions group by employeeId;
        
        -- -------------- update salaryPayments
        -- -------------- set monthlyBonus = monthlyBonus + 15 * avgDealCommission / 100
        -- -------------- where employeeId in (select c.employeeId from salaryPayments as c where c.yearOfPayment = year and c.monthOfPayment = month order by c.monthlyBonus desc limit 1);
		
        update commisions
        set commision = commision + 15 * avgDealCommission / 100
        where employeeId in (select c.employeeId from commisions as c order by c.commission desc limit 1);
        
        if ROW_COUNT() > 1 then
		  	rollback;
             leave paymentProcedure;
		end if;
        
        update commisions
        set commision = commision + 10 * avgDealCommission / 100
        where employeeId in (select c.employeeId from commisions order by c.commission desc limit 1 offset 1);
        
        if ROW_COUNT() > 1 then
		  	rollback;
             leave paymentProcedure;
		end if;
        
        update commisions
        set commision = commision + 5 * avgDealCommission / 100
        where employeeId in (select c.employeeId from commisions order by c.commission desc limit 1 offset 2);
        
        if ROW_COUNT() > 1 then
		  	rollback;
             leave paymentProcedure;
		end if;
        
        -- update commisions
        -- set commision = commision + 5 * avgDealCommission / 100
        -- order by commision desc
        -- limit 3; # първите 3 +5%
        -- if ROW_COUNT() <= 3 then
		--  	rollback;
        --     leave paymentProcedure;
		-- end if;
        -- 
        -- update commisions
        -- set commision = commision + 5 * avgDealCommission / 100
        -- order by commision desc
        -- limit 2; # първите 2 +още 5% (общо 10)
        -- if ROW_COUNT() <= 2 then
		-- 	rollback;
        --     leave paymentProcedure;
		-- end if;
        -- 
        -- update commisions
        -- set commision = commision + 5 * avgDealCommission / 100
        -- order by commision desc
        -- limit 1; # първия 1 +още 5% (общо 15)
        -- if ROW_COUNT() <= 1 then
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
        if ROWCOUNT() in (select COUNT(employees.id) from employees) then
			commit;
		else
			rollback;
        end if;
    commit;
end $
delimiter ;

-- test
call commisionPayment(4, 2024);
select * from salaryPayments;

-- задача 3
drop procedure if exists SendEMailToCustomer;
delimiter $
create procedure SendEMailToCustomer(customer_id int, property_id int, discount float) begin
end $
delimiter ;
drop trigger if exists discount_check;
delimiter $
CREATE TRIGGER discount_check after insert ON ads
FOR EACH ROW
BEGIN
	declare ads_active_of_this_user int;
    declare customer_id int;
	declare discount float default 0;
    
	select p.customer_id into customer_id -- c.id into customer_id
		from properties as p
		-- join customers as c on c.id = properties.customer_id
		where p.id = NEW.property_id;

	if customer_id is not null then
		select count(ads.id) into ads_active_of_this_user
			from ads
			join properties on properties.id = ads.property_id
			-- join customers on customers.id = properties.customer_id
			where properties.customer_id = customer_id; -- customers.id = customer_id;

		if ads_active_of_this_user >= 2 AND ads_active_of_this_user <= 6 then
			set discount = 0.5/100;
			call SendEMailToCustomer(customer_id, NEW.property_id, discount);
		elseif ads_active_of_this_user > 6 then
			set discount = 1 / 100;
			call SendEMailToCustomer(customer_id, NEW.property_id, discount);
		end if;
	end if;
END$
delimiter ;

-- задача 4
drop trigger if exists free_check;
delimiter $
CREATE TRIGGER free_check before insert ON ads
FOR EACH ROW
begin
	declare number_of_ads int default 0;
	select count(ads.id) into number_of_ads
		from ads
		join properties on properties.id = ads.property_id
		where properties.customer_id in (
			select p.customer_id
				from properties as p
				where p.id = NEW.property_id
		);
    if number_of_ads > 2 then
		signal sqlstate '45000' set message_text = "Freemium access limits to 2 ads which you are not trying to exceed.";
	end if;
END$
delimiter ;