\c databox

CREATE USER monitoring WITH PASSWORD 'monitoring';

GRANT pg_read_all_stats to monitoring;

GRANT EXECUTE ON FUNCTION pg_ls_waldir TO monitoring;
