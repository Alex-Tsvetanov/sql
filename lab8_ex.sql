USE school_sport_clubs;
#1. Създайте VIEW, с което извеждате информация за името на треньора, името на спорта,
#чийто тренировки води, информация за група, която тренира, както и сумата, която е
#получил за текущия месец. Резултатната таблица трябва да изглежда така:
drop view if exists `task1`;

create view `task1` AS
	select coaches.name as name, concat(sportgroups.id, " - ", sportgroups.location) as groupInfo, sports.name as sport, 
		salarypayments.year as year, salarypayments.month as month, salarypayments.salaryAmount as salaryAmount
	from coaches
	join sportgroups on sportgroups.coach_id = coaches.id
	join sports on sports.id = sportgroups.sport_id
	join salarypayments on salarypayments.coach_id = coaches.id
;

select * from `task1`;

#2. Създайте процедура, която извежда името на всеки студент, който тренира в повече от
#една група.
drop procedure if exists multisportStudents;
delimiter |
create procedure multisportStudents()
begin
	select students.name
    from students
    join student_sport on student_sport.student_id = students.id
    group by students.id
    having COUNT(student_sport.sportGroup_id) > 1;
end |
delimiter ;
call multisportStudents();

#3. Напишете процедура, която извежда имената на всички треньори, които не тренират
#групи.
drop procedure if exists noGroupsCoaches;
delimiter |
create procedure noGroupsCoaches()
begin
	select coaches.name
    from coaches
    left join sportGroups on sportGroups.coach_id = coaches.id
    group by coaches.id
    having COUNT(sportGroups.id) = 0;
end |
delimiter ;
call noGroupsCoaches();

#4. Използвайте базата данни transaction_test. Създайте процедура, която конвертира суми
#от лева в евро и обратно по курса на БНБ. за прехвърляне на пари от една сметка в друга.
use `transaction_test`;

delimiter $
drop procedure if exists convertEUR_BGN $
create procedure convertEUR_BGN(in from_amount float, in from_currency ENUM('EUR', 'BGN'), in to_currency ENUM('EUR', 'BGN'), out to_amount float)
begin
	if (from_currency = to_currency) then
		set to_amount = from_amount;
	else
		if (from_currency = 'BGN') then
			set to_amount = from_amount * 0.51;
		else
			set to_amount = from_amount * 1.96;
		end if;
	end if;
end $
delimiter ;
set @out_amount = 0;
call convertEUR_BGN(100, 'BGN', 'EUR', @out_amount); select @out_amount;
call convertEUR_BGN(100, 'EUR', 'EUR', @out_amount); select @out_amount;
call convertEUR_BGN(100, 'BGN', 'BGN', @out_amount); select @out_amount;
call convertEUR_BGN(100, 'EUR', 'BGN', @out_amount); select @out_amount;
#5. Създайте процедура за прехвърляне на пари от една сметка в друга. Нека процедурата
#да извежда съобщение за грешка ако няма достатъчно пари, за да се осъществи успешно
#трансакцията или ако трансакцията е неуспешна. Направете проверка за вида на
#валутите, в които са сметките – ако са в лева или евро – извикайте процедурата от
#предишната задача, в противен случай изведете съобщение за грешка и прекратете
#процедурата. Нека тя да получава като параметри ID на сметката от която се прехвърля,
#ID на сметката на получателя и сумата, която трябва да се преведе.
use `transaction_test`;
delimiter $
drop procedure if exists task5 $
create procedure task5(in money_to_transfer float, in from_account_id int, in to_account_id int)
begin
    declare amount_from float;
    declare amount_to float;
    declare from_currency ENUM('BGN', 'EUR');
    declare to_currency ENUM('BGN', 'EUR');
	transfer: 
    begin
		if ((select count(id) from customer_accounts where id = from_account_id) <> 1)
		then
			select "Can't find sender's account" as error_message;
			leave transfer;
		end if;
		if ((select count(id) from customer_accounts where id = to_account_id) <> 1)
		then
			select "Can't find receiver's account" as error_message;
			leave transfer;
		end if; 
		start transaction;
		set amount_from = money_to_transfer;
		set amount_to = money_to_transfer;
		select currency into from_currency from customer_accounts where id = to_account_id;
		select currency into to_currency from customer_accounts where id = to_account_id;
		call convertEUR_BGN(amount_from, from_currency, to_currency, amount_to);
		if ((select amount from customer_accounts where id = from_account_id) < amount_from)
		then
			select "Not enough money, can't transfer" as error_message;
			rollback;
		else
			update customer_accounts
			set amount = amount - amount_from
			where id = from_account_id;
			if (ROW_COUNT() = 1)
			then
				update customer_accounts
				set amount = amount + amount_to
				where id = to_account_id;
				if (ROW_COUNT() = 1)
				then
					select "Success" as error_message;
					commit;
				else
					select "Can't update receiver's account" as error_message;
					rollback;
				end if;
			end if;
		end if;
	end;
end $
delimiter ;
call task5(4000, 1, 3);
call task5(4000, 3, 1);
call task5(6000, 1, 3);
call task5(4000, 1, 2);
call task5(4000, 2, 1);