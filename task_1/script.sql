/*
1. Схема Products
    Используется для хранения данных об артикулах, размерах, свойствах, категориях и меню.
2. Схема Users
    Используется для хранения данных о пользователях, их избранных товарах и корзине.
3. Схема Dictionary
    Используется для хранения различных справочных таблиц-словарей. Например, список основных свойств товаров, цветов.
*/

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- схема products
create type gender_type as enum ('unisex', 'female', 'male');

alter type gender_type owner to postgres;

create type season_type as enum ('summer', 'winter', 'all_season', 'demi_season');

alter type season_type owner to postgres;

create table brands
(
    id         serial
        constraint brands_pk
            primary key,
    name       text                     default ''::text          not null,
    picture    text,
    created_at timestamp with time zone default CURRENT_TIMESTAMP not null,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP not null
);

comment on table brands is 'Таблица описания брендов';

comment on column brands.id is 'Уникальный идентификатор бренда';

comment on column brands.name is 'Название бренда';

comment on column brands.picture is 'Ссылка на логотип бренда или название в хранилище';

comment on column brands.created_at is 'Дата создания в бд';

comment on column brands.updated_at is 'Дата изменения данных';

alter table brands
    owner to postgres;

create unique index brands_id_uindex
    on brands (id);

create table categories
(
    id        serial
        constraint categories_pk
            primary key,
    name      text default ''::text not null,
    parent_id integer
        constraint categories_categories_id_fk
            references categories
            on update cascade on delete cascade
);

comment on table categories is 'Таблица категорий товаров';

comment on column categories.id is 'Уникальный идентификатор категории товаров';

comment on column categories.name is 'Название категории товаров';

comment on column categories.parent_id is 'Айди родительской категории';

alter table categories
    owner to postgres;

create unique index categories_id_uindex
    on categories (id);

create table suppliers
(
    id         serial
        constraint suppliers_pk
            primary key,
    name       text                     default ''::text          not null,
    tax_number text                     default ''::text          not null,
    address    text                     default ''::text          not null,
    phone      text                     default ''::text          not null,
    created_at timestamp with time zone default CURRENT_TIMESTAMP not null,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP not null
);

comment on table suppliers is 'Таблица поставщиков';

comment on column suppliers.id is 'Уникальный идентификатор поставщика';

comment on column suppliers.name is 'Название организации поставщика';

comment on column suppliers.tax_number is 'ИНН поставщика';

comment on column suppliers.address is 'Юридический адрес поставщика';

comment on column suppliers.phone is 'Телефон поставщика';

comment on column suppliers.created_at is 'Дата создания';

comment on column suppliers.updated_at is 'Дата изменения';

alter table suppliers
    owner to postgres;

create table root_products
(
    id             serial
        constraint products_pk
            primary key,
    name           text                     default ''::text                           not null,
    description    text                     default ''::text                           not null,
    origin_country text                     default ''::text                           not null,
    gender         products.gender_type     default 'unisex'::products.gender_type     not null,
    brand_id       integer                                                             not null
        constraint root_products_brand_id_brands_id_fk
            references brands
            on update cascade on delete cascade,
    category_id    integer                                                             not null
        constraint root_products_categories_id_fk
            references categories
            on update cascade on delete set null,
    season         products.season_type     default 'all_season'::products.season_type not null,
    supplier_id    integer                                                             not null
        constraint root_products_suppliers_id_fk
            references suppliers
            on update cascade on delete set null,
    created_at     timestamp with time zone default CURRENT_TIMESTAMP                  not null,
    updated_at     timestamp with time zone default CURRENT_TIMESTAMP                  not null
);

comment on table root_products is 'Таблица корневых артикулов товаров и их основных параметров';

comment on column root_products.id is 'Корневой артикул товара (объединяет под собой разные номенклатуры, например, разные цвета одного товара)';

comment on column root_products.name is 'Название товара';

comment on column root_products.description is 'Описание товара';

comment on column root_products.origin_country is 'Страна изготовления';

comment on column root_products.gender is 'Пол';

comment on column root_products.brand_id is 'Бренд товара';

comment on column root_products.category_id is 'Категория товара';

comment on column root_products.season is 'Сезон';

comment on column root_products.supplier_id is 'Поставщик товара';

comment on column root_products.created_at is 'Дата создания в бд';

comment on column root_products.updated_at is 'Дата изменения';

alter table root_products
    owner to postgres;

create table nm_products
(
    id         serial
        constraint nm_products_pk
            primary key,
    root_id    integer
        constraint nm_products_root_id_root_products_id_fk
            references root_products
            on update cascade on delete cascade,
    color      text                     default ''::text
        constraint nm_products_colors_en_title_fk
            references dictionary.colors
            on update cascade on delete set default,
    rating     numeric                  default 0                 not null,
    created_at timestamp with time zone default CURRENT_TIMESTAMP not null,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP not null
);

