create or replace package table_audit authid current_user is

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
/*
Oracle Table Auditing
=====================

This package is a simple way to setup table-level auditing. In the background,
it will create a shadow table, and a row-level trigger on the table you specify.

At its simplest, just execute:

    TABLE_AUDIT.AUDIT_TABLE('mytable');

To stop auditing, just execute:

    TABLE_AUDIT.STOP('mytable');

The audit starts with finding the fully defined schema.table name. For example
`'mytable'` would actually be `"SCOTT"."MYTABLE"`. Then a shadow table is created
with the same schema/table with a tilde appended: `"SCOTT"."MYTABLE~"`.

After the shadow table is created and configured, the trigger is created on the
source table. The trigger name is the same as the table name with an exclamation
point appended: `"SCOTT"."MYTABLE!"`.

The shadow table is identical to the source table except there are no
constraints at all - necessary for safety and speed. It also contains
an additional five fields:

`"-userid-"` contains the `user_id` from the `all_users` view.

`"-audsid-"` contains the `audsid` from the `v$session` view.
*Note: If you have database auditing enabled, this is the same value as `sessionid` in `dba_audit_trail`*

`"-tmstmp-"` contains the time the record was modified.

`"-webuser-"` if this session is APEX/MOD_PLSQL, the logged-in userid is here. Otherwise null.

`"-action-"` contains:
'I' for insert (new record data recorded)
'U' for update (old record data recorded)
'D' for delete (old record data recorded)

Since the tilde `~`, bang `!` and dash `-` are special characters in the context of
SQL identifiers, any reference to these must be surrounded by double-quotes
and must match the name exactly (case-sensitive), like so:

    select * from "MYTABLE~";

Why all the double-quotes and stuff? A couple of reasons, but the main one is to
mostly eliminate the possibility of a name collision. If you haven't seen this
before, it may look a little odd, but it works with no negative database effects.
Internally, Oracle *always* uses double-quoted identifiers for its own processing.

Usage notes:
------------

You should only audit what is necessary. If you audit a busily modified
table, you will create significant overhead because of the auditing process.
Audit what you need, then `STOP()` when you think you have enough data.

Whenever you alter a table that is being audited, you should re-execute
the `AUDIT_TABLE()` procedure. This synchronizes the shadow table
to match the source table, and re-creates the trigger as well. It is
designed to save the existing shadow table (issuing `ALTER TABLE...` commands)
so it is safe to re-execute this procedure at any time.

Note that if you drop a column and recreate a column with the same name
along with an incompatible data type (without synchronizing in between), you
will run into problems. I'll leave it as an exercise for the reader to
see what happens. Try this package out on a dummy table to see the behavior.
Also note that dropping a column in your table will also drop the same
column in your shadow table.

If you are using SQL*Plus with `SET SERVEROUTPUT ON`, you will see
the all of the SQL this package executes. (DBMS_OUTPUT enabled)

Naturally, you must have the appropriate privileges for this to work;
notably `CREATE [ANY] TABLE` and `CREATE [ANY] TRIGGER`. The shadow table
and trigger will always be created in the same schema as the source
table.

Limitations:
------------

This package works on normal heap tables with pretty much any data-type, including
user-defined types. The known limitations are as follows:

- Shadows for object tables (tables based on an object) will be created as a normal table.
- Does not support nested tables (too hard to manage the extra storage clauses).
- Shadows for partitioned tables will be in a non-partitioned table.

*/
-------------------------------------------------------------------------------
/* PROCEDURE AUDIT_TABLE

Begin or update auditing for a table. If you do not specify a tablespace,
the shadow table will be created using the default user tablespace.
*/
procedure audit_table
  ( table_name   in   varchar2,
    tablespace   in   varchar2 default null );

-------------------------------------------------------------------------------
/* PROCEDURE STOP

Stop auditing. The default behavior is to drop the trigger only - the shadow table stays.
Specify `drop_shadow => true` if you want to drop the shadow table as well.
*/
procedure stop
  ( table_name   in   varchar2,
    drop_shadow  in   boolean default false );

end table_audit;
/
show errors package table_audit
grant execute on table_audit to public
/
create or replace public synonym table_audit for table_audit
/
