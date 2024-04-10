use school_sport_clubs;

SELECT sports.name, sportgroups.location
FROM sports
INNER JOIN sportgroups ON sportgroups.sport_id = sports.id;

SELECT sports.name, sportgroups.location
FROM sports
LEFT OUTER JOIN sportgroups ON sportgroups.sport_id = sports.id;

SELECT sports.name, sportgroups.location
FROM sports
RIGHT OUTER JOIN sportgroups ON sportgroups.sport_id = sports.id
where sports.id is NULL;

SELECT sports.name, sportgroups.location
FROM sports
LEFT OUTER JOIN sportgroups ON sportgroups.sport_id = sports.id
where sportgroups.sport_id is NULL;

SELECT sports.name, coaches.name
FROM sports
JOIN sportgroups ON sportgroups.sport_id = sports.id
JOIN coaches ON coaches.id = sportgroups.coach_id;

SELECT sports.name, coaches.name
FROM sports
JOIN coaches ON sports.id in (select sport_id from sportgroups where sportgroups.coach_id=coaches.id);