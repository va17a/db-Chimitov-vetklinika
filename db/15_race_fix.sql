-- Сериализация вакцинаций одного питомца через блокировку общей строки pets.
CREATE OR REPLACE FUNCTION add_visit_procedure(
    p_visit_id integer,
    p_procedure_id integer,
    p_quantity integer DEFAULT 1,
    p_actual_price numeric(10, 2) DEFAULT NULL,
    p_notes text DEFAULT NULL
)
RETURNS TABLE (
    visit_id integer,
    procedure_id integer,
    quantity integer,
    actual_price numeric(10, 2)
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_catalog_price numeric(10, 2);
    v_pet_id integer;
BEGIN
    SELECT pr.price
    INTO v_catalog_price
    FROM procedures AS pr
    WHERE pr.id = p_procedure_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Процедура с id % не найдена', p_procedure_id;
    END IF;

    -- Общая блокировка не даёт двум сессиям одновременно проверить
    -- годовой интервал и добавить вакцинацию одному питомцу.
    SELECT p.id
    INTO v_pet_id
    FROM visits AS v
    JOIN pets AS p ON p.id = v.pet_id
    WHERE v.id = p_visit_id
    FOR UPDATE OF p;

    RETURN QUERY
    INSERT INTO visit_procedures AS inserted (
        visit_id,
        procedure_id,
        quantity,
        actual_price,
        notes
    )
    VALUES (
        p_visit_id,
        p_procedure_id,
        p_quantity,
        COALESCE(p_actual_price, v_catalog_price),
        p_notes
    )
    RETURNING
        inserted.visit_id,
        inserted.procedure_id,
        inserted.quantity,
        inserted.actual_price;
END;
$$;
