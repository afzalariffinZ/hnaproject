-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`customer_account`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`customer_account` (
  `account_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(100) NOT NULL,
  `surname` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `dob` DATE NOT NULL,
  `country` VARCHAR(100) NOT NULL,
  `marketing_consent` BOOLEAN NULL,
  `role` ENUM('admin', 'member') NOT NULL DEFAULT 'member',
  PRIMARY KEY (`account_id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)
);



-- -----------------------------------------------------
-- Table `mydb`.`gear`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`gear` (
  `gear_id` INT NOT NULL AUTO_INCREMENT,
  `gear_name` VARCHAR(100) NOT NULL,
  `gear_image` VARCHAR(255) NOT NULL,
  `gear_desc` VARCHAR(255) NOT NULL,
  `gear_quantity` INT NOT NULL,
  `price_per_unit` DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (`gear_id`));


-- -----------------------------------------------------
-- Table `mydb`.`payment_mode`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`payment_mode` (
  `payment_mode_id` INT NOT NULL AUTO_INCREMENT,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `gateway_url` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`payment_mode_id`));


-- -----------------------------------------------------
-- Table `mydb`.`order`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`order` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATETIME NOT NULL,
  `payment_ref` VARCHAR(45) NOT NULL,
  `account_id` INT NOT NULL,
  `payment_mode_id` INT NOT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `fk_orders_customer_account1_idx` (`account_id` ASC) ,
  INDEX `fk_orders_payment_mode1_idx` (`payment_mode_id` ASC) ,
  CONSTRAINT `fk_orders_customer_account1`
    FOREIGN KEY (`account_id`)
    REFERENCES `mydb`.`customer_account` (`account_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_payment_mode1`
    FOREIGN KEY (`payment_mode_id`)
    REFERENCES `mydb`.`payment_mode` (`payment_mode_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `mydb`.`transaction_detail`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`transaction_detail` (
  `transaction_id` INT NOT NULL AUTO_INCREMENT,
  `transaction_type` VARCHAR(45) NOT NULL COMMENT '- membership renewal\n- restaurant bills \n- ticket for club\n- football gear purchase',
  `transaction_date` DATE NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`transaction_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`order_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`order_item` (
  `order_item_id` INT NULL,
  `quantity` INT NOT NULL,
  `order_id` INT NOT NULL,
  `gear_id` INT NOT NULL,
  `transaction_id` INT NOT NULL,
  PRIMARY KEY (`order_item_id`),
  INDEX `fk_order_item_orders1_idx` (`order_id` ASC) ,
  INDEX `fk_order_item_product1_idx` (`gear_id` ASC) ,
  INDEX `fk_order_item_transaction_detail1_idx` (`transaction_id` ASC) ,
  CONSTRAINT `fk_order_item_orders1`
    FOREIGN KEY (`order_id`)
    REFERENCES `mydb`.`order` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_item_product1`
    FOREIGN KEY (`gear_id`)
    REFERENCES `mydb`.`gear` (`gear_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_order_item_transaction_detail1`
    FOREIGN KEY (`transaction_id`)
    REFERENCES `mydb`.`transaction_detail` (`transaction_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `mydb`.`membership`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`membership` (
  `member_id` INT NOT NULL AUTO_INCREMENT,
  `account_id` INT NOT NULL,
  `membership_type` VARCHAR(45) NOT NULL COMMENT 'Use \'gold\', \'silver\', \'bronze\' as values',
  `cashback_accumulated` DECIMAL(3,2) NOT NULL,
  `cashback_rate` DECIMAL(3,2) NOT NULL,
  `join_date` DATE NOT NULL,
  `expiry_date` DATE NOT NULL,
  `discount_percentage` DECIMAL(3,2) NOT NULL,
  `discount_rate` DECIMAL(3,2) NOT NULL,
  PRIMARY KEY (`member_id`),
  INDEX `fk_membership_customer_account_idx` (`account_id` ASC) ,
  CONSTRAINT `fk_membership_customer_account`
    FOREIGN KEY (`account_id`)
    REFERENCES `mydb`.`customer_account` (`account_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `mydb`.`event`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`event`;

CREATE TABLE IF NOT EXISTS `mydb`.`event` (
  `event_id` INT NOT NULL AUTO_INCREMENT,
  `event_name` VARCHAR(100) NOT NULL,
  `event_date` DATE NOT NULL,
  `event_type` VARCHAR(45) NOT NULL COMMENT 'Use ''Club Match'', ''Training Session'', ''AGM'', ''Trial Selection'' as values',
  `event_desc` VARCHAR(225) NOT NULL,
  `member_id` INT NOT NULL,
  PRIMARY KEY (`event_id`),
  INDEX `fk_event_membership_idx` (`member_id`),
  CONSTRAINT `fk_event_membership`
    FOREIGN KEY (`member_id`)
    REFERENCES `mydb`.`membership` (`member_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;




SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
