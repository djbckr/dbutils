create or replace package body "RubyWillow".mem is
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

type stash_table is table of anydata index by utl.text;
stash stash_table;

cChar         constant utl.text := 'SYS.CHAR';
cVarchar      constant utl.text := 'SYS.VARCHAR';
cVarchar2     constant utl.text := 'SYS.VARCHAR2';
cNChar        constant utl.text := 'SYS.NCHAR';
cNVarchar2    constant utl.text := 'SYS.NVARCHAR2';
cNumber       constant utl.text := 'SYS.NUMBER';
cDate         constant utl.text := 'SYS.DATE';
cTimestamp    constant utl.text := 'SYS.TIMESTAMP';
cTimestampTZ  constant utl.text := 'SYS.TIMESTAMP_WITH_TIMEZONE';
cTimestampLTZ constant utl.text := 'SYS.TIMESTAMP_WITH_LTZ';
cIntDS        constant utl.text := 'SYS.INTERVAL_DAY_SECOND';
cIntYM        constant utl.text := 'SYS.INTERVAL_YEAR_MONTH';
cRaw          constant utl.text := 'SYS.RAW';

-------------------------------------------------------------------------------
procedure reset
is
begin
  stash.delete();
end reset;
-------------------------------------------------------------------------------
procedure setMem
  ( memName    in   varchar2,
    memValue   in   anydata )
is
begin
  stash(upper(memName)) := memValue;
end setMem;
-------------------------------------------------------------------------------
procedure setString
  ( memName    in   varchar2,
    memValue   in   varchar2 )
is
begin
  setMem(memName, anyData.convertVarchar2(memValue));
end setString;
-------------------------------------------------------------------------------
procedure setNumber
  ( memName    in   varchar2,
    memValue   in   number )
is
begin
  setMem(memName, anyData.convertNumber(memValue));
end setNumber;
-------------------------------------------------------------------------------
procedure setDate
  ( memName    in   varchar2,
    memValue   in   date )
is
begin
  setMem(memName, anyData.convertDate(memValue));
end setDate;
-------------------------------------------------------------------------------
procedure setTimestamp
  ( memName    in   varchar2,
    memValue   in   timestamp )
is
begin
  setMem(memName, anyData.convertTimestamp(memValue));
end setTimestamp;
-------------------------------------------------------------------------------
procedure setTimestampTZ
  ( memName    in   varchar2,
    memValue   in   timestamp with time zone )
is
begin
  setMem(memName, anyData.convertTimestampTZ(memValue));
end setTimestampTZ;
-------------------------------------------------------------------------------
procedure setTimestampLTZ
  ( memName    in   varchar2,
    memValue   in   timestamp with local time zone )
is
begin
  setMem(memName, anyData.convertTimestampLTZ(memValue));
end setTimestampLTZ;
-------------------------------------------------------------------------------
procedure setIntervalYM
  ( memName    in   varchar2,
    memValue   in   interval year to month )
is
begin
  setMem(memName, anyData.convertIntervalYM(memValue));
end setIntervalYM;
-------------------------------------------------------------------------------
procedure setIntervalDS
  ( memName    in   varchar2,
    memValue   in   interval day to second )
is
begin
  setMem(memName, anyData.convertIntervalDS(memValue));
end setIntervalDS;
-------------------------------------------------------------------------------
procedure setRaw
  ( memName    in   varchar2,
    memValue   in   raw )
is
begin
  setMem(memName, anyData.convertRaw(memValue));
end setRaw;
-------------------------------------------------------------------------------
function getMem
  ( memName    in   varchar2 )
  return anyData
is
begin
  return stash(upper(memName));
exception
  when no_data_found then
    return null;
end getMem;
-------------------------------------------------------------------------------
function getString
  ( memName    in   varchar2 )
  return varchar2
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cVarchar2     then return ad.accessVarchar2();
    when cChar         then return ad.accessChar();
    when cVarchar      then return ad.accessVarchar();
    when cNChar        then return ad.accessNChar();
    when cNVarchar2    then return ad.accessNVarchar2();
    when cNumber       then return to_char(ad.accessNumber());
    when cDate         then return to_char(ad.accessDate());
    when cTimestamp    then return to_char(ad.accessTimestamp());
    when cTimestampTZ  then return to_char(ad.accessTimestampTZ());
    when cTimestampLTZ then return to_char(ad.accessTimestampLTZ());
    when cIntDS        then return to_char(ad.accessIntervalDS());
    when cIntYM        then return to_char(ad.accessIntervalYM());
    when cRaw          then return rawToHex(ad.accessRaw());
    else return null;
  end case;

end getString;
-------------------------------------------------------------------------------
function getNumber
  ( memName    in   varchar2 )
  return number
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cNumber       then return ad.accessNumber();
    when cVarchar2     then return to_number(ad.accessVarchar2());
    when cChar         then return to_number(ad.accessChar());
    when cVarchar      then return to_number(ad.accessVarchar());
    when cNChar        then return to_number(ad.accessNChar());
    when cNVarchar2    then return to_number(ad.accessNVarchar2());
    else return null;
  end case;

