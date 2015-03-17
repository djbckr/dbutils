
create or replace type dsinterval_avg authid current_user as object (

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

  total interval day(9) to second(9),
  items integer,

  static function ODCIAggregateInitialize
    ( actx    in out nocopy dsinterval_avg )
    return number,

  member function ODCIAggregateDelete
    ( self in out nocopy dsinterval_avg,
      val  in            dsinterval_unconstrained )
    return number,

  member function ODCIAggregateIterate
    ( self    in out nocopy dsinterval_avg,
      val     in            dsinterval_unconstrained )
    return number,

  member function ODCIAggregateTerminate
    ( self    in out nocopy dsinterval_avg,
      rslt    out           dsinterval_unconstrained,
      flags   in            number )
    return number,

  member function ODCIAggregateMerge
    ( self    in out nocopy dsinterval_avg,
      ctx2    in            dsinterval_avg )
    return number

);
/

create or replace type body dsinterval_avg as
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
static function ODCIAggregateInitialize
  ( actx    in out nocopy dsinterval_avg )
  return number
is
begin

  if actx is null then
    actx := new dsinterval_avg(interval '0' second, 0);
  end if;

  return ODCIConst.Success;

end ODCIAggregateInitialize;
---------------------------------------
member function ODCIAggregateDelete
  ( self in out nocopy dsinterval_avg,
    val  in            dsinterval_unconstrained )
  return number
is
begin

  if val is not null then
    self.total := self.total - val;
    self.items := self.items - 1;
  end if;

  return ODCIConst.Success;

end ODCIAggregateDelete;
---------------------------------------
member function ODCIAggregateIterate
  ( self    in out nocopy dsinterval_avg,
    val     in            dsinterval_unconstrained )
  return number
is
begin

  if val is not null then
    self.total := self.total + val;
    self.items := self.items + 1;
  end if;

  return ODCIConst.Success;

end ODCIAggregateIterate;
---------------------------------------
member function ODCIAggregateTerminate
  ( self    in out nocopy dsinterval_avg,
    rslt    out           dsinterval_unconstrained,
    flags   in            number )
  return number
is
begin

  if self.items = 0 then
    rslt := null;
    return ODCIConst.Success;
  end if;

  rslt := self.total / self.items;

  if bitand(flags, 1) = 0 then
    self.total := interval '0' second;
    self.items := 0;
  end if;

  return ODCIConst.Success;

end ODCIAggregateTerminate;
---------------------------------------
member function ODCIAggregateMerge
  ( self    in out nocopy dsinterval_avg,
    ctx2    in            dsinterval_avg )
  return number
is
begin

  self.total := self.total + ctx2.total;
  self.items := self.items + ctx2.items;

  return ODCIConst.Success;

end ODCIAggregateMerge;
---------------------------------------
end;
/

create or replace function avg_dsinterval
  ( input dsinterval_unconstrained )
  return dsinterval_unconstrained
  authid current_user
  parallel_enable
  aggregate using dsinterval_avg;
/

create or replace public synonym avg_dsinterval for avg_dsinterval;
grant execute on avg_dsinterval to public;

create or replace type dsinterval_sum authid current_user as object (
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

  total interval day(9) to second(9),
  items integer,

  static function ODCIAggregateInitialize
    ( actx    in out nocopy dsinterval_sum )
    return number,

  member function ODCIAggregateDelete
    ( self in out nocopy dsinterval_sum,
      val  in            dsinterval_unconstrained )
    return number,

  member function ODCIAggregateIterate
    ( self    in out nocopy dsinterval_sum,
      val     in            dsinterval_unconstrained )
    return number,

  member function ODCIAggregateTerminate
    ( self    in out nocopy dsinterval_sum,
      rslt    out           dsinterval_unconstrained,
      flags   in            number )
    return number,

  member function ODCIAggregateMerge
    ( self    in out nocopy dsinterval_sum,
      ctx2    in            dsinterval_sum )
    return number

);
/

create or replace type body dsinterval_sum as
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
static function ODCIAggregateInitialize
  ( actx    in out nocopy dsinterval_sum )
  return number
is
begin

  if actx is null then
    actx := new dsinterval_sum(interval '0' second, 0);
  end if;

  return ODCIConst.Success;

end ODCIAggregateInitialize;
---------------------------------------
member function ODCIAggregateDelete
  ( self in out nocopy dsinterval_sum,
    val  in            dsinterval_unconstrained )
  return number
is
begin

  if val is not null then
    self.total := self.total - val;
    self.items := self.items - 1;
  end if;

  return ODCIConst.Success;

end ODCIAggregateDelete;
---------------------------------------
member function ODCIAggregateIterate
  ( self    in out nocopy dsinterval_sum,
    val     in            dsinterval_unconstrained )
  return number
is
begin

  if val is not null then
    self.total := self.total + val;
    self.items := self.items + 1;
  end if;

  return ODCIConst.Success;

end ODCIAggregateIterate;
---------------------------------------
member function ODCIAggregateTerminate
  ( self    in out nocopy dsinterval_sum,
    rslt    out           dsinterval_unconstrained,
    flags   in            number )
  return number
is
begin


  if self.items = 0 then
    rslt := null;
    return ODCIConst.Success;
  end if;

  rslt := self.total;

  if bitand(flags, 1) = 0 then
    self.total := interval '0' second;
    self.items := 0;
  end if;

  return ODCIConst.Success;

end ODCIAggregateTerminate;
---------------------------------------
member function ODCIAggregateMerge
  ( self    in out nocopy dsinterval_sum,
    ctx2    in            dsinterval_sum )
  return number
is
begin
  self.total := self.total + ctx2.total;
  self.items := self.items + ctx2.items;
  return ODCIConst.Success;
end ODCIAggregateMerge;
---------------------------------------
end;
/

create or replace function sum_dsinterval
  ( input dsinterval_unconstrained )
  return dsinterval_unconstrained
  authid current_user
  parallel_enable
  aggregate using dsinterval_sum;
/

create or replace public synonym sum_dsinterval for sum_dsinterval;
grant execute on sum_dsinterval to public;
