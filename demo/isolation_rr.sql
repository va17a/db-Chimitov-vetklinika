-- REPEATABLE READ: транзакция продолжает видеть снимок на момент первого чтения.

-- [setup]
UPDATE pets SET notes = 'isolation-before' WHERE id = 1;

-- [A] Первое чтение фиксирует снимок данных транзакции.
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- expect: value isolation-before
SELECT notes FROM pets WHERE id = 1;

-- [B] Другая сессия меняет и фиксирует строку.
UPDATE pets SET notes = 'isolation-after' WHERE id = 1;

-- [A] Повторное чтение возвращает прежнее значение из снимка.
-- expect: value isolation-before
SELECT notes FROM pets WHERE id = 1;
COMMIT;

-- [cleanup]
UPDATE pets SET notes = 'Активный' WHERE id = 1;
