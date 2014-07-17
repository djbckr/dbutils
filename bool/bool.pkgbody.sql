create or replace package body bool is
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
function fTrue
  return varchar2
  deterministic
is
begin
  return cTrue;
end fTrue;
-------------------------------------------------------------------------------
function fFalse
  return varchar2
  deterministic
is
begin
  return cFalse;
end fFalse;
-------------------------------------------------------------------------------
function toBool
  ( val      in varchar2,
    trueVal  in varchar2 default cTrue )
  return boolean
  deterministic
is
begin
  return  case
            when val is null
            then null
            when val = trueVal
            then true
            else false
          end;
end toBool;
-------------------------------------------------------------------------------
function toChar
  ( val      in boolean,
    trueVal  in varchar2 default cTrue,
    falseVal in varchar2 default cFalse )
  return varchar2
  deterministic
is
begin
  return  case
            when val is null
            then null
            when val
            then trueVal
            else falseVal
          end;
end toChar;
-------------------------------------------------------------------------------
end bool;
/
show errors package body bool
