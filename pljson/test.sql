-- this isn't a formal test - it's mostly just a sanity check

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

var lob clob
prompt building a JSON tree and streaming it...
declare
  zArray  pljsonArray := new pljsonArray();
  zObject pljsonObject;
begin

  <<lp1>>
  for i in 1..1000
  loop
    zObject := new pljsonObject();
    zObject.addMember('stringObj', DBMS_RANDOM.STRING('X', round(DBMS_RANDOM.VALUE(4, 50))));
    zObject.addMember('numberObj', round(DBMS_RANDOM.VALUE(300, 9999), 3));
    zObject.addMember('boolObj', case round(DBMS_RANDOM.VALUE()) when 1 then true else false end );
    zObject.addMember('boolObj2', case round(DBMS_RANDOM.VALUE()) when 1 then true else false end );
    zObject.addMember('nullObj', new pljsonNull());
    zObject.addMember('stringObj2', DBMS_RANDOM.STRING('X', round(DBMS_RANDOM.VALUE(4, 50))));
    zObject.deleteMember('boolObj2');
    zArray.addElement(zObject);
    zArray.addElement(DBMS_RANDOM.STRING('X', round(DBMS_RANDOM.VALUE(4, 50))));
  end loop lp1;

  :lob := zArray.MakeJson(false);

end;
/

prompt Done, now parsing the same tree...

declare
  obj pljsonElement;
begin
  obj := pljsonElement.parseJSON(:lob);
end;
/

prompt DONE!!!!!!!!!!

begin
  dbms_output.put_line(dbms_lob.getLength(:lob));
  dbms_lob.freeTemporary(:lob);
end;
/
