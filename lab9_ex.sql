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
/*
4. Създайте VIEW, което да носи информация за трите имена на
учениците и броя на групите, в които тренират.
*/
/*
5. Създайте процедура, която при подадени имена на треньор извежда
всички имената на всеки ученик, които тренира при него, id на групата
и името на спорта.
*/
/*
6. Напишете процедура, с която по подадено име на спорт се извеждат
имената на треньорите, които водят съответните групи, мястото, часът
и денят на тренировка.
*/