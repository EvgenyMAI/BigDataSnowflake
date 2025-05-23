-- Сначала заполняем справочные таблицы
INSERT INTO countries (name)
SELECT DISTINCT customer_country FROM raw_pet_store_data
UNION
SELECT DISTINCT seller_country FROM raw_pet_store_data
UNION
SELECT DISTINCT store_country FROM raw_pet_store_data
UNION
SELECT DISTINCT supplier_country FROM raw_pet_store_data;

INSERT INTO product_categories (name)
SELECT DISTINCT product_category FROM raw_pet_store_data
WHERE product_category IS NOT NULL;

INSERT INTO cities (name, state, country_id)
SELECT DISTINCT 
    r.store_city,
    r.store_state,
    c.country_id
FROM raw_pet_store_data r
JOIN countries c ON r.store_country = c.name
WHERE r.store_city IS NOT NULL;

-- Покупатели
INSERT INTO customers (
    customer_id, first_name, last_name, age, email,
    country_id, postal_code, pet_type, pet_name, pet_breed
)
SELECT DISTINCT ON (r.sale_customer_id)
    r.sale_customer_id,
    r.customer_first_name,
    r.customer_last_name,
    r.customer_age,
    r.customer_email,
    c.country_id,
    r.customer_postal_code,
    r.customer_pet_type,
    r.customer_pet_name,
    r.customer_pet_breed
FROM raw_pet_store_data r
JOIN countries c ON r.customer_country = c.name
ORDER BY r.sale_customer_id;

-- Продавцы
INSERT INTO sellers (
    seller_id, first_name, last_name, email,
    country_id, postal_code
)
SELECT DISTINCT ON (r.sale_seller_id)
    r.sale_seller_id,
    r.seller_first_name,
    r.seller_last_name,
    r.seller_email,
    c.country_id,
    r.seller_postal_code
FROM raw_pet_store_data r
JOIN countries c ON r.seller_country = c.name
ORDER BY r.sale_seller_id;

-- Товары
INSERT INTO products (
    product_id, name, category_id, weight,
    color, size, brand, material, description,
    price, release_date, expiry_date
)
SELECT DISTINCT ON (r.sale_product_id)
    r.sale_product_id,
    r.product_name,
    pc.category_id,
    r.product_weight,
    r.product_color,
    r.product_size,
    r.product_brand,
    r.product_material,
    r.product_description,
    r.product_price,
    TO_DATE(r.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(r.product_expiry_date, 'MM/DD/YYYY')
FROM raw_pet_store_data r
JOIN product_categories pc ON r.product_category = pc.name
ORDER BY r.sale_product_id;

-- Магазины
INSERT INTO stores (name, location, city_id, phone, email)
SELECT DISTINCT ON (r.store_name, r.store_city)
    r.store_name,
    r.store_location,
    ci.city_id,
    r.store_phone,
    r.store_email
FROM raw_pet_store_data r
JOIN cities ci ON r.store_city = ci.name
JOIN countries co ON ci.country_id = co.country_id AND r.store_country = co.name;

-- Поставщики
INSERT INTO suppliers (name, contact_person, email, phone, city_id)
SELECT DISTINCT ON (r.supplier_name, r.supplier_city)
    r.supplier_name,
    r.supplier_contact,
    r.supplier_email,
    r.supplier_phone,
    ci.city_id
FROM raw_pet_store_data r
JOIN cities ci ON r.supplier_city = ci.name
JOIN countries co ON ci.country_id = co.country_id AND r.supplier_country = co.name;

-- Продажи
WITH numbered_sales AS (
    SELECT 
        r.id,
        TO_DATE(r.sale_date, 'MM/DD/YYYY') AS date,
        r.sale_customer_id,
        r.sale_seller_id,
        r.sale_product_id,
        s.store_id,
        sp.supplier_id,
        r.sale_quantity,
        r.sale_total_price,
        r.product_rating,
        r.product_reviews,
        ROW_NUMBER() OVER (PARTITION BY r.id ORDER BY r.id) AS rn
    FROM raw_pet_store_data r
    LEFT JOIN stores s ON r.store_name = s.name
    LEFT JOIN suppliers sp ON r.supplier_name = sp.name
    WHERE r.sale_customer_id IS NOT NULL
      AND r.sale_seller_id IS NOT NULL
      AND r.sale_product_id IS NOT NULL
)
INSERT INTO sales
SELECT
    id AS sale_id,
    date,
    sale_customer_id AS customer_id,
    sale_seller_id AS seller_id,
    sale_product_id AS product_id,
    store_id,
    supplier_id,
    sale_quantity AS quantity,
    sale_total_price AS total_amount,
    product_rating,
    product_reviews AS review_count
FROM numbered_sales
WHERE rn = 1;