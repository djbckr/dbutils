create or replace package body exif is
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
procedure int_get_media_info
  ( iMedia     in  BLOB,
    iExecFile  in  varchar2,
    oNames     out strarray,
    oValues    out strarray,
    oErr       out varchar2 )
is language java
name 'net.rubywillow.ExifTool.exiftool(oracle.sql.BLOB, java.lang.String, java.sql.Array[], java.sql.Array[], java.lang.String[])';
-------------------------------------------------------------------------------
function getMediaInfo
  ( media   in  BLOB )
  return rMediaInfo
is
  vNames   strarray;
  vValues  strarray;
  vErr     utl.text;
  vPath    utl.text;
  vRslt    rMediaInfo;
begin
  if media is null then
    return null;
  end if;

  int_get_media_info(media, cfg.getCfgString('path.to.exiftool'), vNames, vValues, vErr);

  utl.checkError(vErr);

  <<strLoop>>
  for i in vNames.first..vNames.last
  loop
    case lower(vNames(i))
      when 'file type'    then vRslt.file_type   := vValues(i);
      when 'mime type'    then vRslt.mime_type   := vValues(i);
      when 'create date'  then select cast(to_timestamp(vValues(i), 'YYYY:MM:DD HH24:MI:SS.ff2') as timestamp(0))
                                 into vRslt.create_date
                                 from dual;
      when 'duration'     then vRslt.duration    := to_dsinterval('0 '||vValues(i));
      when 'image width'  then vRslt.width       := to_number(vValues(i));
      when 'image height' then vRslt.height      := to_number(vValues(i));
      else null;
    end case;
  end loop strLoop;

  return vRslt;

end getMediaInfo;
-------------------------------------------------------------------------------
procedure int_get_media_info_raw
  ( iMedia    in   BLOB,
    iExecFile in   varchar2,
    oRslt     out  varchar2,
    oErr      out  varchar2 )
is language java
name 'net.rubywillow.ExifTool.exiftoolraw(oracle.sql.BLOB, java.lang.String, java.lang.String[], java.lang.String[])';
-------------------------------------------------------------------------------
function getMediaInfoRaw
  ( media   in  BLOB )
  return varchar2
is
  vErr   utl.text;
  vPath  utl.text;
  vRslt  utl.text;
begin
  if media is null then
    return null;
  end if;
  int_get_media_info_raw(media, cfg.getCfgString('path.to.exiftool'), vRslt, vErr);
  utl.checkError(vErr);
  return vRslt;
end;
-------------------------------------------------------------------------------
end exif;
/
show errors package body exif
