prompt creating the trc package...

grant create job to "RubyWillow";

create table "trc" (
  tmstmp              timestamp (6),
  audsid              varchar2(30 byte) default sys_context('userenv', 'sessionid'),
  call_stack          varchar2(2000 byte),
  err_stack           varchar2(2000 byte),
  err_backtrace       varchar2(2000 byte),
  additional_info     varchar2(4000 char),
  timing              interval day (4) to second (6),
  timing_comment      varchar2(250 byte),
  log_level           raw(1),
  log_lvl_setting     raw(1),
  session_user        varchar2(30 byte) default sys_context('userenv', 'session_user'),
  proxy_user          varchar2(30 byte) default sys_context('userenv', 'proxy_user'),
  web_user            varchar2(80 char) ,
  module              varchar2(48 byte) default sys_context('userenv', 'module'),
  action              varchar2(32 byte) default sys_context('userenv', 'action'),
  client_info         varchar2(64 byte) default sys_context('userenv', 'client_info'),
  client_identifier   varchar2(64 byte) default sys_context('userenv', 'client_identifier'),
  terminal            varchar2(30 byte) default sys_context('userenv', 'terminal'),
  os_user             varchar2(30 byte) default sys_context('userenv', 'os_user'),
  ip_address          varchar2(16 byte) default sys_context('userenv', 'ip_address'),
  sid                 varchar2(8 byte) default sys_context('userenv', 'sid'),
  instance_name       varchar2(30 byte) default sys_context('userenv', 'instance_name')
) pctfree 0 pctused 99 initrans 4
/

create or replace force view trace as
select  tmstmp utc, audsid, call_stack, err_stack, err_backtrace,
        additional_info, timing, timing_comment,
        case rawtohex (log_level)
           when '01' then '1-Emergency'
           when '02' then '2-Alert'
           when '03' then '3-Critical'
           when '04' then '4-Error'
           when '05' then '5-Warning'
           when '06' then '6-Notice'
           when '07' then '7-Information'
           when '08' then '8-Debug'
           else '?'
        end log_level,
        case rawtohex (log_lvl_setting)
           when '01' then '1-Emergency'
           when '02' then '2-Alert'
           when '03' then '3-Critical'
           when '04' then '4-Error'
           when '05' then '5-Warning'
           when '06' then '6-Notice'
           when '07' then '7-Information'
           when '08' then '8-Debug'
           else '?'
        end log_lvl_setting,
        session_user, proxy_user, web_user, module, action, client_info,
        client_identifier, terminal, os_user, ip_address, sid, instance_name
  from "trc"
  with read only
/

grant select on trace to public
/

create or replace public synonym trace for trace
/

create or replace force view trace_me as
select  utc, call_stack, err_stack, err_backtrace, additional_info,
        timing, timing_comment, log_level, log_lvl_setting, session_user,
        proxy_user, web_user, module, action, client_info, client_identifier,
        terminal, os_user, ip_address, sid, instance_name
  from trace
  where audsid = sys_context('userenv','sessionid')
/

grant select on trace_me to public
/

create or replace public synonym trace_me for trace_me
/

@@trc.package.sql
@@trc.pkgbody.sql
