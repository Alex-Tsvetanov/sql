/**
[x] 1. Да се проектира база от данни и да се представи ER диаграма със
съответни CREATE TABLE заявки за средата MySQL.
[x] 2. Напишете заявка, в която демонстрирате SELECT с ограничаващо условие
по избор.
[x] 3. Напишете заявка, в която използвате агрегатна функция и GROUP BY по
ваш избор.
[ ] 4. Напишете заявка, в която демонстрирате INNER JOIN по ваш избор.
[ ] 5. Напишете заявка, в която демонстрирате OUTER JOIN по ваш избор.
[x] 6. Напишете заявка, в която демонстрирате вложен SELECT по ваш избор.
[x] 7. Напишете заявка, в която демонстрирате едновременно JOIN и агрегатна функция.
[x] 8. Създайте тригер по ваш избор.
[ ] 9. Създайте процедура, в която демонстрирате използване на курсор.
	each news -> find author of most read -> insert into new table most popular

Вашата работа трябва да включва: задание, ER-диаграма, CREATE TABLE
заявки, всички останали заявки, решения на задачите от 2 до 9 и
резултатите от тях.

Тема № 25
Напишете база данни за новинарско уеб приложение. Новините да могат да се
преглеждат по категории, дата, популярност. Коментари под всяка новина могат да
пишат само регистрирани потребители. Да реализира възможност за извеждане на
статистическа информация – напр. най-четена публикация за месеца, 20 най-коментирани статии за деня, 
най-популярните автори за седмицата и т.н. 

*/
DROP DATABASE IF EXISTS coursework_web_news;

# [x] 1. Да се проектира база от данни и да се представи ER диаграма със
# съответни CREATE TABLE заявки за средата MySQL.

CREATE DATABASE coursework_web_news;
USE coursework_web_news;

/* Event dates */
create table dates (
	id int auto_increment primary key,
    this_date DATE not null
);

/* News category */
create table categories (
	id INT auto_increment primary key,
    name text not null
);

/* User permissions */
create table user_types (
	id int auto_increment primary key,
    name text not null,
    permissions int not null /*binary number - 1 bit for each permission*/
);

/* Users */
create table users (
	id int auto_increment primary key,
    username varchar(40) not null unique,
    email varchar(30) not null unique,
    phone varchar(14),
    user_type_id int not null,
    constraint foreign key(user_type_id) references user_types(id)
);

/* News */
create table news (
	id int auto_increment primary key,
    title text not null,
    content text not null,
    short_summery text not null,
    author_id int not null,
    publishing_date int not null,
    publishing_time time not null,
    constraint foreign key(author_id) references users(id),
    constraint foreign key(publishing_date) references dates(id),
    constraint unique key(title, publishing_date)
);

/* Many2Many News-Category */
create table news_category (
	id int auto_increment primary key,
    news_id int not null,
    category_id int not null,
    constraint foreign key(news_id) references news(id),
    constraint foreign key(category_id) references categories(id)
);

/* Comments by user per news */
create table comments (
	id int auto_increment primary key,
    header text not null,
    content text not null,
    comment_date int not null,
    comment_time time not null,
    news_id int not null,
    user_id int not null, /* not null = only registered users */
    constraint foreign key(user_id) references users(id),
    constraint foreign key(news_id) references news(id),
    constraint foreign key(comment_date) references dates(id),
    constraint User_News_Content unique (user_id, news_id, comment_date, comment_time)
);

/* Times a user read each news */
create table readings (
	id int auto_increment primary key,
    news_id int not null,
    user_id int not null,
    reading_date int not null,
    constraint foreign key(reading_date) references dates(id),
    constraint foreign key(user_id) references users(id),
    constraint foreign key(news_id) references news(id)
);

/* Interaction types - likes, dislikes, shares */
create table interaction_types (
	id int auto_increment primary key,
    type text not null
);

/* Interactions per post */
create table interactions (
	id int auto_increment primary key,
    news_id int,
    comment_id int,
    user_id int not null,
    interaction_date int not null,
    interaction_time int not null,
    interaction_type int not null,
    constraint foreign key(interaction_type) references interaction_types(id),
    constraint foreign key(interaction_date) references dates(id),
    constraint foreign key(user_id) references users(id),
    constraint foreign key(news_id) references news(id),
    constraint foreign key(comment_id) references comments(id),
    constraint User_News unique (user_id, news_id)
);

# [x] 8. Създайте тригер по ваш избор.
DELIMITER $
CREATE DEFINER=`root`@`localhost` TRIGGER `interactions_BEFORE_INSERT` BEFORE INSERT ON `interactions` FOR EACH ROW BEGIN
    IF (SELECT ((new.news_id IS NULL) + (new.comment_id IS NULL)) <> 1)
    THEN
		 SIGNAL SQLSTATE VALUE '45000'
		 set MESSAGE_TEXT='Only 1 of news_id and comment_id should be set', MYSQL_ERRNO = 1001;
    END IF;
END$
DELIMITER ;

DELIMITER $
CREATE DEFINER=`root`@`localhost` TRIGGER `interactions_BEFORE_UPDATE` BEFORE UPDATE ON `interactions` FOR EACH ROW BEGIN
    IF (SELECT ((new.news_id IS NULL) + (new.comment_id IS NULL)) <> 1)
    THEN
		 SIGNAL SQLSTATE VALUE '45000'
		 set MESSAGE_TEXT='Only 1 of news_id and comment_id should be set', MYSQL_ERRNO = 1001;
    END IF;
END$
DELIMITER ;

# Да реализира възможност за извеждане на
# статистическа информация – напр. най-четена публикация за месеца, 20 най-коментирани статии за деня, 
# най-популярните автори за седмицата и т.н. 
# [x] 2. Напишете заявка, в която демонстрирате SELECT с ограничаващо условие
# по избор.
# Да се намери общия брой харесвания на всички новини:
DELIMITER $
create procedure total_news_likes()
begin
	SELECT COUNT(interactions.id) from interactions
	where interactions.interaction_type = "Like"
	and interations.news_id IS not null;
end $
DELIMITER ;

# [x] 3. Напишете заявка, в която използвате агрегатна функция и GROUP BY по
# ваш избор.
# Да се намери общия брой реакции от даден видид за дадена новини:
DELIMITER $
create procedure total_news_likes()
begin
	SELECT COUNT(interactions.id) from interactions
	where interactions.interaction_type = "Like"
	and interations.news_id IS not null;
end $
DELIMITER ;
# [x] 6. Напишете заявка, в която демонстрирате вложен SELECT по ваш избор.
# [x] 7. Напишете заявка, в която демонстрирате едновременно JOIN и агрегатна
# функция.
# 20 най-коментирани статии за деня:
DELIMITER $
create procedure top20most_commented_on(in on_date Date)
begin
	select news.id
    from news
    join comments on comments.news_id = news.id
    where comments.comment_date in (select dates.id from dates where dates.this_date = on_date)
    group by news.id
    order by count(comments.id) DESC;
end $
DELIMITER ;
call top20most_commented_on(current_date);
