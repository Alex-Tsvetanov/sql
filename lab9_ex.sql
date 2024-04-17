use `school_sport_clubs`;

/*
1. Създайте тригер, който при изтриване на информация от таблицата
salarypayments записва изтритата информация в таблицата
salarypayments_log.
*/

DROP TRIGGER if exists after_salarypayment_delete;
delimiter |
CREATE TRIGGER after_salarypayment_delete AFTER DELETE ON salarypayments
FOR EACH ROW 
BEGIN
INSERT INTO salarypayments_log(
	operation,
	old_coach_id,
	new_coach_id,
	old_month,
	new_month,
	old_year,
	new_year,
	old_salaryAmount,
	new_salaryAmount,
	old_dateOfPayment,
	new_dateOfPayment,
	dateOfLog
)
VALUES (
	'DELETE',
	OLD.coach_id,
    NULL,
	OLD.month,
    NULL,
	OLD.year,
    NULL,
	OLD.salaryAmount,
    NULL,
	OLD.dateOfPayment,
    NULL,
	NOW()
);
END;
|
Delimiter ;

select * from `salarypayments`;
delete from `salarypayments`;
select * from salarypayments_log;

/*
2. Изтрийте цялата информация от таблицата salarypayments. Напишете
заявка, с която я възстановявате от таблицата salarypayments_log .
*/

INSERT INTO `salarypayments` (coach_id, month, year, salaryAmount, dateOfPayment)
select old_coach_id as coach_id, old_month as month, old_year as year, old_salaryAmount as salaryAmount,
       old_dateOfPayment as dateOfPayment from `salarypayments_log`
where `salarypayments_log`.`operation` = "DELETE";
select * from salarypayments_log;
select * from `salarypayments`;

/*
3. Съгласно въведено ограничение всеки ученик може да тренира в не
повече от 2 групи. Напишете тригер, правещ съответната проверка при
добавяне, който при необходимост да извежда съобщение за
проблема.
*/

DROP TRIGGER if exists before_student_sport_insert;
delimiter |
CREATE TRIGGER before_student_sport_insert BEFORE INSERT ON student_sport
FOR EACH ROW 
BEGIN
	IF ((SELECT COUNT(sportGroup_id) from student_sport where student_id = NEW.student_id) >= 2)
    THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The student is already registered in 2 groups.';
    end if;
END
|
delimiter ;
SELECT sportGroup_id from student_sport where student_id = 1;
insert into student_sport(student_id, sportGroup_id) VALUES (1, 1);
insert into student_sport(student_id, sportGroup_id) VALUES (1, 2);
insert into student_sport(student_id, sportGroup_id) VALUES (1, 3);
insert into student_sport(student_id, sportGroup_id) VALUES (1, 4);
insert into student_sport(student_id, sportGroup_id) VALUES (1, 5);
insert into student_sport(student_id, sportGroup_id) VALUES (1, 6);

/*
4. Създайте VIEW, което да носи информация за трите имена на
учениците и броя на групите, в които тренират.
*/

create view `task4` as
select students.name, count(student_sport.sportGroup_id) 
from students 
join student_sport on student_sport.student_id = students.id
group by students.id;

select * from `task4`;

/*
5. Създайте процедура, която при подадени имена на треньор извежда
всички имената на всеки ученик, които тренира при него, id на групата
и името на спорта.
*/

DROP PROCEDURE if exists task5;
delimiter |
create procedure `task5`(in coach_name VARCHAR(1000))
begin
	select student_sport.sportGroup_id, sports.name, students.name
    from coaches
    join sportgroups on sportgroups.coach_id = coaches.id
    join sports on sports.id = sportgroups.sport_id
    join student_sport on student_sport.sportGroup_id = sportgroups.id
    join students on students.id = student_sport.student_id
    where coaches.name = coach_name;
end |
delimiter ;
call task5("Ivan Todorov Petkov");

/*
6. Напишете процедура, с която по подадено име на спорт се извеждат
имената на треньорите, които водят съответните групи, мястото, часът
и денят на тренировка.
*/

DROP PROCEDURE if exists task6;
delimiter |
create procedure `task6`(in sport_name VARCHAR(1000))
begin
	select coaches.name, sportgroups.location, sportgroups.location, sportgroups.hourOfTraining, sportgroups.dayOfWeek
    from sports
    join sportgroups on sports.id = sportgroups.sport_id
    join coaches on sportgroups.coach_id = coaches.id
    where sports.name = sport_name;
end |
delimiter ;
call task6("Volleyball");