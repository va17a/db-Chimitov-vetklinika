-- Row Level Security: пользователь владельца №1 видит только его питомца.

-- 1. Под ролью приложения видна ровно одна строка.
SET ROLE app_owner_1;
-- expect: value 1
SELECT count(*) FROM pets;

-- 2. Видимый питомец действительно принадлежит владельцу №1.
-- expect: rows 1
SELECT id, name, owner_id FROM pets;

-- 3. Владелец таблицы обходит RLS и видит всех питомцев.
RESET ROLE;
-- expect: value 10
SELECT count(*) FROM pets;
