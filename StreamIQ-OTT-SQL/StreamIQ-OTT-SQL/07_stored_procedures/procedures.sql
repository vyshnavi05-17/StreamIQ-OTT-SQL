USE streamiq;
DELIMITER $$

CREATE PROCEDURE sp_register_user(
 IN p_first_name VARCHAR(50), IN p_last_name VARCHAR(50),
 IN p_email VARCHAR(100), IN p_date_of_birth DATE, IN p_country VARCHAR(50))
BEGIN
 INSERT INTO users(first_name,last_name,email,date_of_birth,country,registration_date,status)
 VALUES(p_first_name,p_last_name,p_email,p_date_of_birth,p_country,CURDATE(),'ACTIVE');
END$$

CREATE PROCEDURE sp_record_watch_session(
 IN p_profile_id INT, IN p_device_id INT, IN p_content_id INT,
 IN p_episode_id INT, IN p_watch_start DATETIME, IN p_watch_end DATETIME,
 IN p_watch_duration_minutes INT, IN p_completion_percentage DECIMAL(5,2))
BEGIN
 INSERT INTO watch_history(profile_id,device_id,content_id,episode_id,watch_start,watch_end,
                            watch_duration_minutes,completion_percentage)
 VALUES(p_profile_id,p_device_id,p_content_id,p_episode_id,p_watch_start,p_watch_end,
        p_watch_duration_minutes,p_completion_percentage);
END$$

CREATE PROCEDURE sp_cancel_subscription(IN p_subscription_id INT)
BEGIN
 UPDATE subscriptions SET status='CANCELLED',end_date=CURDATE(),auto_renew=FALSE
 WHERE subscription_id=p_subscription_id;
END$$

CREATE PROCEDURE sp_record_payment(
 IN p_subscription_id INT, IN p_payment_date DATE, IN p_amount DECIMAL(10,2),
 IN p_payment_method VARCHAR(30), IN p_payment_status VARCHAR(20),
 IN p_transaction_reference VARCHAR(100))
BEGIN
 INSERT INTO payments(subscription_id,payment_date,amount,payment_method,payment_status,transaction_reference)
 VALUES(p_subscription_id,p_payment_date,p_amount,p_payment_method,p_payment_status,p_transaction_reference);
END$$
DELIMITER ;
