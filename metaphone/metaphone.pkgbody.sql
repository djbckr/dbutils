create or replace package body metaphone is
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

procedure intMetaphone
  ( str      in  varchar2,
    rslt     out varchar2,
    rslt_alt out varchar2,
    err      out varchar2 )
is language java
name 'net.rubywillow.DoubleMetaphone.doubleMetaphone(java.lang.String, java.lang.String[], java.lang.String[], java.lang.String[])';

procedure eval
  ( evalString  in varchar2,
    result      out varchar2,
    result_alt  out varchar2 )
is
  vErr       utl.text;
  vRslt      utl.text;
  vRsltAlt   utl.text;
begin
  intMetaphone(evalString, vRslt, vRsltAlt, vErr);
  utl.checkError(vErr);
  result := vRslt;
  result_alt := vRsltAlt;
end eval;

function eval
  ( evalString  in varchar2,
    alternate   in varchar2 default bool.cFalse )
  return varchar2
is
  vErr       utl.text;
  vRslt      utl.text;
  vRsltAlt   utl.text;
begin
  intMetaphone(evalString, vRslt, vRsltAlt, vErr);
  utl.checkError(vErr);
  if alternate = bool.cTrue then
    return vRsltAlt;
  else
    return vRslt;
  end if;
end eval;

end metaphone;
/
show errors package body metaphone
