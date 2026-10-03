USE streamiq;
DELIMITER $$

CREATE FUNCTION fn_calculate_age(p_date_of_birth DATE)
RETURNS INT DETERMINISTIC
BEGIN
 RETURN TIMESTAMPDIFF(YEAR,p_date_of_birth,CURDATE());
END$$

CREATE FUNCTION fn_calculate_subscription_duration(p_start_date DATE,p_end_date DATE)
RETURNS INT DETERMINISTIC
BEGIN
 RETURN DATEDIFF(COALESCE(p_end_date,CURDATE()),p_start_date);
END$$

CREATE FUNCTION fn_get_user_engagement(p_profile_id INT)
RETURNS VARCHAR(30) READS SQL DATA
BEGIN
 DECLARE v_avg_completion DECIMAL(5,2);
 SELECT AVG(completion_percentage) INTO v_avg_completion
 FROM watch_history WHERE profile_id=p_profile_id;
 RETURN CASE
  WHEN v_avg_completion IS NULL THEN 'No Viewing Data'
  WHEN v_avg_completion>=85 THEN 'Highly Engaged'
  WHEN v_avg_completion>=70 THEN 'Engaged'
  WHEN v_avg_completion>=50 THEN 'Moderately Engaged'
  ELSE 'Low Engagement'
 END;
END$$
DELIMITER ;
