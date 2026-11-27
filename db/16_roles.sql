\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

CREATE ROLE app_reader LOGIN PASSWORD :'reader_password';
CREATE ROLE app_writer LOGIN PASSWORD :'writer_password' IN ROLE app_reader;

-- Читающая роль видит только готовые представления, но не базовые таблицы.
GRANT SELECT ON v_pet_owner_card, v_visit_details TO app_reader;

-- Запись разрешена только через бизнес-операцию SECURITY DEFINER.
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;
GRANT EXECUTE ON FUNCTION add_visit_procedure(integer, integer, integer, numeric, text) TO app_writer;
