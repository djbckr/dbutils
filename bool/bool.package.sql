create or replace package bool authid definer is
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

/* a convenience package for centralizing boolean management between SQL and PL/SQL.  */

/* The definition of what is "true" and what is "false"
   Our recommendation is to use these values instead
   of Y/N or T/F or even 1/0 because * and [space] are
   much easier to visualise in a grid.  */
cTrue  constant varchar2(1) := '*';
cFalse constant varchar2(1) := ' ';

/* The above constants can't be used in SQL so
   these functions give you access to those values */
function fTrue
  return varchar2
  deterministic parallel_enable;

function fFalse
  return varchar2
  deterministic parallel_enable;

/* convert a string to boolean. If you want something
   specific to represent true you can supply it.
   Otherwise, it will use cTrue as its test  */
function toBool
  ( val      in varchar2,
    trueVal  in varchar2 default cTrue )
  return boolean
  deterministic parallel_enable;

/* convert a boolean to string. If you want something
   specific to represent the true/false values,
   you can supply it here.  */
function toChar
  ( val      in boolean,
    trueVal  in varchar2 default cTrue,
    falseVal in varchar2 default cFalse )
  return varchar2
  deterministic parallel_enable;

end bool;
/
create or replace public synonym bool for bool
/
grant execute on bool to public
/
