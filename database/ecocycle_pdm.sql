
CREATE DATABASE IF NOT EXISTS ecocycle_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE ecocycle_db;

CREATE TABLE user_types (
  user_type_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  type_name VARCHAR(50) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (user_type_id),
  UNIQUE KEY uq_user_types_type_name (type_name)
) ENGINE=InnoDB;

CREATE TABLE users (
  user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_type_id BIGINT UNSIGNED NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL,
  phone_number VARCHAR(30) NULL,
  password_hash VARCHAR(255) NOT NULL,
  address TEXT NULL,
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  eco_points INT NOT NULL DEFAULT 0,
  total_waste_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
  trees_planted INT NOT NULL DEFAULT 0,
  co2_offset_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
  account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_phone_number (phone_number),
  CONSTRAINT fk_users_user_type
    FOREIGN KEY (user_type_id) REFERENCES user_types (user_type_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE waste_categories (
  waste_category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(80) NOT NULL,
  description VARCHAR(255) NULL,
  point_rate_per_kg INT NOT NULL DEFAULT 0,
  PRIMARY KEY (waste_category_id),
  UNIQUE KEY uq_waste_categories_name (category_name)
) ENGINE=InnoDB;

CREATE TABLE waste_pickups (
  pickup_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  pickup_code VARCHAR(40) NOT NULL,
  pickup_address TEXT NOT NULL,
  scheduled_at DATETIME NOT NULL,
  pickup_status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
  total_weight_kg DECIMAL(10,2) NOT NULL DEFAULT 0,
  earned_points INT NOT NULL DEFAULT 0,
  notes TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (pickup_id),
  UNIQUE KEY uq_waste_pickups_code (pickup_code),
  KEY idx_waste_pickups_user_id (user_id),
  CONSTRAINT fk_waste_pickups_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE waste_pickup_details (
  pickup_detail_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  pickup_id BIGINT UNSIGNED NOT NULL,
  waste_category_id BIGINT UNSIGNED NOT NULL,
  weight_kg DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (pickup_detail_id),
  KEY idx_pickup_details_pickup_id (pickup_id),
  KEY idx_pickup_details_category_id (waste_category_id),
  CONSTRAINT fk_pickup_details_pickup
    FOREIGN KEY (pickup_id) REFERENCES waste_pickups (pickup_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_pickup_details_category
    FOREIGN KEY (waste_category_id) REFERENCES waste_categories (waste_category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE product_categories (
  product_category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(80) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (product_category_id),
  UNIQUE KEY uq_product_categories_name (category_name)
) ENGINE=InnoDB;

CREATE TABLE sellers (
  seller_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  seller_name VARCHAR(120) NOT NULL,
  seller_description TEXT NULL,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (seller_id),
  KEY idx_sellers_user_id (user_id),
  CONSTRAINT fk_sellers_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  seller_id BIGINT UNSIGNED NOT NULL,
  product_category_id BIGINT UNSIGNED NOT NULL,
  product_name VARCHAR(160) NOT NULL,
  description TEXT NULL,
  price DECIMAL(12,2) NOT NULL,
  unit_name VARCHAR(30) NOT NULL DEFAULT 'unit',
  stock DECIMAL(10,2) NOT NULL DEFAULT 0,
  image_url VARCHAR(500) NULL,
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  sold_count INT NOT NULL DEFAULT 0,
  product_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (product_id),
  KEY idx_products_seller_id (seller_id),
  KEY idx_products_category_id (product_category_id),
  CONSTRAINT fk_products_seller
    FOREIGN KEY (seller_id) REFERENCES sellers (seller_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_products_category
    FOREIGN KEY (product_category_id) REFERENCES product_categories (product_category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE carts (
  cart_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (cart_id),
  KEY idx_carts_user_id (user_id),
  CONSTRAINT fk_carts_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cart_items (
  cart_item_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
  PRIMARY KEY (cart_item_id),
  UNIQUE KEY uq_cart_items_cart_product (cart_id, product_id),
  KEY idx_cart_items_product_id (product_id),
  CONSTRAINT fk_cart_items_cart
    FOREIGN KEY (cart_id) REFERENCES carts (cart_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product
    FOREIGN KEY (product_id) REFERENCES products (product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE orders (
  order_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  order_code VARCHAR(40) NOT NULL,
  shipping_address TEXT NOT NULL,
  shipping_method VARCHAR(50) NOT NULL,
  order_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  shipping_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id),
  UNIQUE KEY uq_orders_code (order_code),
  KEY idx_orders_user_id (user_id),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE order_items (
  order_item_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  product_name VARCHAR(160) NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (order_item_id),
  KEY idx_order_items_order_id (order_id),
  KEY idx_order_items_product_id (product_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE payments (
  payment_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  payment_method VARCHAR(80) NOT NULL,
  payment_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  paid_amount DECIMAL(12,2) NOT NULL,
  paid_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (payment_id),
  KEY idx_payments_order_id (order_id),
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE point_transactions (
  point_transaction_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  transaction_type VARCHAR(20) NOT NULL,
  points INT NOT NULL,
  description VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (point_transaction_id),
  KEY idx_point_transactions_user_id (user_id),
  CONSTRAINT fk_point_transactions_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE education_categories (
  education_category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(80) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (education_category_id),
  UNIQUE KEY uq_education_categories_name (category_name)
) ENGINE=InnoDB;

CREATE TABLE education_articles (
  article_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  education_category_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  summary TEXT NOT NULL,
  content TEXT NOT NULL,
  author_name VARCHAR(120) NOT NULL,
  image_url VARCHAR(500) NULL,
  published_at DATETIME NULL,
  PRIMARY KEY (article_id),
  KEY idx_articles_category_id (education_category_id),
  CONSTRAINT fk_articles_category
    FOREIGN KEY (education_category_id) REFERENCES education_categories (education_category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE experts (
  expert_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  expert_name VARCHAR(120) NOT NULL,
  specialty VARCHAR(120) NOT NULL,
  credential VARCHAR(160) NULL,
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  review_count INT NOT NULL DEFAULT 0,
  is_online BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (expert_id)
) ENGINE=InnoDB;

CREATE TABLE consultations (
  consultation_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  expert_id BIGINT UNSIGNED NOT NULL,
  consultation_code VARCHAR(40) NOT NULL,
  topic VARCHAR(160) NULL,
  consultation_status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at DATETIME NULL,
  PRIMARY KEY (consultation_id),
  UNIQUE KEY uq_consultations_code (consultation_code),
  KEY idx_consultations_user_id (user_id),
  KEY idx_consultations_expert_id (expert_id),
  CONSTRAINT fk_consultations_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_consultations_expert
    FOREIGN KEY (expert_id) REFERENCES experts (expert_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE consultation_messages (
  message_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consultation_id BIGINT UNSIGNED NOT NULL,
  sender_type VARCHAR(20) NOT NULL,
  message_text TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (message_id),
  KEY idx_messages_consultation_id (consultation_id),
  CONSTRAINT fk_messages_consultation
    FOREIGN KEY (consultation_id) REFERENCES consultations (consultation_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE consultation_notes (
  consultation_note_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consultation_id BIGINT UNSIGNED NOT NULL,
  diagnosis TEXT NOT NULL,
  recommendation TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (consultation_note_id),
  UNIQUE KEY uq_consultation_notes_consultation (consultation_id),
  CONSTRAINT fk_notes_consultation
    FOREIGN KEY (consultation_id) REFERENCES consultations (consultation_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
  notification_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  notification_type VARCHAR(40) NOT NULL,
  title VARCHAR(160) NOT NULL,
  body TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (notification_id),
  KEY idx_notifications_user_id (user_id),
  CONSTRAINT fk_notifications_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE faqs (
  faq_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(80) NOT NULL,
  question VARCHAR(255) NOT NULL,
  answer TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (faq_id)
) ENGINE=InnoDB;
