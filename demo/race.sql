-- Гонка без блокировки: две сессии добавляют вакцинации одному питомцу.

-- [setup] Удалить остатки прошлого запуска и создать два приёма питомца №1.
DELETE FROM visit_procedures
WHERE visit_id IN (SELECT id FROM visits WHERE reason IN ('race-test-A', 'race-test-B'));
DELETE FROM visits WHERE reason IN ('race-test-A', 'race-test-B');
INSERT INTO visits (pet_id, doctor_id, visit_date, reason)
VALUES
    (1, 1, CURRENT_TIMESTAMP, 'race-test-A'),
    (1, 1, CURRENT_TIMESTAMP, 'race-test-B');

-- [A] Окно A не видит прививок в пределах года и добавляет первую.
BEGIN;
INSERT INTO visit_procedures (visit_id, procedure_id, actual_price)
SELECT id, 3, 1500.00 FROM visits WHERE reason = 'race-test-A';

-- [B] Окно B не видит незафиксированную вставку A и тоже проходит проверку.
BEGIN;
INSERT INTO visit_procedures (visit_id, procedure_id, actual_price)
SELECT id, 4, 2200.00 FROM visits WHERE reason = 'race-test-B';

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check] Для питомца осталась не больше одной новой прививки?
-- expect: false
SELECT count(*) <= 1
FROM visit_procedures AS vp
JOIN visits AS v ON v.id = vp.visit_id
WHERE v.reason IN ('race-test-A', 'race-test-B');

-- [cleanup]
DELETE FROM visit_procedures
WHERE visit_id IN (SELECT id FROM visits WHERE reason IN ('race-test-A', 'race-test-B'));
DELETE FROM visits WHERE reason IN ('race-test-A', 'race-test-B');
