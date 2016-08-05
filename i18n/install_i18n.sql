prompt creating the i18n package...

declare
  roleExists exception;
  pragma exception_init(roleExists, -1921);
begin
  execute immediate 'create role i18n_adm';
exception
  when roleExists then null;
end;
/

@@i18n.sql

@@i18n.package.sql
@@i18n_adm.package.sql

@@i18n.pkgbody.sql
@@i18n_adm.pkgbody.sql
