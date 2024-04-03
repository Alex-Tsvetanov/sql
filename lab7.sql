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

# 3. Създайте процедура, която по подадено име на студент и година извежда
# средната сума на платените от него такси.
# 4. Създайте процедура, която по подадено име треньор извежда броя
# водените от него групи или съобщение – ако този брой е 0.
# 5. Използвайте базата данни transaction_test. Създайте процедура за
# прехвърляне на пари от една сметка в друга. Нека процедурата да извежда
# съобщение за грешка ако няма достатъчно пари, за да се осъществи
# успешно трансакцията или ако трансакцията е неуспешна. За целта може да
# използвате функцията ROW_COUNT(), която връща броя на засегнатите
# редове след последната Update или Delete заявка. Процедурата да получава
# като параметри ID на сметката от която се прехвърля, ID на сметката на
# получателя и сумата, която трябва да се преведе