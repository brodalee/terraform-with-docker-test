GRANT CONNECT ON DATABASE postgresql_docker TO readwriteaccess;
GRANT USAGE, CREATE ON SCHEMA public TO readwriteaccess;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwriteaccess;
CREATE USER writer WITH PASSWORD 'O%e(uv9(HFMrgC%UnirdO1';
GRANT readwriteaccess TO writer;