end getNumber;
-------------------------------------------------------------------------------
function getDate
  ( memName    in   varchar2 )
  return date
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cDate         then return ad.accessDate();
    when cTimestamp    then return cast(ad.accessTimestamp() as date);
    when cTimestampTZ  then return cast(ad.accessTimestampTZ() as date);
    when cTimestampLTZ then return cast(ad.accessTimestampLTZ() as date);
    when cVarchar2     then return to_date(ad.accessVarchar2());
    when cChar         then return to_date(ad.accessChar());
    when cVarchar      then return to_date(ad.accessVarchar());
    when cNChar        then return to_date(ad.accessNChar());
    when cNVarchar2    then return to_date(ad.accessNVarchar2());
    else return null;
  end case;

end getDate;
-------------------------------------------------------------------------------
function getTimestamp
  ( memName    in   varchar2 )
  return timestamp
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cTimestamp    then return ad.accessTimestamp();
    when cTimestampTZ  then return cast(ad.accessTimestampTZ() as timestamp);
    when cTimestampLTZ then return cast(ad.accessTimestampLTZ() as timestamp);
    when cDate         then return cast(ad.accessDate() as timestamp);
    when cVarchar2     then return to_timestamp(ad.accessVarchar2());
    when cChar         then return to_timestamp(ad.accessChar());
    when cVarchar      then return to_timestamp(ad.accessVarchar());
    when cNChar        then return to_timestamp(ad.accessNChar());
    when cNVarchar2    then return to_timestamp(ad.accessNVarchar2());
    else return null;
  end case;

end getTimestamp;
-------------------------------------------------------------------------------
function getTimestampTZ
  ( memName    in   varchar2 )
  return timestamp with time zone
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cTimestampTZ  then return ad.accessTimestampTZ();
    when cTimestamp    then return cast(ad.accessTimestamp() as timestamp with time zone);
    when cTimestampLTZ then return cast(ad.accessTimestampLTZ() as timestamp with time zone);
    when cDate         then return cast(ad.accessDate() as timestamp with time zone);
    when cVarchar2     then return to_timestamp_tz(ad.accessVarchar2());
    when cChar         then return to_timestamp_tz(ad.accessChar());
    when cVarchar      then return to_timestamp_tz(ad.accessVarchar());
    when cNChar        then return to_timestamp_tz(ad.accessNChar());
    when cNVarchar2    then return to_timestamp_tz(ad.accessNVarchar2());
    else return null;
  end case;

end getTimestampTZ;
-------------------------------------------------------------------------------
function getTimestampLTZ
  ( memName    in   varchar2 )
  return timestamp with local time zone
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cTimestampLTZ then return ad.accessTimestampLTZ();
    when cTimestamp    then return cast(ad.accessTimestamp() as timestamp with local time zone);
    when cTimestampTZ  then return cast(ad.accessTimestampTZ() as timestamp with local time zone);
    when cDate         then return cast(ad.accessDate() as timestamp with local time zone);
    when cVarchar2     then return cast(to_timestamp_tz(ad.accessVarchar2()) as timestamp with local time zone);
    when cChar         then return cast(to_timestamp_tz(ad.accessChar()) as timestamp with local time zone);
    when cVarchar      then return cast(to_timestamp_tz(ad.accessVarchar()) as timestamp with local time zone);
    when cNChar        then return cast(to_timestamp_tz(ad.accessNChar()) as timestamp with local time zone);
    when cNVarchar2    then return cast(to_timestamp_tz(ad.accessNVarchar2()) as timestamp with local time zone);
    else return null;
  end case;

end getTimestampLTZ;
-------------------------------------------------------------------------------
function getIntervalYM
  ( memName    in   varchar2 )
  return interval year to month
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cIntYM        then return ad.accessIntervalYM();
    when cVarchar2     then return to_yminterval(ad.accessVarchar2());
    when cChar         then return to_yminterval(ad.accessChar());
    when cVarchar      then return to_yminterval(ad.accessVarchar());
    when cNChar        then return to_yminterval(ad.accessNChar());
    when cNVarchar2    then return to_yminterval(ad.accessNVarchar2());
    else return null;
  end case;

end getIntervalYM;
-------------------------------------------------------------------------------
function getIntervalDS
  ( memName    in   varchar2 )
  return interval day to second
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cIntDS        then return ad.accessIntervalDS();
    when cVarchar2     then return to_dsinterval(ad.accessVarchar2());
    when cChar         then return to_dsinterval(ad.accessChar());
    when cVarchar      then return to_dsinterval(ad.accessVarchar());
    when cNChar        then return to_dsinterval(ad.accessNChar());
    when cNVarchar2    then return to_dsinterval(ad.accessNVarchar2());
    else return null;
  end case;

end getIntervalDS;
-------------------------------------------------------------------------------
function getRaw
  ( memName    in   varchar2 )
  return raw
is
  ad anyData;
  tn utl.text;
begin
  ad := getMem(memName);

  if ad is null then
    return null;
  end if;

  tn := ad.getTypeName();

  case tn
    when cRaw          then return ad.accessRaw();
    when cVarchar2     then return rawToHex(ad.accessVarchar2());
    when cChar         then return rawToHex(ad.accessChar());
    when cVarchar      then return rawToHex(ad.accessVarchar());
    when cNChar        then return rawToHex(ad.accessNChar());
    when cNVarchar2    then return rawToHex(ad.accessNVarchar2());
    else return null;
  end case;

end getRaw;
-------------------------------------------------------------------------------
end mem;
/
