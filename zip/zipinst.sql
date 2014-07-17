prompt creating the zip package...

create type zip_type authid definer as object
  ( file_name    varchar2(256),
    file_data    blob );
/

grant execute on zip_type to public
/

create or replace public synonym zip_type for zip_type
/

create type zip_table as table of zip_type
/

grant execute on zip_table to public
/

create or replace public synonym zip_table for zip_table
/

@@Zip.sql.java
@@zip.package.sql
@@zip.pkgbody.sql
