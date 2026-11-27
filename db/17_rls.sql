-- Пример Row Level Security: роль владельца №1 видит только своих питомцев.
CREATE ROLE app_owner_1 NOLOGIN;

GRANT SELECT ON pets TO app_owner_1;

ALTER TABLE pets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pets_owner_1_select ON pets;
CREATE POLICY pets_owner_1_select
    ON pets
    FOR SELECT
    TO app_owner_1
    USING (owner_id = 1);
