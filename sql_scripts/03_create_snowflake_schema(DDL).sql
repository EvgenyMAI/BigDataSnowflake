CREATE TABLE product_categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    state TEXT,
    country_id INTEGER REFERENCES countries(country_id),
    UNIQUE (name, state, country_id)
);

-- Измерение: Покупатели
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER,
    email TEXT,
    country_id INTEGER REFERENCES countries(country_id),
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT
);

-- Измерение: Продавцы
CREATE TABLE sellers (
    seller_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    country_id INTEGER REFERENCES countries(country_id),
    postal_code TEXT
);

-- Измерение: Товары
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category_id INTEGER REFERENCES product_categories(category_id),
    weight NUMERIC(10,2),
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    price NUMERIC(10,2) CHECK (price > 0),
    release_date DATE,
    expiry_date DATE
);

-- Измерение: Магазины
CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT,
    city_id INTEGER REFERENCES cities(city_id),
    phone TEXT,
    email TEXT,
    UNIQUE (name, city_id)
);

-- Измерение: Поставщики
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    city_id INTEGER REFERENCES cities(city_id),
    UNIQUE (name, city_id)
);

-- Фактовая таблица: Продажи
CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    customer_id INTEGER REFERENCES customers(customer_id),
    seller_id INTEGER REFERENCES sellers(seller_id),
    product_id INTEGER REFERENCES products(product_id),
    store_id INTEGER REFERENCES stores(store_id),
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    quantity INTEGER CHECK (quantity > 0),
    total_amount NUMERIC(12,2) CHECK (total_amount > 0),
    product_rating NUMERIC(3,1),
    review_count INTEGER
);

-- Индексы
CREATE INDEX idx_customers_country ON customers(country_id);
CREATE INDEX idx_sales_date ON sales(date);