-- READ COMMITTED: каждый запрос видит последние зафиксированные данные.

-- [setup]
UPDATE pets SET notes = 'isolation-before' WHERE id = 1;

-- [A] Первая транзакция начинается и читает исходное значение.
BEGIN ISOLATION LEVEL READ COMMITTED;
-- expect: value isolation-before
SELECT notes FROM pets WHERE id = 1;

-- [B] Вторая сессия меняет и фиксирует значение.
UPDATE pets SET notes = 'isolation-after' WHERE id = 1;

-- [A] Повторное чтение возвращает новое зафиксированное значение.
-- expect: value isolation-after
SELECT notes FROM pets WHERE id = 1;
COMMIT;

-- [cleanup]
UPDATE pets SET notes = 'Активный' WHERE id = 1;
