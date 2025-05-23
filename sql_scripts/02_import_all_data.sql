DO $$
DECLARE
    file_path TEXT;
    file_id INTEGER;
    id_offset INTEGER;
BEGIN
    FOR file_id IN 0..9 LOOP
        -- Определяем путь к файлу
        IF file_id = 0 THEN
            file_path := '/csvdata/MOCK_DATA.csv';
            id_offset := 0;
        ELSE
            file_path := '/csvdata/MOCK_DATA' || file_id || '.csv';
            id_offset := file_id * 1000;
        END IF;

        -- Создаем временную таблицу для каждого файла
        EXECUTE 'CREATE TEMP TABLE tmp_mock_data (
            id INTEGER,
            customer_first_name TEXT,
            customer_last_name TEXT,
            customer_age INTEGER,
            customer_email TEXT,
            customer_country TEXT,
            customer_postal_code TEXT,
            customer_pet_type TEXT,
            customer_pet_name TEXT,
            customer_pet_breed TEXT,
            seller_first_name TEXT,
            seller_last_name TEXT,
            seller_email TEXT,
            seller_country TEXT,
            seller_postal_code TEXT,
            product_name TEXT,
            product_category TEXT,
            product_price NUMERIC,
            product_quantity INTEGER,
            sale_date TEXT,
            sale_customer_id INTEGER,
            sale_seller_id INTEGER,
            sale_product_id INTEGER,
            sale_quantity INTEGER,
            sale_total_price NUMERIC,
            store_name TEXT,
            store_location TEXT,
            store_city TEXT,
            store_state TEXT,
            store_country TEXT,
            store_phone TEXT,
            store_email TEXT,
            pet_category TEXT,
            product_weight NUMERIC,
            product_color TEXT,
            product_size TEXT,
            product_brand TEXT,
            product_material TEXT,
            product_description TEXT,
            product_rating NUMERIC,
            product_reviews INTEGER,
            product_release_date TEXT,
            product_expiry_date TEXT,
            supplier_name TEXT,
            supplier_contact TEXT,
            supplier_email TEXT,
            supplier_phone TEXT,
            supplier_address TEXT,
            supplier_city TEXT,
            supplier_country TEXT
        )';

        -- Загружаем данные
        EXECUTE format('COPY tmp_mock_data FROM %L DELIMITER '','' CSV HEADER', file_path);

        -- Вставляем в основную таблицу с корректировкой ID
        EXECUTE format('
            INSERT INTO raw_pet_store_data
            SELECT
                id + %s,
                sale_date,
                sale_customer_id + %s,
                sale_seller_id + %s,
                sale_product_id + %s,
                sale_quantity,
                sale_total_price,
                customer_first_name,
                customer_last_name,
                customer_age,
                customer_email,
                customer_country,
                customer_postal_code,
                customer_pet_type,
                customer_pet_name,
                customer_pet_breed,
                seller_first_name,
                seller_last_name,
                seller_email,
                seller_country,
                seller_postal_code,
                product_name,
                product_category,
                product_price,
                product_quantity,
                product_weight,
                product_color,
                product_size,
                product_brand,
                product_material,
                product_description,
                product_rating,
                product_reviews,
                product_release_date,
                product_expiry_date,
                store_name,
                store_location,
                store_city,
                store_state,
                store_country,
                store_phone,
                store_email,
                supplier_name,
                supplier_contact,
                supplier_email,
                supplier_phone,
                supplier_address,
                supplier_city,
                supplier_country
            FROM tmp_mock_data
        ', id_offset, id_offset, id_offset, id_offset);

        -- Удаляем временную таблицу
        EXECUTE 'DROP TABLE tmp_mock_data';

        RAISE NOTICE 'Успешно импортирован файл %', file_path;
    END LOOP;
END $$;