DROP DATABASE IF EXISTS School;
CREATE DATABASE School;
USE School;

CREATE TABLE IF NOT EXISTS Day_of_week (
    id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Days of the week',
    dayOfWeek ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Slots (
    id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Slots',
    start TIME NOT NULL,
    end TIME NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Clubs (
    id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Clubs',
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Sports (
    id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Sports',
    name VARCHAR(10) NOT NULL,
    club_id INTEGER NOT NULL,
    PRIMARY KEY (id),
    foreign key (club_id) REFERENCES Clubs(id)
);

CREATE TABLE IF NOT EXISTS Trainer (
	id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Trainers',
    name VARCHAR(40) NOT NULL,
    email VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Locations (
	id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Locations',
    address VARCHAR(40) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Students (
	id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Students',
    name VARCHAR(40) NOT NULL,
    phone VARCHAR(14),
    email VARCHAR(14),
    PRIMARY KEY (id),
    CONSTRAINT Contact_info_phone UNIQUE (phone),
    CONSTRAINT Contact_info_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS PracticeGroup (
	id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Practice groups',
    capacity INTEGER NOT NULL,
    day_id INTEGER,
    slot_id INTEGER,
    trainer_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY (id),
    foreign key (day_id) REFERENCES Day_of_week(id),
    foreign key (slot_id) REFERENCES Slots(id),
    foreign key (trainer_id) REFERENCES Trainer(id),
    foreign key (location_id) REFERENCES Locations(id),
    CONSTRAINT PracticeGroup_day_time_location UNIQUE (day_id, slot_id, location_id)
);

CREATE TABLE IF NOT EXISTS Student_PracticeGroup (
	id INTEGER AUTO_INCREMENT COMMENT 'Primary key for Student-Practice group relationship',
    student_id INTEGER,
    practice_group_id INTEGER,
    PRIMARY KEY (id),
    foreign key (student_id) REFERENCES Students(id),
    foreign key (practice_group_id) REFERENCES PracticeGroup(id)
);

