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

whenever sqlerror exit sql.sqlcode
SET APPINFO RubyWillow_Install
SET ARRAYSIZE 250
SET DEFINE '^'
SET SQLPREFIX ~
SET LINESIZE 32767
SET LONG 2000000000
SET LONGCHUNKSIZE 8192
SET PAGESIZE 50000
SET SERVEROUTPUT ON
SET TIMING OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET VERIFY OFF
SET NUMWIDTH 14
SET FEEDBACK OFF
--set echo on

BEGIN
  EXECUTE IMMEDIATE q'[ALTER SESSION SET NLS_DATE_FORMAT='YYYY/MM/DD HH24:MI:SS']';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET NLS_TIMESTAMP_FORMAT='YYYY/MM/DD HH24:MI:SS.FF4']';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT='YYYY/MM/DD HH24:MI:SS.FF4 TZH:TZM']';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET NLS_LENGTH_SEMANTICS=CHAR]';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET PLSCOPE_SETTINGS='IDENTIFIERS:NONE']';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET PLSQL_CODE_TYPE='INTERPRETED']';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=3]';
  EXECUTE IMMEDIATE q'[ALTER SESSION SET PLSQL_WARNINGS='DISABLE:ALL','ENABLE:SEVERE']';
END;
/

grant unlimited tablespace to "RubyWillow"
/

alter session set current_schema = "RubyWillow";

@@bool/boolinst.sql
@@utl/utlinst.sql
@@cfg/cfginst.sql
@@trc/trcinst.sql
@@zip/zipinst.sql
@@mem/meminst.sql
@@metaphone/metaphoneinst.sql
@@pljson/pljsoninst.sql
@@tblaudit/tblauditinst.sql
@@whirlpool/whirlpoolinst.sql
@@dsagg/install_dsagg.sql
@@i18n/install_i18n.sql

/* NOTE: the EXIF utility has some potential security issues,
   so we don't recommend installing it on a system that should
   be more secure. Just uncomment the below line to install it.
*/
-- @@exif/exifinst.sql

prompt Finished Installing RubyWillow Database Utilities...

exit
