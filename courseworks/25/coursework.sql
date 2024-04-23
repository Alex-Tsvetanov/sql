/**
[x] 1. Да се проектира база от данни и да се представи ER диаграма със
съответни CREATE TABLE заявки за средата MySQL.
[x] 2. Напишете заявка, в която демонстрирате SELECT с ограничаващо условие
по избор.
[x] 3. Напишете заявка, в която използвате агрегатна функция и GROUP BY по
ваш избор.
[x] 4. Напишете заявка, в която демонстрирате INNER JOIN по ваш избор.
[x] 5. Напишете заявка, в която демонстрирате OUTER JOIN по ваш избор.
[x] 6. Напишете заявка, в която демонстрирате вложен SELECT по ваш избор.
[x] 7. Напишете заявка, в която демонстрирате едновременно JOIN и агрегатна функция.
[x] 8. Създайте тригер по ваш избор.
[x] 9. Създайте процедура, в която демонстрирате използване на курсор.
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
    title varchar(100) not null,
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
    interaction_time time not null,
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

# примерни данни
INSERT INTO dates (this_date) VALUES 
    ('2024-04-21'),
    ('2024-04-20'),
    ('2024-04-19');

INSERT INTO categories (name) VALUES 
    ('Technology'),
    ('Politics'),
    ('Entertainment');

INSERT INTO user_types (name, permissions) VALUES 
    ('Admin', 127),
    ('User', 65),
    ('Publisher', 119);

INSERT INTO users (username, email, phone, user_type_id) VALUES 
    ('admin', 'admin@example.com', '1234567890', 1),
    ('user1', 'user1@example.com', '0987654321', 2),
    ('user2', 'user2@example.com', '1112223334', 2);

INSERT INTO news (title, content, short_summery, author_id, publishing_date, publishing_time) VALUES 
    ('New Technology Advancements', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'Exciting new tech discoveries!', 1, 1, '08:00:00'),
    ('Political Unrest in Region', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'Recent political developments.', 1, 1, '10:00:00'),
    ('New Movie Release', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 'Check out the latest blockbuster!', 1, 1, '12:00:00');

INSERT INTO news_category (news_id, category_id) VALUES 
    (1, 1),
    (2, 2),
    (3, 3);

INSERT INTO comments (header, content, comment_date, comment_time, news_id, user_id) VALUES 
    ('Great news!', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 1, '09:00:00', 1, 2),
    ('Interesting article', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 1, '11:00:00', 2, 3),
    ('Looking forward to it!', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 1, '13:00:00', 3, 2);

INSERT INTO readings (news_id, user_id, reading_date) VALUES 
    (1, 2, 1),
    (2, 3, 1),
    (3, 2, 1);

INSERT INTO interaction_types (type) VALUES 
    ('Like'),
    ('Dislike'),
    ('Share');

INSERT INTO interactions (news_id, user_id, interaction_date, interaction_time, interaction_type) VALUES 
    (1, 2, 1, '09:30:00', 1),
    (2, 3, 1, '11:30:00', 3),
    (3, 2, 1, '13:30:00', 1);

# задачи:

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
# Да се намери броя реакции от даден вид за всяка новини:
DELIMITER $
create procedure news_reactions(in interaction_type_id int)
begin
	SELECT COUNT(interactions.id) from news
    left join interactions on interactions.news_id = news.id
	where interactions.interaction_type = interaction_type_id
	group by interations.news_id;
end $
DELIMITER ;
# [x] 4. Напишете заявка, в която демонстрирате INNER JOIN по ваш избор.
DELIMITER $
create procedure publishers_with_news()
begin
	select news.title, users.username from news
    inner join users on news.author_id = users.id
    where users.user_type_id in (select user_types.id from user_types where user_types.name = "Publishers");
end $
DELIMITER ;
call publishers_with_news();
# [x] 5. Напишете заявка, в която демонстрирате OUTER JOIN по ваш избор.
DELIMITER $
create procedure publishers_without_news()
begin
	select news.title, users.username from news
    left outer join users on news.author_id = users.id
    where users.user_type_id in (select user_types.id from user_types where user_types.name = "Publishers");
end $
DELIMITER ;
call publishers_without_news();
# [x] 6. Напишете заявка, в която демонстрирате вложен SELECT по ваш избор.
DELIMITER $
create procedure all_comments_on_date(in on_date Date)
begin
	select * from comments
    where comments.comment_date in (select dates.id from dates where dates.this_date = on_date);
end $
DELIMITER ;
call all_comments_on_date("2024-04-21");
# [x] 7. Напишете заявка, в която демонстрирате едновременно JOIN и агрегатна
# функция.
# 20 най-коментирани статии за деня:
DELIMITER $
create procedure top_news_most_commented_on(in number_of_top_news int, in on_date Date)
begin
	select news.id as news_id, count(comments.id) as number_of_comments
    from news
    join comments on comments.news_id = news.id
    where comments.comment_date in (select dates.id from dates where dates.this_date = on_date)
    group by news.id
    order by number_of_comments DESC
    limit number_of_top_news;
end $
DELIMITER ;
call top_news_most_commented_on(2, current_date);

# [x] 9. Създайте процедура, в която демонстрирате използване на курсор.
#     each news -> find author of most read -> insert into new table most popular
SET SQL_SAFE_UPDATES = 0;

create table author_of_the_month (
	id int auto_increment primary key,
    author_id int not null,
    constraint foreign key(author_id) references users(id),
    month int,
    constraint CHK_Month CHECK (month>=1 AND month <= 12),
    year int not null
);
DELIMITER $
create procedure get_most_popular_author()
proc_label: begin
	declare current_news_author int default null;
	declare current_news_readings int default 0;
	declare current_news_interactions int default 0;
	declare current_news_id int;
    DECLARE done bool DEFAULT FALSE;
	DECLARE current_news CURSOR FOR SELECT news.id FROM news;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
    drop temporary table author_interactions;
	create temporary table author_interactions(
		id int auto_increment primary key,
		author_id int,
		reads_and_interactions int default 0
	) Engine = Memory;
    
    SELECT news.id FROM news;
	open current_news;
    for_in_news: LOOP
		FETCH current_news INTO current_news_id;
		select current_news_id;
        IF done THEN
            LEAVE for_in_news;
        END IF;
        
        select news.author_id into current_news_author from news where news.id = current_news_id;
        select COUNT(readings.id) into current_news_readings from readings where readings.news_id = current_news_id;
        select COUNT(interactions.id) into current_news_interactions from interactions where interactions.news_id = current_news_id;
        
        insert into author_interactions(author_id, reads_and_interations) values (current_news_author, current_news_readings + current_news_interactions);
    end loop for_in_news;
    
    insert into author_of_the_month (author_id, month, year)
		select author_interactions.author_id, month(now()), year(now()) from author_interactions
		order by author_interactions.reads_and_interactions desc
		limit 1;
end $
DELIMITER ;
call get_most_popular_author();
select * from author_of_the_month;
