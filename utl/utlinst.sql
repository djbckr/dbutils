prompt creating table and array objects...
-- SQL nested table types (requires storage clause if used in a table)
create or replace type strtable as table of varchar2(20000 char);
/
create or replace type numtable as table of number;
/
create or replace type rawtable as table of raw(32);
/
create or replace type tstable as table of timestamp;
/
create or replace type tstztable as table of timestamp with time zone;
/
create or replace type anytable as table of anydata;
/


-- SQL array types (does not require storage clause if used in a table)
create or replace type strarray as varray(100) of varchar2(20000 char);
/
create or replace type numarray as varray(100) of number;
/
create or replace type rawarray as varray(100) of raw(32);
/
create or replace type tsarray as varray(100) of timestamp;
/
create or replace type tstzarray as varray(100) of timestamp with time zone;
/
create or replace type anyarray as varray(100) of anydata;
/


create or replace public synonym strtable for strtable
/
create or replace public synonym numtable for numtable
/
create or replace public synonym rawtable for rawtable
/
create or replace public synonym tstable for tstable
/
create or replace public synonym tstztable for tstztable
/
create or replace public synonym anytable for anytable
/

create or replace public synonym strarray for strarray
/
create or replace public synonym numarray for numarray
/
create or replace public synonym rawarray for rawarray
/
create or replace public synonym tsarray for tsarray
/
create or replace public synonym tstzarray for tstzarray
/
create or replace public synonym anyarray for anyarray
/

grant execute on strtable to public
/
grant execute on numtable to public
/
grant execute on rawtable to public
/
grant execute on tstztable to public
/
grant execute on tstable to public
/
grant execute on anytable to public
/

grant execute on strarray to public
/
grant execute on numarray to public
/
grant execute on rawarray to public
/
grant execute on tstzarray to public
/
grant execute on tsarray to public
/
grant execute on anyarray to public
/

prompt creating the utl package...
@@Utility.sql.java

@@utl.package.sql
@@utl.pkgbody.sql
