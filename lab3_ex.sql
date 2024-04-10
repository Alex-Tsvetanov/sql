/*Използвайте базата данни school_sport_clubs.*/
use `school_sport_clubs`;

/*1. Напишете заявка, с която добавяте нов запис в таблицата students – Ivan Ivanov Ivanov с ЕГН: 9207186371, адрес: София-Сердика, клас 10, телефон: 0888892950.*/
INSERT into students(name, egn, address, class, phone) VALUES ('Ivan Ivanov Ivanov', '9207186371', 'София-Сердика', 10, '0888892950');

/*2. Изведете цялата информация в таблицата students, подредена по азбучен ред.*/
select * from students order by name ASC;

/*3. Напишете заявка, с която ще изтриете добавения в т. 1 запис.*/
delete from students where egn='9207186371';

/*4. Напишете заявка, с която ще изведете името на всеки ученик и спорта, който той тренира.*/
select DISTINCT students.name, sports.name
from students
join student_sport on student_sport.student_id = students.id
join sportgroups on sportgroups.id = student_sport.sportGroup_id
join sports on sportgroups.sport_id = sports.id;

/*5. Изведете имената на учениците и класовете им, както и номера (id) на групата, в която
тренират, но само за ученици, които тренират в понеделник.*/
select DISTINCT students.name, students.class, sportgroups.id
from students
join student_sport on student_sport.student_id = students.id
join sportgroups on sportgroups.id = student_sport.sportGroup_id
where sportgroups.dayOfWeek = 'Monday';

/*6. Изведете имената на всички треньори, които провеждат тренировки по футбол.*/
select coaches.name from coaches
where coaches.id in (
	select coach_id from sportgroups 
    where sportgroups.sport_id in (
		select sports.id from sports 
        where sports.name = "Football"
	)
);
/*7. Напишете заявка, с която ще изведете местоположението, началния час и деня, в който се
провеждат всички тренировки по волейбол.*/
select sportgroups.location, sportgroups.hourOfTraining, sportgroups.dayOfWeek from sportgroups
where sportgroups.sport_id in (
	select id from sports
    where sports.name = "Volleyball"
);
/*8. Напишете заявка, с която ще изведете всички спортове, които тренира ученик с име Iliyan
Ivanov.*/
select sports.name from sports
where sports.id in (
	select sportgroups.sport_id
	from sportgroups
	where sportgroups.id in (
		select student_sport.sportGroup_id
		from student_sport
		where student_sport.student_id in (
			select students.id
			from students
			where students.name = "Iliyan Ivanov"
		)
	)
);
/*9. Изведете имената на всички ученици, които тренират футбол при треньор с име Ivan Todorov
Petkov.*/
select students.name
from students
where students.id in (
	select student_sport.student_id
	from student_sport
	where student_sport.sportGroup_id in (
		select sportgroups.id
		from sportgroups
		where sportgroups.coach_id in (
			select coaches.id from coaches where coaches.name = "Ivan Todorov Petkov"
		)
	)
);

/*10. Проектирайте и създайте база данни, обслужваща автосервиз. Да се съхранява информация
за предлаганите услуги, извършените ремонти, клиентите и техните автомобили, както и
служителите, обслужвали всяко МПС.*/
DROP DATABASE IF EXISTS autoservice;
CREATE DATABASE autoservice;
use autoservice;

create table services (
	id int auto_increment primary key,
    name varchar(100) not null
);

create table employees (
	id int auto_increment primary key,
    name varchar(100) not null,
    egn char(10) not null,
    iban varchar(30) not null
);

create table clients (
	id int auto_increment primary key,
    name varchar(100) not null,
    phone_number varchar(14) not null
);

create table vehicles (
	id int auto_increment primary key,
    model varchar(100) not null,
    reg_number char(8) not null,
    owner_id int not null,
    constraint foreign key(owner_id) references clients.id
);

create table orders (
	id int auto_increment primary key,
    type int not null,
    constraint foreign key(type) references services.id,
    vehicle_id int not null,
    constraint foreign key(vehicle_id) references vehicles.id,
    employee_id int not null,
    constraint foreign key(employee_id) references employees.id
);
