-- Покупатели
INSERT INTO customers
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id AS customer_id,
    customer_first_name AS first_name,
    customer_last_name AS last_name,
    customer_age AS age,
    customer_email AS email,
    customer_country AS country,
    customer_postal_code AS postal_code,
    customer_pet_type AS pet_type,
    customer_pet_name AS pet_name,
    customer_pet_breed AS pet_breed
FROM raw_pet_store_data
ORDER BY sale_customer_id;

-- Продавцы
INSERT INTO sellers
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id AS seller_id,
    seller_first_name AS first_name,
    seller_last_name AS last_name,
    seller_email AS email,
    seller_country AS country,
    seller_postal_code AS postal_code
FROM raw_pet_store_data
ORDER BY sale_seller_id;

-- Товары
INSERT INTO products
SELECT DISTINCT ON (sale_product_id)
    sale_product_id AS product_id,
    product_name AS name,
    product_category AS category,
    product_weight AS weight,
    product_color AS color,
    product_size AS size,
    product_brand AS brand,
    product_material AS material,
    product_description AS description,
    product_price AS price,
    TO_DATE(product_release_date, 'MM/DD/YYYY') AS release_date,
    TO_DATE(product_expiry_date, 'MM/DD/YYYY') AS expiry_date
FROM raw_pet_store_data
ORDER BY sale_product_id;

-- Магазины
INSERT INTO stores (name, location, city, state, country, phone, email)
SELECT DISTINCT ON (store_name, store_city)
    store_name, store_location, store_city, 
    store_state, store_country, store_phone, store_email
FROM raw_pet_store_data;

-- Поставщики
INSERT INTO suppliers (name, contact_person, email, phone, city, country)
SELECT DISTINCT ON (supplier_name, supplier_country)
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_city,
    supplier_country
FROM raw_pet_store_data;

-- Продажи
INSERT INTO sales
SELECT
    r.id AS sale_id,
    TO_DATE(r.sale_date, 'MM/DD/YYYY') AS date,
    r.sale_customer_id AS customer_id,
    r.sale_seller_id AS seller_id,
    r.sale_product_id AS product_id,
    s.store_id,
    sp.supplier_id,
    r.sale_quantity AS quantity,
    r.sale_total_price AS total_amount,
    r.product_rating,
    r.product_reviews AS review_count
FROM raw_pet_store_data r
LEFT JOIN stores s ON r.store_name = s.name AND r.store_city = s.city
LEFT JOIN suppliers sp ON r.supplier_name = sp.name AND r.supplier_country = sp.country;