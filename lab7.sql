use school_sport_clubs;
# 1. Създайте процедура, с която по подадено име на треньор се извеждат
# името на спорта, мястото, часът и денят на тренировка, както и имената и
# телефоните на учениците, които тренират.

delimiter $
drop procedure if exists task1 $
create procedure task1(in coach_name VARCHAR(255))
begin
	select sports.name, sportGroups.location, sportGroups.hourOfTraining, students.name, students.phone
    from coaches
    join sportGroups on sportGroups.coach_id = coaches.id
    join sports on sports.id = sportGroups.sport_id
    join student_sport on student_sport.sportGroup_id = sportGroups.id
    join students on students.id = student_sport.student_id
    where coaches.name = coach_name;
end $
delimiter ;
call task1("Ivan Todorov Petkov");

# 2. Създайте процедура, с която по подадено id на спорт се извеждат: името
# на спорта, имената на учениците, които тренират и имената на треньорите,
# които водят тренировките по този спорт.

delimiter $
drop procedure if exists task2 $
create procedure task2(in sport_id integer)
begin
	select sports.name, students.name, coaches.name
    from sports
    join sportGroups on sports.id = sportGroups.sport_id   
    join coaches on sportGroups.coach_id = coaches.id
    join student_sport on student_sport.sportGroup_id = sportGroups.id
    join students on students.id = student_sport.student_id
    where sports.id = sport_id;
end $
delimiter ;
call task2(1);

# 3. Създайте процедура, която по подадено име на студент и година извежда
# средната сума на платените от него такси.

delimiter $
drop procedure if exists task3 $
create procedure task3(in student_name varchar(255), in year integer)
begin
	select AVG(taxesPayments.paymentAmount)
    from students
    join taxesPayments on taxesPayments.student_id = students.id
    where students.name = student_name
    and taxesPayments.year = year;
end $
delimiter ;
call task3("Iliyan Ivanov", 2022);

# 4. Създайте процедура, която по подадено име треньор извежда броя
# водените от него групи или съобщение – ако този брой е 0.

delimiter $
drop procedure if exists task4 $
create procedure task4(in coach_name varchar(255))
begin
	IF (0 IN (select COUNT(student_sport.student_id)
    from coaches
    join sportGroups on coaches.id = sportGroups.coach_id
    join student_sport on student_sport.sportGroup_id = sportGroups.id
    where coaches.name = coach_name))
    then
		SELECT "No students here" as error_message;
	else
		select COUNT(student_sport.student_id) as students_count
		from coaches
		join sportGroups on coaches.id = sportGroups.coach_id
		join student_sport on student_sport.sportGroup_id = sportGroups.id
		where coaches.name = coach_name;
	end if;
end $
delimiter ;
call task4("Ivan Todorov Petkov");
call task4("no coach");

# 5. Използвайте базата данни transaction_test. Създайте процедура за
# прехвърляне на пари от една сметка в друга. Нека процедурата да извежда
# съобщение за грешка ако няма достатъчно пари, за да се осъществи
# успешно трансакцията или ако трансакцията е неуспешна. За целта може да
# използвате функцията ROW_COUNT(), която връща броя на засегнатите
# редове след последната Update или Delete заявка. Процедурата да получава
# като параметри ID на сметката от която се прехвърля, ID на сметката на
# получателя и сумата, която трябва да се преведе
use transaction_test;

delimiter $
drop procedure if exists task5 $
create procedure task5(in money_to_transfer float, in from_account_id int, in to_account_id int)
begin
	start transaction;
    if ((select currency from customer_accounts where id = from_account_id) <> (select currency from customer_accounts where id = to_account_id))
    then
		select "Not the same currency, can't transfer" as error_message;
        rollback;
	else
		if ((select amount from customer_accounts where id = from_account_id) < money_to_transfer)
		then
			select "Not enough money, can't transfer" as error_message;
			rollback;
		else
			update customer_accounts
			set amount = amount - money_to_transfer
			where id = from_account_id;
			if (ROW_COUNT() = 1)
			then
				update customer_accounts
				set amount = amount + money_to_transfer
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
	end if;
end $
delimiter ;
call task5(4000, 1, 3);
call task5(4000, 3, 1);
call task5(6000, 1, 3);
call task5(4000, 1, 2);