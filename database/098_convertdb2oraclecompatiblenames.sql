ALTER TABLE operation RENAME COLUMN type TO soort;
ALTER TABLE organization RENAME COLUMN number TO streetnumber;
ALTER TABLE transaction RENAME COLUMN type TO soort;
ALTER TABLE _user_ips RENAME COLUMN _user TO users;
ALTER TABLE _user_orgs RENAME COLUMN _user TO users;
ALTER TABLE _user_orgs RENAME COLUMN type TO soort;
ALTER TABLE _user_roles RENAME COLUMN _user TO users;
alter table "service_domain_resource_formats" rename to "service_domain_resource_fmts";
alter table "_user" rename to "users";
alter table "_user_ips" rename to "users_ips";
alter table "_user_orgs" rename to "users_orgs";
alter table "_user_roles" rename to "users_roles";