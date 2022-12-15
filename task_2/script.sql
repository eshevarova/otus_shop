-- таблица root_products
-- индекс по идентификатору бренда и категории товара
create index root_products_brand_id_category_id_index
    on root_products (brand_id, category_id);
-- индекс по названию товара
create index root_products_name_index
    on root_products (name);
-- индекс по полу и сезону
create index root_products_gender_season_index
    on root_products (gender, season);

-- таблица nm_products
-- индекс по цвету и рейтингу товара
create index nm_products_color_rating_index
    on nm_products (color, rating);

-- таблица sizes
-- индекс по названиям размера
create index sizes_name_original_name_index
    on sizes (name, original_name);
-- индекс по номенклатурному артикулу
create index sizes_nm_id_index
    on sizes (nm_id);

-- таблица stocks
-- индекс по цене и наличию товара
create index stocks_price_amount_index
    on stocks (price, amount);
-- индекс по идентификатору размера
create index stocks_size_id_index
    on stocks (size_id);

-- таблица properties
-- индекс по названию свойства и самому свойству
create index properties_main_parent_id_name_index
    on properties (main_parent_id, name);
-- индекс по номенклатурному артикулу
create index properties_nm_id_index
    on properties (nm_id);
