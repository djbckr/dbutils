create or replace package body utl is
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

-------------------------------------------------------------------------------
-- I wrap all java calls to catch exceptions and return the call-stack. Then
-- throw the exception here so we get it in the client.
procedure checkError
  ( iError  in  varchar2 )
is
  vErr text;
begin
  if iError is not null then
    if length(iError) > 4000 then
      vErr := substr(iError, 1, 4000);
    else
      vErr := iError;
    end if;
    raise_application_error(-20001, vErr);
  end if;
end checkError;
-------------------------------------------------------------------------------
procedure int_split_string_strtable
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    returnType         in   varchar2,
    do_trim            in   binary_integer,
    rslt               out  strtable,
    err                out  varchar2 )
is language java
name 'net.rubywillow.Utility.splitString(java.lang.String, java.lang.String, java.lang.String, int, java.sql.Array[], java.lang.String[])';
-------------------------------------------------------------------------------
function split_string_strtable
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    return_trim        in   varchar2 default bool.cTrue )
  return strtable deterministic
is
  rslt    strtable;
  err     text;
begin

  int_split_string_strtable
    ( string_to_split,
      delimiter,
      'STRTABLE',
      case return_trim when bool.cTrue then 1 else 0 end,
      rslt, err );

  checkError(err);

  return rslt;

end split_string_strtable;
-------------------------------------------------------------------------------
procedure int_split_string_strarray
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    returnType         in   varchar2,
    do_trim            in   binary_integer,
    rslt               out  strarray,
    err                out  varchar2 )
is language java
name 'net.rubywillow.Utility.splitString(java.lang.String, java.lang.String, java.lang.String, int, java.sql.Array[], java.lang.String[])';
-------------------------------------------------------------------------------
function split_string_strarray
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    return_trim        in   varchar2 default bool.cTrue )
  return strarray deterministic
is
  rslt    strarray;
  err     text;
begin

  int_split_string_strarray
    ( string_to_split,
      delimiter,
      'STRARRAY',
      case return_trim when bool.cTrue then 1 else 0 end,
      rslt, err );

  checkError(err);

  return rslt;

end split_string_strarray;
-------------------------------------------------------------------------------
function int_rand_guid
  return varchar2
is language java
name 'net.rubywillow.Utility.randomGuid() return java.lang.String';
-------------------------------------------------------------------------------
function random_guid
  return raw
is
begin
  return hextoraw(int_rand_guid());
end random_guid;
-------------------------------------------------------------------------------
function raw_bit_or
  ( inp  in  rawarray )
  return raw
is
  rslt raw(256) := HexToRaw('00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000');
  indx binary_integer;
  len  binary_integer := 0;
  tmp  binary_integer;
begin
  if inp is null then
    return null;
  end if;

  if inp.count() = 0 then
    return null;
  end if;

  indx := inp.first;

  <<mainLoop>>
  loop
    tmp := utl_raw.length(inp(indx));

    if tmp > len then
      len := tmp;
    end if;

    rslt := utl_raw.bit_or(rslt, inp(indx));

    indx := inp.next(indx);

    exit mainLoop when indx is null;

  end loop mainLoop;

  return utl_raw.substr(rslt, 1, len);

end raw_bit_or;
-------------------------------------------------------------------------------
function raw_bit_and
  ( inp  in  rawarray )
  return raw
is
  rslt raw(256) := HexToRaw('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  indx binary_integer;
  len  binary_integer := 0;
  tmp  binary_integer;
begin
  if inp is null then
    return null;
  end if;

  if inp.count() = 0 then
    return null;
  end if;

  indx := inp.first;

  <<mainLoop>>
  loop
    tmp := utl_raw.length(inp(indx));

    if tmp > len then
      len := tmp;
    end if;

    rslt := utl_raw.bit_and(rslt, inp(indx));

    indx := inp.next(indx);

    exit mainLoop when indx is null;

  end loop mainLoop;

  return utl_raw.substr(rslt, 1, len);

end raw_bit_and;
-------------------------------------------------------------------------------
function make_id
  return number
  parallel_enable
is
begin
  -- use UTC so we don't deal with Daylight Saving time changes
  return to_number(to_char(sys_extract_utc(systimestamp), 'YYYYMMDDHH24MISSFF6')||to_char(looper.nextval, 'FM00009'));
end make_id;
-------------------------------------------------------------------------------
function timestamp_from_id
  ( id number )
  return timestamp with time zone
  deterministic parallel_enable
is
  x text;
begin
  if id is null then
    return null;
  end if;
  x := to_char(id);
  x := substr(x, 1, 20);
  if length(x) <> 20 then
    raise_application_error(-20001, 'ID is not a valid format');
  end if;
  -- convert x to timestamp, add UTC time zone, then move to local
  return from_tz(to_timestamp(x, 'YYYYMMDDHH24MISSFF6'), 'UTC') at local;
end timestamp_from_id;
-------------------------------------------------------------------------------
end utl;
/
show errors package body utl
