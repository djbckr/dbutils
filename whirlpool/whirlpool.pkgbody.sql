create or replace package body whirlpool is
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

-- Whirlpool hash value when no value (NULL) is passed. It's easier to do this than to fiddle around with NULL values in Java.
nullhash constant raw(64) := hexToRaw('19FA61D75522A4669B44E39C1D2E1726C530232130D407F89AFEE0964997F7A73E83BE698B288FEBCF88E3E03C4F0757EA8964E59B63D93708B138CC42A66EB3');

-------------------------------------------------------------------------------
procedure int_whirlpool_string
  ( input     in  varchar2,
    charset   in  varchar2,
    rslt      out raw,
    err       out varchar2 )
is language java
name 'net.rubywillow.WhirlpoolRW.whirlpoolString(java.lang.String, java.lang.String, oracle.sql.RAW[], java.lang.String[])';
-------------------------------------------------------------------------------
function whirlpoolString
  ( input   in  varchar2,
    charset in  varchar2 default 'UTF-8' )
  return raw deterministic
is
  err    utl.text;
  rslt   raw(64);
begin
  if input is null then
    return nullhash;
  end if;

  int_whirlpool_string(input, charset, rslt, err);

  utl.checkError(err);

  return rslt;
end whirlpoolString;
-------------------------------------------------------------------------------
procedure int_whirlpool_raw
  ( input    in  raw,
    rslt     out raw,
    err      out varchar2 )
is language java
name 'net.rubywillow.WhirlpoolRW.whirlpoolRaw(oracle.sql.RAW, oracle.sql.RAW[], java.lang.String[])';
-------------------------------------------------------------------------------
function whirlpoolRaw
  ( input  in   raw )
  return raw deterministic
is
  err    utl.text;
  rslt   raw(64);
begin
  if input is null or utl_raw.length(input) = 0 then
    return nullhash;
  end if;

  int_whirlpool_raw(input, rslt, err);

  utl.checkError(err);

  return rslt;
end whirlpoolRaw;
-------------------------------------------------------------------------------
procedure int_whirlpool_clob
  ( input    in  CLOB,
    charset  in  varchar2,
    rslt     out raw,
    err      out varchar2 )
is language java
name 'net.rubywillow.WhirlpoolRW.whirlpoolCLOB(oracle.sql.CLOB, java.lang.String, oracle.sql.RAW[], java.lang.String[])';
-------------------------------------------------------------------------------
function whirlpoolClob
  ( input   in  CLOB,
    charset in  varchar2 default 'UTF-8' )
  return raw deterministic
is
  err    utl.text;
  rslt   raw(64);
begin
  if input is null or dbms_lob.getLength(input) = 0 then
    return nullhash;
  end if;

  int_whirlpool_clob(input, charset, rslt, err);

  utl.checkError(err);

  return rslt;
end whirlpoolClob;
-------------------------------------------------------------------------------
procedure int_whirlpool_blob
  ( input    in  BLOB,
    rslt     out raw,
    err      out varchar2 )
is language java
name 'net.rubywillow.WhirlpoolRW.whirlpoolBLOB(oracle.sql.BLOB, oracle.sql.RAW[], java.lang.String[])';
-------------------------------------------------------------------------------
function whirlpoolBlob
  ( input  in   BLOB )
  return raw deterministic
is
  err    utl.text;
  rslt   raw(64);
begin
  if input is null or dbms_lob.getLength(input) = 0 then
    return nullhash;
  end if;

  int_whirlpool_blob(input, rslt, err);

  utl.checkError(err);

  return rslt;
end whirlpoolBlob;
-------------------------------------------------------------------------------
end whirlpool;
/
show errors package body whirlpool
