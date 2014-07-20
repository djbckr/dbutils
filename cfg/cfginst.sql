prompt creating the cfg package...

declare
  roleExists exception;
  pragma exception_init(roleExists, -1921);
begin
  execute immediate 'create role cfgadmin';
exception
  when roleExists then null;
end;
/

declare
  roleExists exception;
  pragma exception_init(roleExists, -1921);
begin
  execute immediate 'create role cfgview';
exception
  when roleExists then null;
end;
/

begin
  execute immediate 'grant cfgadmin to '||user;
  execute immediate 'grant cfgview to '||user;
end;
/

create table "cfg" (
  name        varchar2(250 char),
  value       anydata constraint "nlCfgValue" not null,
  constraint "pkCfg" primary key (name)
) organization index overflow;

create or replace force view config as
with y as ( select z.name,
                   z.value.getTypeName() typeName,
                   z.value
              from "cfg" z )
select x.name, x.typeName,
       case x.typeName
         when 'SYS.VARCHAR2' then x.value.accessVarchar2()
         when 'SYS.NUMBER' then to_char(x.value.accessNumber())
         when 'SYS.RAW' then rawtohex(x.value.accessRaw())
         when 'SYS.TIMESTAMP' then to_char(x.value.accessTimestamp(), 'YYYY-MM-DD HH24:MI:SS')
         else '>> un-disaplayable value: use anyvalue.access...() function <<'
       end value,
       x.value anyvalue
  from y x
with read only
/
grant select on config to cfgview;
create or replace public synonym config for config;

@@cfg.package.sql
@@cfg_admin.package.sql
@@cfg.pkgbody.sql
@@cfg_admin.pkgbody.sql

-- if there were configurations backed-up, restore them now
declare
  tablenotexists exception;
  pragma exception_init(tablenotexists, -942);
  vUser  varchar2(9999);
  vName  varchar2(9999);
  vValue anydata;
  cx     sys_refcursor;
begin
  select user into vUser from dual;
  open cx for 'select name, value from "'||vUser||'"."cfgBackup"';
  loop
    fetch cx into vName, vValue;
    exit when cx%notfound;
    cfg_admin.setCfg(vName, vValue);
  end loop;
  close cx;
  execute immediate 'drop table "'||vUser||'"."cfgBackup" purge';
exception
  when tablenotexists then null;
end;
/
