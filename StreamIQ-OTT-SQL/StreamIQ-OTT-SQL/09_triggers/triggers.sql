USE streamiq;
DELIMITER $$

CREATE TRIGGER trg_payment_success_activate
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
 IF NEW.payment_status='SUCCESS' THEN
  UPDATE subscriptions SET status='ACTIVE',auto_renew=TRUE
  WHERE subscription_id=NEW.subscription_id;
 END IF;
END$$

CREATE TRIGGER trg_validate_rating
BEFORE INSERT ON ratings
FOR EACH ROW
BEGIN
 IF NEW.rating<1 OR NEW.rating>5 THEN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT='Rating must be between 1 and 5';
 END IF;
END$$
DELIMITER ;
