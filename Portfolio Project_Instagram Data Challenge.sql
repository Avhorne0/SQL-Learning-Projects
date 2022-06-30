/*We want to reward our users who have been around the longest.  
Find the 5 oldest users.*/

USE ig_clone;

SELECT TOP(5)
id, username, created_at
FROM ig_clone.dbo.users
ORDER BY created_at ASC


/*What day of the week do most users register on?
We need to figure out when to schedule an ad campgain*/

SELECT DATENAME(Weekday,created_at) AS 'day of the week', COUNT(*) AS 'Total Registration'
FROM users
GROUP BY DATENAME(Weekday,created_at)
ORDER BY 2 DESC;

SELECT 
    DATENAME(Weekday,created_at) AS 'day',
    COUNT(*) AS 'total'
FROM users
GROUP BY DATENAME(Weekday,created_at)
ORDER BY 'total' DESC 
/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/

SELECT username
FROM ig_clone.dbo.users
LEFT JOIN ig_clone.dbo.photos ON users.id = photos.user_id
WHERE photos.id IS NULL

/*We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/

SELECT TOP (5)
users.username, photos.id, photos.image_url, COUNT(*) AS 'Total Likes'
FROM ig_clone.dbo.users
JOIN ig_clone.dbo.photos ON users.id = photos.user_id
JOIN ig_clone.dbo.likes ON photos.id = likes.photo_id
GROUP BY photos.id,users.username, photos.id, photos.image_url
ORDER BY COUNT(*) DESC


/*Our Investors want to know...How many times does the average user post?*/
/*total number of photos/total number of users*/
--Version 1
SELECT CONVERT(DECIMAL(5,2),((SELECT COUNT(*) FROM photos)* 1.0/(SELECT COUNT(*) FROM Users)))
--Version 2
SELECT (SELECT COUNT(*) FROM photos)/ CONVERT(DECIMAL(5,2),(SELECT COUNT(*) FROM Users))
--Version 3
SELECT CAST(ROUND((SELECT COUNT(*)FROM photos)*1.0/(SELECT COUNT(*) FROM users),3) AS DECIMAL(10,2))

/*user ranking by postings higher to lower*/
SELECT
users.username, COUNT(photos.image_url) AS '# of Postings'
FROM ig_clone.dbo.users
JOIN ig_clone.dbo.photos ON users.id = photos.user_id
--JOIN ig_clone.dbo.likes ON photos.id = likes.photo_id
GROUP BY users.id, users.username
ORDER BY COUNT(photos.image_url) DESC

/*Total Posts by users (longer version of SELECT COUNT(*)FROM photos) */

SELECT users.id,username, count(image_url) as #_of_Posts
FROM users JOIN
photos ON users.id = photos.user_id
GROUP BY users.id, username
ORDER BY 3 DESC

/*total numbers of users who have posted at least one time */

--NOT USING WHERE NOT NULL----
SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM ig_clone.dbo.users
JOIN ig_clone.dbo.photos ON users.id = photos.user_id

--- USING WHERE NULL----
SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM ig_clone.dbo.users
LEFT JOIN ig_clone.dbo.photos ON users.id = photos.user_id
WHERE photos.id IS NOT NULL


/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/

SELECT TOP (5)
tags.tag_name, COUNT(tag_name)
FROM ig_clone.dbo.tags
JOIN ig_clone.dbo.photo_tags ON tags.id = photo_tags.tag_id
--JOIN ig_clone.dbo.photos ON photos.id = photo_tags.photo_id
GROUP BY tags.id, tag_name
ORDER BY COUNT(tag_name) DESC

SELECT tag_name, COUNT(tag_name) AS total
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id, tag_name
ORDER BY total DESC;

/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/

SELECT username, users.id, COUNT(likes.user_id) as Total_Likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id, username
HAVING COUNT(likes.user_id) = (SELECT COUNT(*) FROM photos)
ORDER BY 3 DESC

SELECT COUNT(*) as botCount FROM 
( SELECT username, users.id, COUNT(likes.user_id) as Total_Likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id, username
HAVING COUNT(likes.user_id) = (SELECT COUNT(*) FROM photos)
) as Tab1




/*We also have a problem with celebrities
Find users who have never commented on a photo*/

SELECT username, users.id, COUNT(comments.user_id) as Total_Comments_by_user
FROM users
LEFT JOIN Comments ON users.id = comments.user_id
GROUP BY users.id, username
HAVING COUNT(comments.user_id) = 0
ORDER BY 3 DESC

SELECT COUNT(*) as CelebCount FROM
(SELECT username, users.id, COUNT(comments.user_id) as Total_Comments_by_user
FROM users
LEFT JOIN Comments ON users.id = comments.user_id
GROUP BY users.id, username
HAVING COUNT(comments.user_id) = 0
) as tab

/*Mega Challenges
Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/

		SELECT COUNT(*) as Celeb_bot_Count,
			(CONVERT(DECIMAL(5,2),COUNT(*)*1.0 /(SELECT COUNT(*) FROM users)*100)) as '%'
		FROM 
		(SELECT users.id, username
FROM users
LEFT JOIN likes ON users.id = likes.user_id
LEFT JOIN Comments ON Likes.user_id = comments.user_id
GROUP BY users.id, username
HAVING COUNT(likes.user_id) = (SELECT COUNT(*) FROM photos) or COUNT(comments.user_id) = 0
) as Tab1

-------------------------------------------------------------------------------------------------

/*Find users who have ever commented on a photo*/

SELECT username, users.id, COUNT(comments.user_id) as Total_Comments_by_user
FROM users
LEFT JOIN Comments ON users.id = comments.user_id
GROUP BY users.id, username
HAVING COUNT(comments.user_id) >= 1
ORDER BY 3 DESC

SELECT COUNT(*) as non_bot_celeb_users,
(CONVERT(DECIMAL(5,2),COUNT(*)*1.0 /(SELECT COUNT(*) FROM users)*100)) as '%' FROM
(SELECT username, users.id, COUNT(comments.user_id) as Total_Comments_by_user
FROM users
LEFT JOIN Comments ON users.id = comments.user_id
GROUP BY users.id, username
HAVING COUNT(comments.user_id) >= 1
--ORDER BY 3 DESC
) as non_bot_celeb_users

/*Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on photos before*/

SELECT Bots AS #_of_Bots, 
	   (Tab1.Bots/(SELECT COUNT(*) FROM users))*100 AS '%'
	   Tab.Celebrity AS #_of_Celebrities,
	   (Tab.Celebrity/(SELECT COUNT(*) FROM users))*100 AS '$'
FROM
		(
SELECT COUNT(*) as Bots FROM 
(SELECT username, users.id, COUNT(likes.user_id) as Total_Likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id, username
HAVING COUNT(likes.user_id) = (SELECT COUNT(*) FROM photos)
) as Tab1) as tab1
JOIN
			 ( 
				SELECT COUNT(*) as celebrity FROM
(SELECT username, users.id, COUNT(comments.user_id) as Total_Comments_by_user
FROM users
LEFT JOIN Comments ON users.id = comments.user_id
GROUP BY users.id, username
HAVING COUNT(comments.user_id) = 0
) as tab) as tab
ON tab1.user_id = tab.user_id