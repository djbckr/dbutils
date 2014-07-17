
prompt creating the exif package...
@@ExifTool.sql.java
@@exif.package.sql
@@exif.pkgbody.sql

/*
    In order for this utility to work, you must install exiftool on the Oracle database server.

    http://www.sno.phy.queensu.ca/~phil/exiftool/

    Then, update the configuration to point to the executable (the perl script)
*/
exec cfg.setCfgString('path.to.exiftool','/home/oracle/exiftool/Image-ExifTool-9.67/exiftool');