comment on table nm_products is 'Таблица номенклатур товаров и их основных параметров';

comment on column nm_products.id is 'Номенклатурный артикул товара';

comment on column nm_products.root_id is 'Корневой артикул';

comment on column nm_products.color is 'Цвет товара';

comment on column nm_products.rating is 'Рейтинг товара';

comment on column nm_products.created_at is 'Дата создания в бд';

comment on column nm_products.updated_at is 'Дата изменения';

alter table nm_products
    owner to postgres;

create unique index nm_products_id_uindex
    on nm_products (id);

create unique index suppliers_id_uindex
    on suppliers (id);

create table sizes
(
    id            serial
        constraint sizes_pk
            primary key,
    nm_id         integer
        constraint sizes_nm_products_id_fk
            references nm_products
            on update cascade on delete cascade,
    name          text default ''::text not null,
    original_name text default ''::text not null
);

comment on table sizes is 'Таблица размеров по артикулам';

comment on column sizes.id is 'Размерный артикул товара';

comment on column sizes.nm_id is 'Номенклатурный артикул товара';

comment on column sizes.name is 'Российское название размера (40, 134, 70А)';

comment on column sizes.original_name is 'Размер производителя';

alter table sizes
    owner to postgres;

create unique index sizes_id_uindex
    on sizes (id);

create table stocks
(
    size_id    integer                                            not null
        constraint stocks_sizes_id_fk
            references sizes,
    amount     integer                                            not null,
    price      numeric                  default 0                 not null,
    sold       integer                  default 0                 not null,
    created_at timestamp with time zone default CURRENT_TIMESTAMP not null,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP not null
);

comment on table stocks is 'Таблица остатков и цен товаров (все на одном складе)';

comment on column stocks.size_id is 'Размерный артикул';

comment on column stocks.amount is 'Количество единиц товара';

comment on column stocks.price is 'Цена товара';

comment on column stocks.sold is 'Количество проданных единиц товара';

comment on column stocks.created_at is 'Дата создания';

comment on column stocks.updated_at is 'Дата изменения';

alter table stocks
    owner to postgres;

create table nm_pictures
(
    id         serial
        constraint nm_pictures_pk
            primary key,
    nm_id      integer
        constraint nm_pictures_nm_products_id_fk
            references nm_products
            on update cascade on delete cascade,
    picture    text                     default ''::text          not null,
    created_at timestamp with time zone default CURRENT_TIMESTAMP not null,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP not null
);

comment on table nm_pictures is 'Таблица картинок для каждого номенклатурного артикула';

comment on column nm_pictures.id is 'Уникальный идентификатор картинки';

comment on column nm_pictures.nm_id is 'Номенклатурный артикул товара';

comment on column nm_pictures.picture is 'Ссылка на картинку или путь в хранилище';

comment on column nm_pictures.created_at is 'Дата создания в бд';

comment on column nm_pictures.updated_at is 'Дата изменения';

alter table nm_pictures
    owner to postgres;

create unique index nm_pictures_id_uindex
    on nm_pictures (id);

create table properties
(
    id             serial
        constraint properties_pk
            primary key,
    nm_id          integer               not null
        constraint properties_nm_products_id_fk
            references nm_products
            on update cascade on delete cascade,
    main_parent_id integer
        constraint properties_properties_id_fk
            references properties
            on update cascade on delete cascade,
    name           text default ''::text not null,
    attribute      text
);

comment on table properties is 'Таблица описания свойств товаров';

comment on column properties.id is 'Уникальный идентификатор свойства товара';

comment on column properties.nm_id is 'Номенклатурный артикул товара';

comment on column properties.main_parent_id is 'Идентификатор головного свойства';

comment on column properties.name is 'Описание свойства (название)';

comment on column properties.attribute is 'Дополнительный атрибут для свойства (например, количество материала в составе)';

alter table properties
    owner to postgres;

create unique index properties_id_uindex
    on properties (id);

-- схема users
create table users
(
    id         uuid                     default uuid_generate_v4() not null
        constraint users_pk
            primary key,
    first_name text                     default ''::text           not null,
    last_name  text                     default ''::text           not null,
    patronymic text                     default ''::text           not null,
    email      text                     default ''::text           not null,
    created_at timestamp with time zone default CURRENT_TIMESTAMP  not null,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP  not null,
    phone      text                     default ''::text           not null
);

comment on table users is 'Таблица данных пользователей';

