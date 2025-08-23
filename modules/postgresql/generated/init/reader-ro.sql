GRANT CONNECT ON DATABASE postgresql_docker TO readaccess;
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
CREATE USER reader WITH PASSWORD 'GH5e#-PhK_!{>}eUZ#QSf$';
GRANT readaccess TO reader;
