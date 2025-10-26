
-- ====================================================================
-- AIRBNB SAMPLE DATA (DML) SCRIPT
-- This script inserts realistic sample data into the six defined tables.
-- UUIDs are used for primary and foreign keys as defined in the schema.
-- ====================================================================

-- 1. USER DATA (Hosts, Guests, Admin)

-- Host 1 (Lists multiple properties)
INSERT INTO User (user_id, first_name, last_name, email, password_hash, role) VALUES
('a1a1a1a1-1111-1111-1111-111111111111', 'Elara', 'Vance', 'elara.host@example.com', 'elara_host_hash_123', 'host');

-- Host 2 (Lists one property)
INSERT INTO User (user_id, first_name, last_name, email, password_hash, role) VALUES
('b2b2b2b2-2222-2222-2222-222222222222', 'Rylan', 'Thorne', 'rylan.host@example.com', 'rylan_host_hash_456', 'host');

-- Guest 1 (Made confirmed and cancelled bookings)
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role) VALUES
('c3c3c3c3-3333-3333-3333-333333333333', 'Seraphina', 'Moon', 'seraphina.guest@example.com', 'seraphina_guest_hash_789', '555-0101', 'guest');

-- Guest 2 (Made one pending booking)
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role) VALUES
('d4d4d4d4-4444-4444-4444-444444444444', 'Kai', 'Sterling', 'kai.guest@example.com', 'kai_guest_hash_012', '555-0202', 'guest');

-- Admin User
INSERT INTO User (user_id, first_name, last_name, email, password_hash, role) VALUES
('e5e5e5e5-5555-5555-5555-555555555555', 'Admin', 'Root', 'admin@example.com', 'admin_hash_root', 'admin');

-- 2. PROPERTY DATA

-- Property 1 (Owned by Host 1)
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at) VALUES
('p1p1p1p1-1111-1111-1111-111111111111', 'a1a1a1a1-1111-1111-1111-111111111111',
'The Starlight Loft', 'A modern studio with panoramic city views and a balcony.',
'New York City, NY', 250.00, NOW());

-- Property 2 (Owned by Host 1)
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at) VALUES
('p2p2p2p2-2222-2222-2222-222222222222', 'a1a1a1a1-1111-1111-1111-111111111111',
'Rustic Mountain Cabin', 'Cozy log cabin nestled in the woods, perfect for a quiet retreat.',
'Aspen, CO', 180.50, NOW());

-- Property 3 (Owned by Host 2)
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at) VALUES
('p3p3p3p3-3333-3333-3333-333333333333', 'b2b2b2b2-2222-2222-2222-222222222222',
'Beachfront Villa', 'Luxury villa with private beach access and pool.',
'Miami, FL', 550.00, NOW());

-- 3. BOOKING DATA

-- Booking 1: Confirmed (Guest 1 -> Property 1, 4 nights @ 250 = 1000.00)
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES
('k1k1k1k1-1111-1111-1111-111111111111', 'p1p1p1p1-1111-1111-1111-111111111111', 'c3c3c3c3-3333-3333-3333-333333333333',
'2025-12-01', '2025-12-05', 1000.00, 'confirmed');

-- Booking 2: Pending (Guest 2 -> Property 2, 2 nights @ 180.50 = 361.00)
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES
('k2k2k2k2-2222-2222-2222-222222222222', 'p2p2p2p2-2222-2222-2222-222222222222', 'd4d4d4d4-4444-4444-4444-444444444444',
'2026-01-15', '2026-01-17', 361.00, 'pending');

-- Booking 3: Canceled (Guest 1 -> Property 3, 3 nights @ 550.00 = 1650.00)
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES
('k3k3k3k3-3333-3333-3333-333333333333', 'p3p3p3p3-3333-3333-3333-333333333333', 'c3c3c3c3-3333-3333-3333-333333333333',
'2025-11-10', '2025-11-13', 1650.00, 'canceled');

-- 4. PAYMENT DATA (Only for Confirmed Bookings)

-- Payment 1 (for Booking 1)
INSERT INTO Payment (payment_id, booking_id, amount, payment_method, payment_date) VALUES
('m1m1m1m1-1111-1111-1111-111111111111', 'k1k1k1k1-1111-1111-1111-111111111111', 1000.00, 'credit_card', NOW());

-- 5. REVIEW DATA (For Property 1)

-- Review 1 (Guest 1 on Property 1)
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('r1r1r1r1-1111-1111-1111-111111111111', 'p1p1p1p1-1111-1111-1111-111111111111', 'c3c3c3c3-3333-3333-3333-333333333333', 5,
'The Starlight Loft was incredible! Amazing view and perfectly clean.', NOW());

-- Review 2 (Guest 2 on Property 1 - assumed Guest 2 stayed previously)
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('r2r2r2r2-2222-2222-2222-222222222222', 'p1p1p1p1-1111-1111-1111-111111111111', 'd4d4d4d4-4444-4444-4444-444444444444', 4,
'Great location, but the check-in process was a little confusing.', NOW());

-- 6. MESSAGE DATA

-- Message 1: Guest 1 asking Host 1 about check-in
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
('msg1msg1-1111-1111-1111-111111111111', 'c3c3c3c3-3333-3333-3333-333333333333', 'a1a1a1a1-1111-1111-1111-111111111111',
'Hello Elara, looking forward to our stay! Can you confirm the key pickup process?', NOW());

-- Message 2: Host 1 replying to Guest 1
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
('msg2msg2-2222-2222-2222-222222222222', 'a1a1a1a1-1111-1111-1111-111111111111', 'c3c3c3c3-3333-3333-3333-333333333333',
'Hi Seraphina, the code is 4567#. Instructions are in the booking details. Safe travels!', NOW());
