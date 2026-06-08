-- Migrasi: hapus tabel sisa konsep lama di luar marketplace.
-- Drop urut anak -> induk agar tidak melanggar FK.
-- Catatan: point_transactions TIDAK di-drop (dipakai fitur eco-points).
USE ecocycle_db;

DROP TABLE IF EXISTS waste_pickup_details;
DROP TABLE IF EXISTS waste_pickups;
DROP TABLE IF EXISTS waste_categories;
DROP TABLE IF EXISTS consultation_notes;
DROP TABLE IF EXISTS consultation_messages;
DROP TABLE IF EXISTS consultations;
DROP TABLE IF EXISTS experts;
DROP TABLE IF EXISTS education_articles;
DROP TABLE IF EXISTS education_categories;
DROP TABLE IF EXISTS faqs;
