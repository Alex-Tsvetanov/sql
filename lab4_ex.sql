/*Използвайте базата данни school_sport_clubs за задачи от 1 до 4.*/
use school_sport_clubs;
/*1. Изведете имената, класовете и телефоните на всички ученици, които тренират футбол.*/
select students.name, students.class, students.phone from students
where students.id in (
	select student_id from student_sport 
    where student_sport.sportGroup_id in (
		select sportgroups.id from sportgroups
        where sportgroups.sport_id in (
			select sports.id from sports 
			where sports.name = "Football"
		)
	)
);
/*2. Изведете имената на всички треньори по волейбол.*/
select coaches.name from coaches
where coaches.id in (
	select coach_id from sportgroups 
    where sportgroups.sport_id in (
		select sports.id from sports 
        where sports.name = "Volleyball"
	)
);
/*3. Изведете името на треньора и спорта, който тренира ученик с име Илиян Иванов.*/
select 
	(select coaches.name from coaches where coaches.id = sportgroups.coach_id) as coach_name, 
    (select sports.name from sports where sports.id = sportgroups.sport_id) as sport_name 
from sportgroups
where sportgroups.id in (
	select student_sport.sportGroup_id from student_sport
	where student_sport.student_id in (
		select students.id from students where name = 'Iliyan Ivanov'
	)
);
/*4. Изведете имената на учениците, класовете им, местата на тренировки и името на треньорите за тези ученици, чийто тренировки започват в 8.00 часа.*/
select
	students.name,
	students.class,
	sportgroups.location as location,
	(select coaches.name from coaches where coaches.id = sportgroups.coach_id) as coach_name, 
    (select sports.name from sports where sports.id = sportgroups.sport_id) as sport_name 
from sportgroups
join students on students.id in (
	select student_id from student_sport
    where sportGroup_id = sportgroups.id
)
where 
	sportgroups.id in (
		select student_sport.sportGroup_id from student_sport
		where student_sport.student_id in (
			select students.id from students where name = 'Iliyan Ivanov'
		)
	)
    AND
    sportgroups.hourOfTraining = "8:00:00"
;
/*5. Проектирайте и създайте база данни за уеб система за болница.
Пази се информация за всички лекари, работещи в болницата – три имена, кабинет, специализация (личен лекар, очен лекар, уши нос гърло и т.н.), 
работи ли се със здравната каса, телефонен номер и имейл. Съхраняват се също и данни за пациентите, лекувани от всеки лекар. За пациентите се пази
следната информация: три имена, адрес, ЕГН, диагноза, предписано лечение и медикаменти, както и период на лечението. 
Допълнете таблиците с необходима информация по ваш избор.
*/
drop database if exists `hospital`;
create database `hospital`;
use `hospital`;

/*кабинет*/
create table rooms (
	id int auto_increment primary key,
    number varchar(5) not null,
    level int not null,
    constraint unique key(number, level)
);

/*специализация (личен лекар, очен лекар, уши нос гърло и т.н.)*/
create table specialization (
	id int auto_increment primary key,
    name varchar(40) not null unique
);

/*всички лекари, работещи в болницата*/
create table doctors (
	id int auto_increment primary key,
    name varchar(100) not null,
    room_id int not null,
    constraint foreign key(room_id) references rooms(id),
    nzok bool not null,
    phone varchar(14) not null,
    email varchar(30)
);

/*всички лекари <-> специализация*/
create table doctor_specialization (
	id int auto_increment primary key,
    doctor_id int not null,
    constraint foreign key(doctor_id) references doctors(id),
    specialization_id int not null,
    constraint foreign key(specialization_id) references specialization(id)
);

/*За пациентите се пази следната информация: три имена, адрес, ЕГН, диагноза, предписано лечение и медикаменти, както и период на лечението. */
create table patients (
	id int auto_increment primary key,
    name varchar(100) not null,
    address varchar(50),
    egn char(10) not null
);
/*лечения*/
create table medications (
	id int auto_increment primary key,
	diagnose varchar(1000) not null,
    medication varchar(1000)
);
/*всички лекари <-> пациенти*/
create table doctor_patient (
	id int auto_increment primary key,
    doctor_id int not null,
    constraint foreign key(doctor_id) references doctors(id),
    patient_id int not null,
    constraint foreign key(patient_id) references patients(id),
    medication_id int,
    constraint foreign key(medication_id) references medications(id),
    start_medication datetime,
    end_medication datetime,
    constraint unique key(doctor_id, patient_id, medication_id, start_medication, end_medication)
);