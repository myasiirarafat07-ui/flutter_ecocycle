USE ecocycle_db;

INSERT INTO user_types (type_name, description) VALUES
  ('Individual', 'Pengguna perorangan'),
  ('Petani', 'Pengguna dari sektor pertanian'),
  ('Bisnis', 'Pengguna bisnis atau komunitas')
ON DUPLICATE KEY UPDATE
  description = VALUES(description);
