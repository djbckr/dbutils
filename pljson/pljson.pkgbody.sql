create or replace package body pljson is

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

  -- Identifying strings in pljsonElement.typ
  -- Reason for this: A SQL TYPE must have at least one
  -- attribute/field, even for an abstract type. The only
  -- thing that made sense was to identify what kind of element
  -- the type would be. While you can find out by type-casting,
  -- this works so long as things are encapsulated. Like this package.
  -- DON'T CHANGE THESE! The Java back-end uses them as well.
  cObject   constant varchar2(24) := 'daElVTjd5yGxxlulG2Pv4mmh';
  cArray    constant varchar2(24) := 'ZZyQnZyETd0uEhQCh1Qqc45S';
  cString   constant varchar2(24) := 'LavdJ6qDpIwVQHGSNVD9d3U4';
  cNumber   constant varchar2(24) := 'ys1Y2sh2gm8QK5z5u04M5rIS';
  cBoolean  constant varchar2(24) := 'dhAKeRQTw1k2Rpo9q9H86mMI';
  cNull     constant varchar2(24) := 'N4rsqsFXfWQYuS2tekZMU7Xx';

--------------------------------------------------------------------------------
function parseJson
  ( json  in  CLOB,
    err   out varchar2 )
  return pljsonElement
is language java name 'net.rubywillow.json.ParseJson.parseJson( java.sql.Clob, java.lang.String[] ) return java.sql.Struct';
--------------------------------------------------------------------------------
function parseJson
  ( json in CLOB )
  return pljsonElement
is
  err  varchar2(32000);
  rslt pljsonElement;
begin
  rslt := parseJson( json, err );
  utl.checkError(err);

  return rslt;
end parseJson;
--------------------------------------------------------------------------------
function makeJson
  ( pljson in pljsonElement,
    pretty in binary_integer,
    err out varchar2 )
  return CLOB
is language java name 'net.rubywillow.json.MakeJson.makeJson( java.sql.Struct, int, java.lang.String[] ) return java.sql.Clob';
--------------------------------------------------------------------------------
function makeJson
  ( pljson in pljsonElement,
    pretty in boolean default false )
  return CLOB
is
  err  varchar2(32000);
  rslt CLOB;
begin
  rslt := makeJson(pljson, case when pretty then 1 else 0 end, err);
  utl.checkError(err);
  return rslt;
end makeJson;
--------------------------------------------------------------------------------
function refCursorToJson
  ( input    in sys_refcursor,
    rootName in varchar2,
    compact  in binary_integer,
    pretty   in binary_integer,
    dateFmt  in varchar2,
    err     out varchar2 )
  return CLOB
is language java name 'net.rubywillow.json.RefCursorToJson.refCursorToJson( java.sql.ResultSet, java.lang.String, int, int, java.lang.String, java.lang.String[] ) return java.sql.Clob';
--------------------------------------------------------------------------------
function refCursorToJson
  ( input    in sys_refcursor,
    compact  in boolean  default false,
    rootName in varchar2 default 'json',
    pretty   in boolean  default false,
    dateFmt  in varchar2 default 'yyyy-MM-dd HH:mm:ss' )
  return CLOB
is
  rslt CLOB;
  err  varchar2(32000);
begin
  rslt := refCursorToJson( input,
                           rootName,
                           case when compact then 1 else 0 end,
                           case when pretty  then 1 else 0 end,
                           dateFmt,
                           err );
  utl.checkError(err);

  return rslt;
end refCursorToJson;
--------------------------------------------------------------------------------
function createObject return pljsonObject
is
begin
  return new pljsonObject(cObject, new pljsonObjectEntries());
end createObject;
--------------------------------------------------------------------------------
function createArray return pljsonArray
is
begin
  return new pljsonArray(cArray, new pljsonElements());
end createArray;
--------------------------------------------------------------------------------
function createString
  ( val in varchar2 )
  return pljsonString
is
begin
  return new pljsonString(cString, val);
end createString;
--------------------------------------------------------------------------------
function createNumber
  ( val in number )
  return pljsonNumber
is
begin
  return new pljsonNumber(cNumber, val);
end createNumber;
--------------------------------------------------------------------------------
function createBoolean
  ( val in boolean )
  return pljsonBoolean
is
begin
  return new pljsonBoolean(cBoolean, case when val then '*' else ' ' end);
end createBoolean;
--------------------------------------------------------------------------------
function createNull return pljsonNull
is
begin
  return new pljsonNull(cNull);
end createNull;
--------------------------------------------------------------------------------
function getObject  ( e  in pljsonElement ) return pljsonObject
is
begin
  return case when e."~" = cObject then treat(e as pljsonObject) else null end;
end getObject  ;
--------------------------------------------------------------------------------
function getArray   ( e  in pljsonElement ) return pljsonArray
is
begin
  return case when e."~" = cArray then treat(e as pljsonArray) else null end;
end getArray   ;
--------------------------------------------------------------------------------
function getString  ( e  in pljsonElement ) return varchar2
is
begin
  return case when e."~" = cString  then treat(e as pljsonString).value
              when e."~" = cNumber  then to_char(treat(e as pljsonNumber).value)
              when e."~" = cBoolean then treat(e as pljsonBoolean).val
              else null
         end;
end getString  ;
--------------------------------------------------------------------------------
function getNumber  ( e  in pljsonElement ) return number
is
begin
  return case when e."~" = cNumber then treat(e as pljsonNumber).value else null end;
end getNumber  ;
--------------------------------------------------------------------------------
function getBoolean ( e  in pljsonElement ) return boolean
is
begin
  return case when e."~" = cBoolean then treat(e as pljsonBoolean).value else null end;
end getBoolean ;
--------------------------------------------------------------------------------

function "isObject "( e  in  pljsonElement ) return boolean is begin return e."~" = cObject;  end "isObject ";
function "isArray  "( e  in  pljsonElement ) return boolean is begin return e."~" = cArray;   end "isArray  ";
function "isString "( e  in  pljsonElement ) return boolean is begin return e."~" = cString;  end "isString ";
function "isNumber "( e  in  pljsonElement ) return boolean is begin return e."~" = cNumber;  end "isNumber ";
function "isBoolean"( e  in  pljsonElement ) return boolean is begin return e."~" = cBoolean; end "isBoolean";
function "isNull   "( e  in  pljsonElement ) return boolean is begin return e."~" = cNull;    end "isNull   ";

end pljson;
/
