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
    do_trim            in   number,
    rslt               out  strtable,
    err                out  varchar2 )
is language java
name 'net.rubywillow.Utility.splitString(java.lang.String, java.lang.String, java.lang.String, java.math.BigDecimal, java.sql.Array[], java.lang.String[])';
-------------------------------------------------------------------------------
function split_string_strtable
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    return_trim        in   varchar2 default '*' )
  return strtable deterministic
is
  rslt    strtable;
  err     text;
begin

  int_split_string_strtable
    ( string_to_split,
      delimiter,
      'STRTABLE',
      case return_trim when '*' then 1 else 0 end,
      rslt, err );

  checkError(err);

  return rslt;

end split_string_strtable;
-------------------------------------------------------------------------------
procedure int_split_string_strarray
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    returnType         in   varchar2,
    do_trim            in   number,
    rslt               out  strarray,
    err                out  varchar2 )
is language java
name 'net.rubywillow.Utility.splitString(java.lang.String, java.lang.String, java.lang.String, java.math.BigDecimal, java.sql.Array[], java.lang.String[])';
-------------------------------------------------------------------------------
function split_string_strarray
  ( string_to_split    in   varchar2,
    delimiter          in   varchar2,
    return_trim        in   varchar2 default '*' )
  return strarray deterministic
is
  rslt    strarray;
  err     text;
begin

  int_split_string_strarray
    ( string_to_split,
      delimiter,
      'STRARRAY',
      case return_trim when '*' then 1 else 0 end,
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
end utl;
/
show errors package body utl
