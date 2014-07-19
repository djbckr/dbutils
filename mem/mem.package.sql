create or replace package mem authid definer is
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

procedure reset;
-------------------------------------------------------------------------------
procedure setMem
  ( memName    in   varchar2,
    memValue   in   anydata );
-------------------------------------------------------------------------------
procedure setString
  ( memName    in   varchar2,
    memValue   in   varchar2 );
-------------------------------------------------------------------------------
procedure setNumber
  ( memName    in   varchar2,
    memValue   in   number );
-------------------------------------------------------------------------------
procedure setDate
  ( memName    in   varchar2,
    memValue   in   date );
-------------------------------------------------------------------------------
procedure setTimestamp
  ( memName    in   varchar2,
    memValue   in   timestamp );
-------------------------------------------------------------------------------
procedure setTimestampTZ
  ( memName    in   varchar2,
    memValue   in   timestamp with time zone );
-------------------------------------------------------------------------------
procedure setTimestampLTZ
  ( memName    in   varchar2,
    memValue   in   timestamp with local time zone );
-------------------------------------------------------------------------------
procedure setIntervalYM
  ( memName    in   varchar2,
    memValue   in   interval year to month );
-------------------------------------------------------------------------------
procedure setIntervalDS
  ( memName    in   varchar2,
    memValue   in   interval day to second );
-------------------------------------------------------------------------------
procedure setRaw
  ( memName    in   varchar2,
    memValue   in   raw );
-------------------------------------------------------------------------------
function getMem
  ( memName    in   varchar2 )
  return anydata parallel_enable;
-------------------------------------------------------------------------------
function getString
  ( memName    in   varchar2 )
  return varchar2 parallel_enable;
-------------------------------------------------------------------------------
function getNumber
  ( memName    in   varchar2 )
  return number parallel_enable;
-------------------------------------------------------------------------------
function getDate
  ( memName    in   varchar2 )
  return date parallel_enable;
-------------------------------------------------------------------------------
function getTimestamp
  ( memName    in   varchar2 )
  return timestamp parallel_enable;
-------------------------------------------------------------------------------
function getTimestampTZ
  ( memName    in   varchar2 )
  return timestamp with time zone parallel_enable;
-------------------------------------------------------------------------------
function getTimestampLTZ
  ( memName    in   varchar2 )
  return timestamp with local time zone parallel_enable;
-------------------------------------------------------------------------------
function getIntervalYM
  ( memName    in   varchar2 )
  return interval year to month parallel_enable;
-------------------------------------------------------------------------------
function getIntervalDS
  ( memName    in   varchar2 )
  return interval day to second parallel_enable;
-------------------------------------------------------------------------------
function getRaw
  ( memName    in   varchar2 )
  return raw parallel_enable;
-------------------------------------------------------------------------------
end mem;
/
show errors package mem
grant execute on mem to public
/
create or replace public synonym mem for mem
/
