/*
    NOTE TO INSTALLER: this install script is for a
    multi-tenant (12c with pluggable db's) database.

    If you are installing in a normal database, use "install.sql"
*/

set feedback off
whenever sqlerror exit sql.sqlcode

-- edit the following line to install into the proper pluggable database
alter session set container=pdb1;

prompt preparing to install...

-- switch to the schema of the logged-in user (just in case)
declare
  vUser varchar2(9999);
begin
  select user into vUser from dual;
  execute immediate 'ALTER SESSION SET CURRENT_SCHEMA="'||vUser||'"';
end;
/

-- create the cfgBackup table, copying the data in RubyWillow.cfg
-- The cfginst script will drop the table after copying the data
-- back into the "cfg" table.
declare
  tablenotexists exception;
  alreadyexists  exception;
  pragma exception_init(tablenotexists, -942);
  pragma exception_init(alreadyexists, -955);
begin
  execute immediate 'create table "cfgBackup" as select * from "RubyWillow"."cfg"';
exception
  -- "RubyWillow"."cfg" doesn't exist. Nothing to do.
  when tablenotexists then null;
  -- "cfgBackup" already exists probably from a prior failed install, so we should leave it alone.
  when alreadyexists then null;
end;
/

-- drop the RubyWillow user
declare
  usernotexists exception;
  pragma exception_init(usernotexists, -1918);
begin
  execute immediate 'drop user "RubyWillow" cascade';
exception
  when usernotexists then null;
end;
/

prompt creating user...
create user "RubyWillow" identified by "CnkcDFe4zh56BtiG" container=current;
@@stdinst.sql
