SELECT u.name, 
t.question,
a.content,
CASE status_id
	WHEN 1 THEN 'CORRECT'
	WHEN 0 THEN 'INCORRECT'
END as correct
FROM completed_tasks ct 
JOIN Users u ON u.id = ct.user_id 
JOIN Tasks t ON t.id = ct.task_id
JOIN Answers a ON ct.answer_id = a.id
WHERE 
user_id in (1812, 1811) 
AND ct.created_at >= '2012-06-22 01:27:12.966158'
ORDER BY u.name;