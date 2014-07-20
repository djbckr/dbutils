create or replace package cfg_admin authid definer is
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

  -- This package can only be executed by users with the CFGADMIN role

/*
###PACKAGE CFG

Set arbritrary name/value pairs.

The name is case-insensitive.
That is: "MYCONFIG" == "MyConfig" == "myconfig"

The name is also trimmed of white-space at the beginning and end.

It's generally considered good form to use dot-notation for a name,
like "domain.category.variable" to help avoid name contention. Of
course, you are free to do as you like.

You can see the contents of CFG using the CONFIG view.

Note that the functions

    setCfgString
    setCfgNumber
    setCfgTimestamp
    setCfgRaw

Are convenience functions that translates the data-type for you. Note that if
you SET a number, and GET a string, you will get NULL. The underlying engine
uses the ANYDATA datatype and this is the behavior. Make sure you set/get the
correct datatype you are expecting to use.

*/

-- the main procedures
procedure setCfg
  ( iName   in   varchar2,
    iValue  in   anydata );

procedure dropCfg
  ( iName in  varchar );

-------------------------------------------------------------------------------
-- the convenience procedures
procedure setCfgString
  ( iName      in   varchar2,
    iString    in   varchar2 );

procedure setCfgNumber
  ( iName      in   varchar2,
    iNumber    in   number );

procedure setCfgTimestamp
  ( iName      in   varchar2,
    iTimestamp in   timestamp );

procedure setCfgRaw
  ( iName      in   varchar2,
    iRaw       in   raw );

end cfg_admin;
/
show errors package cfg_admin
grant execute on cfg_admin to cfgadmin
/
create or replace public synonym cfg_admin for cfg_admin
/
