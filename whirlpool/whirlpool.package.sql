create or replace package whirlpool authid definer is
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
/*  FUNCTION WHIRLPOOLxxx

    Given input, returns a whirlpool encoded RAW value
    http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html

    This is an open-source public-domain ISO standard (ISO/IEC 10118-3:2004)
    http://www.iso.org/iso/catalogue_detail?csnumber=39876

    The hashing code is the reference implementation Java code from the first link.

    The whirlpoolString and whirlpoolClob functions have the possibility of
    mangling strings if the charset is incorrect. It uses java's
    String.getBytes(charset) to get the byte-array to pass to the hash function.

*/

function whirlpoolString
  ( input   in  varchar2,
    charset in  varchar2 default 'UTF-8',
    rounds  in  positiven default 1 )
  return raw deterministic;

function whirlpoolRaw
  ( input  in   raw,
    rounds in   positiven default 1 )
  return raw deterministic;

function whirlpoolClob
  ( input   in  CLOB,
    charset in  varchar2 default 'UTF-8' )
  return raw deterministic;

function whirlpoolBlob
  ( input  in   BLOB )
  return raw deterministic;

end whirlpool;
/
show errors package whirlpool

grant execute on whirlpool to public
/

create or replace public synonym whirlpool for whirlpool
/
