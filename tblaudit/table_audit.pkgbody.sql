create or replace package body table_audit is

/*  Copyright (c) 2014, Ruby Willow, Inc.
    All rights reserved.

  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice, this list of
  conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of Ruby Willow, Inc. nor the names of its contributors may be used to
  endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

  subtype vc is varchar2(32760);

  gSchema  vc;
  gTable   vc;
  gTrigger vc;
  gShadow  vc;

  -- do our best to get good data-type representations
  cursor crColumns
    ( tableName  varchar2 )
  is
  select column_name,
         case
           when data_type in ('CHAR', 'VARCHAR2', 'NCHAR', 'NVARCHAR2')
           then data_type||'('||char_length||
               case
                 when data_type in ('CHAR', 'VARCHAR2')
                 then case char_used
                        when 'C' then ' CHAR'
                        when 'B' then ' BYTE'
                        else null
                      end
                 else null
               end ||
               ')'
           when data_type = 'NUMBER'
           then case
                  when data_precision is null and data_scale = 0 then 'INTEGER'
                  else 'NUMBER' ||
                    case when data_precision is null and data_scale is null then null
                    else '(' || data_precision ||','|| data_scale ||')' end
                  end
           when data_type = 'FLOAT' then 'FLOAT('||data_precision||')'
           when data_type = 'RAW' then 'RAW('||data_length||')'
           when data_type_owner is not null then '"'||data_type_owner||'"."'||data_type||'"'
           else data_type
         end data_type
    from all_tab_columns
    where owner = gSchema
      and table_name = tableName
    order by column_id;

  type coltab is table of crColumns%rowtype;

-------------------------------------------------------------------------------
-- wrap execute immediate
procedure action
  ( theAction  in varchar2 )
is
begin
  dbms_output.put_line(theAction);
  execute immediate theAction;
end action;
-------------------------------------------------------------------------------
-- if the source table has dropped columns, this will find them and drop
-- them in the shadow table.
procedure dropCols
  ( sourceColumns  in  coltab,
    shadowColumns  in  coltab )
is
  missing boolean;
begin
  <<primaryLoop>>
  for i in shadowColumns.first..shadowColumns.last
  loop
    if shadowColumns(i).column_name in ('-userid-','-audsid-','-tmstmp-','-action-','-webuser-') then
      continue;
    end if;
    missing := true;
    <<secondaryLoop>>
    for j in sourceColumns.first..sourceColumns.last
    loop
      if sourceColumns(j).column_name = shadowColumns(i).column_name then
        missing := false;
      end if;
    end loop secondaryLoop;
    if missing then
      action('alter table "'||gSchema||'"."'||gShadow||'" drop ("'||shadowColumns(i).column_name||'")');
    end if;
  end loop primaryLoop;
end dropCols;
-------------------------------------------------------------------------------
-- finds any missing/changed columns in the shadow
-- table and adds/modifies them as needed
procedure addCols
  ( sourceColumns  in  coltab,
    shadowColumns  in  coltab )
is
  modstr  vc;
begin

  <<primaryLoop>>
  for i in sourceColumns.first..sourceColumns.last
  loop

    modstr := 'add'; -- assume it's missing first

    <<secondaryLoop>>
    for j in shadowColumns.first..shadowColumns.last
    loop

      if shadowColumns(j).column_name = sourceColumns(i).column_name then
        modstr := null; -- not missing, assume no change needed

        if shadowColumns(j).data_type != sourceColumns(i).data_type then
          modstr := 'modify'; -- datatype has changed, modify column
        end if;

      end if;

    end loop secondaryLoop;

    if modstr is not null then
      action('alter table "'||gSchema||'"."'||gShadow||'" '||modstr||' ( "'||
        sourceColumns(i).column_name||'" '||sourceColumns(i).data_type||' )');
    end if;

  end loop primaryLoop;

end addCols;
-------------------------------------------------------------------------------
-- if the shadow table doesn't exist, create one with basic columns.
-- after it's created, we will add missing fields (it's easier this way)
procedure manageShadow
  ( tablespace  in varchar2 )
is
  n1    number;
  sourceColumns  coltab;
  shadowColumns  coltab;
begin

  select count(*)
    into n1
    from all_tables
    where owner = gSchema
      and table_name = gShadow;

  if n1 = 0 then
    action('
create table "'||gSchema||'"."'||gShadow||'"'||
  case when tablespace is not null then ' tablespace '||tablespace
       else null end||' as
  select cast(null as number) as "-userid-",
         cast(null as number) as "-audsid-",
         cast(null as timestamp with time zone) as "-tmstmp-",
         cast(null as varchar2(128 char)) as "-webuser-",
         cast(null as varchar2(1 byte)) as "-action-"
    from dual
    where null is not null
');
  end if;

  open crColumns(gTable);
  fetch crColumns bulk collect into sourceColumns;
  close crColumns;

  open crColumns(gShadow);
  fetch crColumns bulk collect into shadowColumns;
  close crColumns;

  addCols(sourceColumns, shadowColumns);
  dropCols(sourceColumns, shadowColumns);

end manageShadow;
-------------------------------------------------------------------------------
-- get the owner and proper object name from the supplied table name.
procedure resolveObjects
  ( table_name in varchar2 )
is
  v1       vc;
  v2       vc;
  n1       number;
  n2       number;
begin
  dbms_utility.name_resolve(table_name, 2, gSchema, gTable, v1, v2, n1, n2);

  gShadow := substr(gTable, 1, 29) || '~';
  gTrigger := substr(gTable, 1, 29) || '!';

end resolveObjects;
-------------------------------------------------------------------------------
-- create or replace the trigger
procedure manageTrigger
is
  s vc;
  cols coltab;

  procedure colvals
    ( newold  in  varchar2 )
  is
  begin
    <<loop0>>
    for i in cols.first..cols.last
    loop
      s := s || '    vRow."'||cols(i).column_name||'" := :'||newold||'."'||cols(i).column_name||'";
';
    end loop loop0;
  end colvals;

begin

  open crColumns(gTable);
  fetch crColumns bulk collect into cols;
  close crColumns;

  s := '
create or replace trigger "'||gSchema||'"."'||gTrigger||'"
after insert or update or delete
on "'||gSchema||'"."'||gTable||'" for each row
declare
  vRow "'||gSchema||'"."'||gShadow||q'["%rowtype;
begin

  select sys_context('USERENV','SESSION_USERID'),
         sys_context('USERENV', 'SESSIONID'),
         systimestamp,
         owa_sec.get_user_id()
    into vRow."-userid-", vRow."-audsid-", vRow."-tmstmp-", vRow."-webuser-"
    from dual;

  vRow."-action-" :=
      case
        when inserting then 'I'
        when updating then 'U'
        when deleting then 'D'
        else '?'
      end;

  if inserting then
]';
  colvals('NEW');
  s := s || '  else
';
  colvals('OLD');
  s := s || '  end if;

  insert into "'||gSchema||'"."'||gShadow||'" values vRow;

end "'||gTrigger||'";';

  action(s);
  action('alter trigger "'||gSchema||'"."'||gTrigger||'" enable');

end manageTrigger;
-------------------------------------------------------------------------------
-- starts a new audit, or if it already exists, updates the shadow
-- table if it needs it. It will always re-create the trigger.
procedure audit_table
  ( table_name   in   varchar2,
    tablespace   in   varchar2 default null )
is
begin

  resolveObjects(table_name);

  manageShadow(tablespace);
  manageTrigger();

end audit_table;
-------------------------------------------------------------------------------
-- stop auditing a table.
-- the default behavior is to drop the trigger.
-- use drop_shadow => true to drop the shadow table as well.
procedure stop
  ( table_name   in   varchar2,
    drop_shadow  in   boolean default false )
is
  eTrgNotThere  exception;
  eTblNotThere  exception;
  pragma exception_init(eTrgNotThere, -04080);
  pragma exception_init(eTblNotThere, -00942);
begin
  resolveObjects(table_name);

  begin
    action('drop trigger "'||gSchema||'"."'||gTrigger||'"');
  exception
    when eTrgNotThere then dbms_output.put_line('The trigger wasn''t found - it''s probably fine though.');
  end;

  if drop_shadow then
    begin
      action('drop table "'||gSchema||'"."'||gShadow||'" cascade constraints purge');
    exception
      when eTblNotThere then dbms_output.put_line('The table wasn''t found - it''s probably fine though.');
    end;
  end if;

end stop;
-------------------------------------------------------------------------------
end table_audit;
/
show errors package body table_audit
