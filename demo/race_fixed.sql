-- Исправленная гонка: бизнес-операция блокирует строку питомца до COMMIT.

-- [setup] Удалить остатки прошлого запуска и создать два приёма питомца №1.
DELETE FROM visit_procedures
WHERE visit_id IN (SELECT id FROM visits WHERE reason IN ('race-fixed-A', 'race-fixed-B'));
DELETE FROM visits WHERE reason IN ('race-fixed-A', 'race-fixed-B');
INSERT INTO visits (pet_id, doctor_id, visit_date, reason)
VALUES
    (1, 1, CURRENT_TIMESTAMP, 'race-fixed-A'),
    (1, 1, CURRENT_TIMESTAMP, 'race-fixed-B');

-- [A] Окно A блокирует питомца и добавляет первую вакцинацию.
BEGIN;
SELECT * FROM add_visit_procedure(
    (SELECT id FROM visits WHERE reason = 'race-fixed-A'),
    3
);

-- [B] Окно B ждёт блокировку A, затем видит прививку и получает ошибку правила.
-- expect: blocked
-- expect: error "минимум один год"
BEGIN;
SELECT * FROM add_visit_procedure(
    (SELECT id FROM visits WHERE reason = 'race-fixed-B'),
    4
);

-- [A] После COMMIT окно B продолжает выполнение.
COMMIT;

-- [B] Отменить транзакцию, прерванную ошибкой триггера.
ROLLBACK;

-- [check] Сохранилась ровно одна вакцинация: правило соблюдено.
-- expect: true
SELECT count(*) = 1
FROM visit_procedures AS vp
JOIN visits AS v ON v.id = vp.visit_id
WHERE v.reason IN ('race-fixed-A', 'race-fixed-B');

-- [cleanup]
DELETE FROM visit_procedures
WHERE visit_id IN (SELECT id FROM visits WHERE reason IN ('race-fixed-A', 'race-fixed-B'));
DELETE FROM visits WHERE reason IN ('race-fixed-A', 'race-fixed-B');
