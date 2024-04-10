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


#4. Използвайте базата данни transaction_test. Създайте процедура, която конвертира суми
#от лева в евро и обратно по курса на БНБ. за прехвърляне на пари от една сметка в друга.

#5. Създайте процедура за прехвърляне на пари от една сметка в друга. Нека процедурата
#да извежда съобщение за грешка ако няма достатъчно пари, за да се осъществи успешно
#трансакцията или ако трансакцията е неуспешна. Направете проверка за вида на
#валутите, в които са сметките – ако са в лева или евро – извикайте процедурата от
#предишната задача, в противен случай изведете съобщение за грешка и прекратете
#процедурата. Нека тя да получава като параметри ID на сметката от която се прехвърля,
#ID на сметката на получателя и сумата, която трябва да се преведе.
