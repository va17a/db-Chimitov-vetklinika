-- Лабораторная работа №4. Транзакции, изоляция и права доступа

-- 1. Запомнить исходное количество владельцев.
SELECT count(*) AS owners_count FROM owners;

-- 2. Начать транзакцию и успешно добавить владельца.
BEGIN;
INSERT INTO owners (full_name, phone, email, address)
VALUES ('Тест отката', '+79999999990', 'rollback@example.com', 'Тестовый адрес');

-- 3. Ошибка уникальности в середине транзакции отменяет всю транзакцию.
-- expect: error unique
INSERT INTO owners (full_name, phone, email, address)
VALUES ('Дубликат телефона', '+79000000001', NULL, 'Тестовый адрес');
ROLLBACK;

-- 4. Проверить, что и первый INSERT отменён.
-- expect: same 1
SELECT count(*) AS owners_count FROM owners;

-- 5. app_reader может читать представление.
SET ROLE app_reader;
SELECT pet_id, pet_name, owner_name
FROM v_pet_owner_card
ORDER BY pet_id
LIMIT 3;

-- 6. app_reader не может менять базовую таблицу.
-- expect: error permission
UPDATE pets SET notes = 'Запрещённое изменение' WHERE id = 1;
RESET ROLE;

-- 7. app_writer не может добавить процедуру напрямую в таблицу.
SET ROLE app_writer;
-- expect: error permission
INSERT INTO visit_procedures (visit_id, procedure_id, quantity, actual_price)
VALUES (1, 6, 1, 900.00);
RESET ROLE;

-- 8. app_writer выполняет разрешённую бизнес-операцию, результат откатывается после демо.
SET ROLE app_writer;
BEGIN;
SELECT *
FROM add_visit_procedure(1, 6, 1, NULL, 'Проверка прав app_writer');
ROLLBACK;
RESET ROLE;

-- 9. app_reader не может читать базовую таблицу напрямую.
SET ROLE app_reader;
-- expect: error permission
SELECT * FROM pets;
RESET ROLE;
