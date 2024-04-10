/*
Проектирайте и създайте база данни, съхраняваща информация за новинарски сайт. Новините,
които пишат редакторите ще бъдат публикувани в различни категории – спорт, крими и т.н. Към
всяка новина трябва да могат да се добавят както изображения, така и видео материали.
Читателите могат да коментират новините, но за целта трябва да са регистрирани. Ако някой
потребител наруши правилата за поведение – неговият акаунт може да бъде изтрит от
администратор
*/
DROP DATABASE IF EXISTS lab2_ex;
CREATE DATABASE lab2_ex;
use lab2_ex;

create table categories (
	id INT auto_increment primary key,
    name text not null
);

create table media_types (
	id int auto_increment primary key,
    mime VARCHAR(20) NOT NULL
);

create table media_resources (
	id int auto_increment primary key,
    server_location text not null UNIQUE,
    type_id INT NOT NULL,
    constraint foreign key(type_id) references media_types(id)
);

create table user_types (
	id int auto_increment primary key,
    name text not null,
    permissions int not null /*binary number - 1 bit for each permission*/
);

create table users (
	id int auto_increment primary key,
    username varchar(40) not null unique,
    email varchar(30) not null unique,
    phone varchar(14),
    user_type_id int not null,
    constraint foreign key(user_type_id) references user_types(id)
);

create table news (
	id int auto_increment primary key,
    title text not null,
    content text not null,
    short_summery text not null,
    author_id int not null,
    constraint foreign key(author_id) references users(id)
);

create table news_media (
	id int auto_increment primary key,
    news_id int not null,
    media_id int not null,
    constraint foreign key(news_id) references news(id),
    constraint foreign key(media_id) references media_resources(id)
);

create table user_ipv4s (
	id int auto_increment primary key,
    ipv4 binary(32),
    user_id int,
    constraint foreign key(user_id) references users(id)
);

create table user_ipv6s (
	id int auto_increment primary key,
    ipv6 binary(128),
    user_id int,
    constraint foreign key(user_id) references users(id)
);

create table comments (
	id int auto_increment primary key,
    header text not null,
    content text not null,
    news_id int not null,
    user_id int not null,
    constraint foreign key(user_id) references users(id),
    constraint foreign key(news_id) references news(id),
    constraint User_News_Content unique (user_id, news_id, content)
);
    