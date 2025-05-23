-- Измерение: Покупатели
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER,
    email TEXT,
    country TEXT,
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT
);
CREATE INDEX idx_customers_country ON customers(country);

-- Измерение: Продавцы
CREATE TABLE sellers (
    seller_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    country TEXT,
    postal_code TEXT
);

-- Измерение: Товары
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT,
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
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT,
    UNIQUE (name, city)
);

-- Измерение: Поставщики
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    city TEXT,
    country TEXT,
    UNIQUE (name, country)
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
CREATE INDEX idx_sales_date ON sales(date);