create or replace package body zip is
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
procedure int_deflate
  ( iFiles in  zip_table,
    oRslt  out blob,
    oErr   out varchar2 )
is language java
name 'net.rubywillow.Zip.zipCompress(oracle.sql.ARRAY, oracle.sql.BLOB[], java.lang.String[])';
-------------------------------------------------------------------------------
function deflate
  ( iFiles in zip_table )
  return blob
is
  vRslt blob;
  vErr  utl.text;
begin
  int_deflate(iFiles, vRslt, vErr);
  utl.checkError(vErr);
  return vRslt;
end deflate;
-------------------------------------------------------------------------------
procedure int_inflate
  ( izipfile in blob,
    oRslt    out zip_table,
    oErr     out varchar2 )
is language java
name 'net.rubywillow.Zip.zipExtract(oracle.sql.BLOB, oracle.sql.ARRAY[], java.lang.String[])';
-------------------------------------------------------------------------------
function inflate
  ( iZipFile in blob )
  return zip_table
is
  vRslt zip_table;
  vErr  utl.text;
begin
  int_inflate(iZipFile, vRslt, vErr);
  utl.checkError(vErr);
  return vRslt;
end inflate;
-------------------------------------------------------------------------------
end zip;
/
show errors package body zip
