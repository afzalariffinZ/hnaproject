-- to alter the customer_acc cuz there are missing columns
ALTER TABLE customer_account
ADD COLUMN username VARCHAR(100) NOT NULL AFTER account_id,
ADD COLUMN first_name VARCHAR(100) NOT NULL AFTER username,
ADD COLUMN surname VARCHAR(100) NOT NULL AFTER first_name,
ADD COLUMN dob DATE NULL AFTER surname,
ADD COLUMN country VARCHAR(100) NOT NULL AFTER dob,
ADD COLUMN marketing_consent ENUM('yes', 'no') DEFAULT 'no' AFTER country;

-- auto member aft log in
ALTER TABLE customer_account
ADD COLUMN role ENUM('admin', 'member') NOT NULL DEFAULT 'member' AFTER password;

-- hardcode (only for testing)
INSERT INTO customer_account
(username, first_name, surname, dob, country, marketing_consent, email, password)
VALUES
-- user accounts
('user1', 'Ali', 'Rahman', '1995-07-12', 'Singapore', 'yes', 'user1@example.com', 'userpass123'),
('user2', 'Nina', 'Tan', '1998-02-28', 'Singapore', 'no', 'user2@example.com', 'userpass123'),
('user3', 'Siti', 'Kamal', '2000-11-15', 'Malaysia', 'yes', 'user3@example.com', 'userpass123'),
('user4', 'John', 'Lim', '1999-05-20', 'Singapore', 'no', 'user4@example.com', 'userpass123');

-- admin acc (must work on backend)
INSERT INTO customer_account 
(username, first_name, surname, dob, country, marketing_consent, email, password, role)
VALUES
('admin', 'Admin', 'User', '1990-01-01', 'Singapore', 'no', 'admin@example.com', 'adminpass123', 'admin');


INSERT INTO event (
  event_name, event_date, event_type, event_desc, member_id
)
VALUES
-- training session
('Evening Training', '2025-05-15', 'Training Session', 'Regular drills and conditioning at the stadium pitch.', 1),
-- club Match
('Friendly Match vs Red Lions', '2025-05-18', 'Club Match', 'Friendly game at our home ground with Red Lions FC.', 2),
-- AGM
('Annual General Meeting 2025', '2025-06-01', 'AGM', 'Annual meeting to discuss club performance and elect new committee.', 3),
-- trial selection
('Open Trials for U21 Team', '2025-05-25', 'Trial Selection', 'Open trials to scout new players for the U21 development squad.', 4);


INSERT INTO membership (
  account_id, membership_type, cashback_accumulated, cashback_rate, join_date, expiry_date, discount_percentage, discount_rate
)
VALUES
(1, 'Bronze', 5.00, 0.50, '2024-01-01', '2025-01-01', 0.00, 0.00),
(2, 'Silver', 10.00, 1.00, '2024-02-15', '2025-02-15', 0.00, 0.00),
(3, 'Gold', 20.00, 2.00, '2024-03-20', '2025-03-20', 0.00, 0.00),
(4, 'Bronze', 2.50, 0.30, '2024-04-10', '2025-04-10', 0.00, 0.00),
(5, 'Silver', 7.50, 0.80, '2024-05-05', '2025-05-05', 0.00, 0.00);

-- diff discounts for diff memeber B-5% S-10% G-15%
UPDATE membership
SET discount_percentage = CASE
    WHEN membership_type = 'Bronze' THEN 5.00
    WHEN membership_type = 'Silver' THEN 10.00
    WHEN membership_type = 'Gold' THEN 15.00
END,
discount_rate = CASE
    WHEN membership_type = 'Bronze' THEN 0.05
    WHEN membership_type = 'Silver' THEN 0.10
    WHEN membership_type = 'Gold' THEN 0.15
END;

INSERT INTO gear (gear_name, gear_desc, price_per_unit)
VALUES
('Jersey', 'Official Club Jersey', 49.99),
('Football Boots', 'High-quality boots', 89.50),
('Scarf', 'Club branded scarf', 19.99),
('Water Bottle', 'Reusable club-branded water bottle', 12.99),
('Training Shorts', 'Breathable training shorts for players', 29.90),
('Goalkeeper Gloves', 'Professional grip gloves for goalkeepers', 59.50),
('Club Cap', 'Stylish cap with embroidered club logo', 24.99);

INSERT INTO payment_mode (total_amount, name, gateway_url)
VALUES
(112.50, 'PayPal', 'https://paypal.com/pay'),
(248.90, 'PayPal', 'https://paypal.com/pay'),
(93.75,  'PayPal', 'https://paypal.com/pay'),
(174.20, 'PayPal', 'https://paypal.com/pay'),
(305.60, 'PayPal', 'https://paypal.com/pay');

INSERT INTO transaction_detail (transaction_type, transaction_date, amount)
VALUES
('membership renewal', '2024-06-24', 282.46),
('match ticket purchase', '2024-11-14', 57.79),
('gear purchase - boots + jersey', '2023-01-07', 278.07),
('club canteen purchase', '2024-07-01', 194.01),
('match ticket purchase', '2023-05-07', 91.24);

INSERT INTO `order` (order_date, payment_ref, account_id, payment_mode_id)
VALUES
('2024-01-15 14:00:00', 'PAYPAL001', 1, 2),
('2024-02-15 16:30:00', 'PAYPAL002', 2, 2),
('2024-03-20 12:45:00', 'PAYPAL003', 3, 2),
('2024-04-05 10:00:00', 'PAYPAL004', 4, 2),
('2024-05-01 18:15:00', 'PAYPAL005', 5, 2);


INSERT INTO `order_item` (order_item_id, quantity, order_id, gear_id, transaction_id)
VALUES
(1, 1, 1, 1, 1),  -- jersey
(2, 1, 2, 2, 2),  -- boots
(3, 2, 3, 4, 3),  -- bottle
(4, 1, 4, 5, 4),  -- training 
(5, 1, 5, 6, 5);  -- goalkeeper stuff

