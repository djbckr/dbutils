
@@gson224.sql

prompt creating the pljson utility...

@@PLJSON.sql.java
@@MakeJson.sql.java
@@ParseJson.sql.java
@@RefCursorToJson.sql.java

alter session set PLSQL_WARNINGS = 'DISABLE:5004';
@@pljson.types.sql
@@pljson.package.sql
@@pljson.pkgbody.sql
@@pljson.typbodies.sql

grant execute on pljsonElement to public;
grant execute on pljsonNull to public;
grant execute on pljsonObjectEntry to public;
grant execute on pljsonObjectEntries to public;
grant execute on pljsonObject to public;
grant execute on pljsonElements to public;
grant execute on pljsonArray to public;
grant execute on pljsonPrimitive to public;
grant execute on pljsonString to public;
grant execute on pljsonNumber to public;
grant execute on pljsonBoolean to public;
grant execute on pljson to public;


create or replace public synonym pljsonElement       for pljsonElement;
create or replace public synonym pljsonNull          for pljsonNull;
create or replace public synonym pljsonObjectEntry   for pljsonObjectEntry;
create or replace public synonym pljsonObjectEntries for pljsonObjectEntries;
create or replace public synonym pljsonObject        for pljsonObject;
create or replace public synonym pljsonElements      for pljsonElements;
create or replace public synonym pljsonArray         for pljsonArray;
create or replace public synonym pljsonPrimitive     for pljsonPrimitive;
create or replace public synonym pljsonString        for pljsonString;
create or replace public synonym pljsonNumber        for pljsonNumber;
create or replace public synonym pljsonBoolean       for pljsonBoolean;
create or replace public synonym pljson              for pljson;
