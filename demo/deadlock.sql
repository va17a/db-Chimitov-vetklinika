-- Взаимоблокировка: сессии запрашивают две строки в противоположном порядке.

-- [A] Сессия A блокирует питомца №1.
BEGIN;
SELECT id FROM pets WHERE id = 1 FOR UPDATE;

-- [B] Сессия B блокирует питомца №2.
BEGIN;
SELECT id FROM pets WHERE id = 2 FOR UPDATE;

-- [A] A ждёт строку №2, которую удерживает B.
-- expect: blocked
SELECT id FROM pets WHERE id = 2 FOR UPDATE;

-- [B] B пытается заблокировать №1 и замыкает цикл ожидания.
-- expect: error deadlock
SELECT id FROM pets WHERE id = 1 FOR UPDATE;

-- [B] PostgreSQL отменил транзакцию B и снял её блокировки.
ROLLBACK;

-- [A] Завершить транзакцию A после снятия взаимоблокировки.
ROLLBACK;