comment on column users.id is 'Уникальный идентификатор пользователя';

comment on column users.first_name is 'Имя пользователя';

comment on column users.last_name is 'Фамилия пользователя';

comment on column users.patronymic is 'Отчество пользователя (при наличии)';

comment on column users.email is 'Адрес электронной почты';

comment on column users.created_at is 'Дата создания пользователя';

comment on column users.updated_at is 'Дата изменения данных пользователя';

comment on column users.phone is 'Телефон пользователя';

alter table users
    owner to postgres;

create unique index users_email_uindex
    on users (email);

create table order_statuses
(
    en_title text                  not null
        constraint order_statuses_pk
            primary key,
    ru_title text default ''::text not null
);

comment on table order_statuses is 'Статусы заказов';

comment on column order_statuses.en_title is 'Статус на английском';

comment on column order_statuses.ru_title is 'Статус на русском';

alter table order_statuses
    owner to postgres;

create table orders
(
    id         uuid                     default uuid_generate_v4() not null
        constraint purchases_pk
            primary key,
    created_at timestamp with time zone default CURRENT_TIMESTAMP  not null,
    user_id    uuid                                                not null
        constraint purchases_users_id_fk
            references users
            on update cascade on delete cascade,
    status     text                                                not null
        constraint orders_order_statuses_en_title_fk
            references order_statuses
            on update cascade,
    updated_at timestamp with time zone default CURRENT_TIMESTAMP  not null
);

comment on table orders is 'Заказы пользователей';

comment on column orders.id is 'Уникальный идентификатор покупки';

comment on column orders.user_id is 'Идентификатор пользователя';

comment on column orders.updated_at is 'Дата и время обновления статуса заказа';

alter table orders
    owner to postgres;

create table orders_products
(
    order_id uuid    not null
        constraint orders_products_orders_id_fk
            references orders
            on update cascade on delete cascade,
    nm_id    integer not null
        constraint orders_products_nm_products_id_fk
            references products.nm_products
            on update cascade on delete cascade,
    size_id  integer not null
        constraint orders_products_sizes_id_fk
            references products.sizes
            on update cascade on delete cascade,
    price    numeric not null
);

comment on table orders_products is 'Подробный список покупок';

comment on column orders_products.order_id is 'Идентификатор заказа';

comment on column orders_products.nm_id is 'Номенклатурный артикул товара';

comment on column orders_products.size_id is 'Идентификатор размера';

comment on column orders_products.price is 'Цена товара при заказе';

alter table orders_products
    owner to postgres;

create table favourites
(
    user_id uuid    not null
        constraint favourites_users_id_fk
            references users
            on update cascade on delete cascade,
    nm_id   integer not null
        constraint favourites_nm_products_id_fk
            references products.nm_products
            on update cascade on delete cascade
);

comment on table favourites is 'Избранные товары пользователей';

comment on column favourites.user_id is 'Идентификатор пользователя';

comment on column favourites.nm_id is 'Артикул товара';

alter table favourites
    owner to postgres;

create table baskets
(
    user_id uuid    not null
        constraint baskets_users_id_fk
            references users
            on update cascade on delete cascade,
    nm_id   integer not null
        constraint baskets_nm_products_id_fk
            references products.nm_products
            on update cascade on delete cascade,
    size_id integer not null
        constraint baskets_sizes_id_fk
            references products.sizes
            on update cascade on delete cascade
);

comment on table baskets is 'Корзины пользователей';

comment on column baskets.user_id is 'Идентификатор пользователя';

comment on column baskets.nm_id is 'Номенклатурный артикул товара';

comment on column baskets.size_id is 'Идентификатор размера';

alter table baskets
    owner to postgres;

--схема dictionary
create table colors
(
    en_title text                  not null
        constraint colors_pk
            primary key,
    ru_title text default ''::text not null
);

comment on column colors.en_title is 'Название цвета на английском';

comment on column colors.ru_title is 'Название цвета на русском';

alter table colors
    owner to postgres;

create table materials
(
    id   serial
        constraint materials_pk
            primary key,
    name text default ''::text not null
);

comment on table materials is 'Таблица материалов';

comment on column materials.id is 'Уникальный идентификатор материала';

comment on column materials.name is 'Название материала';

alter table materials
    owner to postgres;

create table main_properties
(
    id   serial
        constraint main_properties_pk
            primary key,
    name text default ''::text not null
);

comment on table main_properties is 'Названия основных свойств товаров (состав, узор, фасон)';

comment on column main_properties.id is 'Уникальный идентификатор главного свойства';

comment on column main_properties.name is 'Название главного свойства';

alter table main_properties
    owner to postgres;
