GRANT CONNECT ON DATABASE postgresql_docker TO readwriteaccess;
GRANT USAGE, CREATE ON SCHEMA public TO readwriteaccess;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwriteaccess;
CREATE USER api WITH PASSWORD '&R?M2k5%*1!oOek_+:vh&E';
GRANT readwriteaccess TO api;
