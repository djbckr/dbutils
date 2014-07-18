--------------------------------------------------------------------------------

create or replace type body pljsonElement is

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

member function isObject
  return boolean
is
begin
  return self is of (pljsonObject);
end isObject    ;

member function isArray
  return boolean
is
begin
  return self is of (pljsonArray);
end isArray     ;

member function isNull
  return boolean
is
begin
  return self is of (pljsonNull);
end isNull      ;

member function isString
  return boolean
is
begin
  return self is of (pljsonString);
end isString    ;

member function isNumber
  return boolean
is
begin
  return self is of (pljsonNumber);
end isNumber    ;

member function isBoolean
  return boolean
is
begin
  return self is of (pljsonBoolean);
end isBoolean   ;

member function isPrimitive
  return boolean
is
begin
  return self is of (pljsonPrimitive);
end isPrimitive ;

member function getString
  return varchar2
is
begin
  return case when self is of (pljsonString)  then treat(self as pljsonString).value
              when self is of (pljsonNumber)  then to_char(treat(self as pljsonNumber).value)
              when self is of (pljsonBoolean) then treat(self as pljsonBoolean).bval
              else null
         end;
end getString;

member function getNumber
  return number
is
begin
  return case when self is of (pljsonNumber) then treat(self as pljsonNumber).value else null end;
end getNumber;

member function getBoolean
  return boolean
is
begin
  return case when self is of (pljsonBoolean) then treat(self as pljsonBoolean).value() else null end;
end getBoolean;

member function makeJSON
  ( self in out nocopy pljsonElement,
    pretty in boolean default false )
  return CLOB
is
  err  varchar2(32000);
  rslt CLOB;
begin
  rslt := pljson.makeJson(self, case when pretty then 1 else 0 end, err);
  utl.checkError(err);
  return rslt;
end makeJSON;

static function parseJSON
  ( json  in  CLOB )
  return pljsonElement
is
  err  varchar2(32000);
  rslt pljsonElement;
begin
  rslt := pljson.parseJson( json, bool.cTrue, bool.cFalse, err );
  utl.checkError(err);
  return rslt;
end parseJSON;

static function refCursorToJson
  ( input    in sys_refcursor,
    compact  in boolean  default false,
    rootName in varchar2 default 'json',
    pretty   in boolean  default false,
    dateFmt  in varchar2 default 'yyyy-MM-dd HH:mm:ss' )
  return CLOB
is
  rslt CLOB;
  err  varchar2(32000);
begin
  rslt := pljson.refCursorToJson
            ( input,
              rootName,
              case when compact then 1 else 0 end,
              case when pretty  then 1 else 0 end,
              dateFmt,
              err );
  utl.checkError(err);
  return rslt;
end refCursorToJson;

end;
/

--------------------------------------------------------------------------------

create or replace type body pljsonObject is

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

constructor function pljsonObject
  ( self in out nocopy pljsonObject )
  return self as result
is
begin
  self."~" := 'daElVTjd5yGxxlulG2Pv4mmh';
  self.tuple := new pljsonObjectEntries();
  return;
end pljsonObject;

member function getIndex
  ( self   in out nocopy pljsonObject,
    aName  in varchar2 )
  return binary_integer
is
  indx binary_integer;
begin

  indx := tuple.first;

  <<searchLoop>>
  while indx is not null
  loop
    if tuple(indx).name = aName then
      exit searchLoop;
    end if;
    indx := tuple.next(indx);
  end loop searchLoop;

  return indx;

end getIndex;

member function getMember
  ( self   in out nocopy pljsonObject,
    aName  in  varchar2 )
  return pljsonElement
is
  rslt pljsonElement;
  indx binary_integer;
begin

  indx := self.getIndex(aName);
  if indx is not null then
    rslt := tuple(indx).value;
  end if;

  return rslt;

end getMember;

member procedure addMember
  ( self    in out nocopy pljsonObject,
    aName   in  varchar2,
    element in pljsonElement )
is
  indx binary_integer;
begin

  indx := self.getIndex(aName);

  if indx is null then
    tuple.extend;
    indx := tuple.last;
  end if;

  tuple(indx) := new pljsonObjectEntry(aName, element);

end addMember;

member procedure addMember
  ( self    in out nocopy pljsonObject,
    aName   in  varchar2,
    element in  varchar2 )
is
begin
  addMember(aName, new pljsonString(element));
end addMember;

member procedure addMember
  ( self    in out nocopy pljsonObject,
    aName   in  varchar2,
    element in  number )
is
begin
  addMember(aName, new pljsonNumber(element));
end addMember;

member procedure addMember
  ( self    in out nocopy pljsonObject,
    aName   in  varchar2,
    element in  boolean )
is
begin
  addMember(aName, new pljsonBoolean(element));
end addMember;

member procedure deleteMember
  ( self    in out nocopy pljsonObject,
    aName   in varchar2 )
is
  indx  binary_integer;
begin
  indx := self.getIndex(aName);
  if indx is not null then
    tuple.delete(indx);
  end if;
end deleteMember;

end;
/

--------------------------------------------------------------------------------

create or replace type body pljsonArray is

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

constructor function pljsonArray
  ( self in out nocopy pljsonArray )
  return self as result
is
begin
  self."~" := 'ZZyQnZyETd0uEhQCh1Qqc45S';
  self.elements := new pljsonElements();
  return;
end pljsonArray;

member procedure addElement
  ( self    in out nocopy pljsonArray,
    element in pljsonElement )
is
begin
  elements.extend;
  elements(elements.last) := element;
end addElement;

member procedure addElement
  ( self    in out nocopy pljsonArray,
    element in  varchar2 )
is
begin
  addElement(new pljsonString(element));
end addElement;

member procedure addElement
  ( self    in out nocopy pljsonArray,
    element in  number )
is
begin
  addElement(new pljsonNumber(element));
end addElement;

member procedure addElement
  ( self    in out nocopy pljsonArray,
    element in  boolean )
is
begin
  addElement(new pljsonBoolean(element));
end addElement;

member procedure deleteElement
  ( self     in out nocopy pljsonArray,
    position in  binary_integer )
is
begin
  elements.delete(position);
end deleteElement;

end;
/

--------------------------------------------------------------------------------

create or replace type body pljsonBoolean is

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

member function value return boolean
is
begin
  return bool.toBool(self.bval);
end value;

constructor function pljsonBoolean
  ( self in out nocopy pljsonBoolean,
    val  in boolean )
  return self as result
is
begin
  self."~" := 'dhAKeRQTw1k2Rpo9q9H86mMI';
  self.bval := bool.toChar(val);
  return;
end pljsonBoolean;

end;
/

--------------------------------------------------------------------------------

create or replace type body pljsonNull is

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

constructor function pljsonNull
  ( self in out nocopy pljsonNull )
  return self as result
is
begin
  self."~" := 'N4rsqsFXfWQYuS2tekZMU7Xx';
  return;
end pljsonNull;

end;
/

--------------------------------------------------------------------------------

create or replace type body pljsonString is

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

constructor function pljsonString
  ( self in out nocopy pljsonString,
    val  in varchar2 )
  return self as result
is
begin
  self."~" := 'LavdJ6qDpIwVQHGSNVD9d3U4';
  self.value := val;
  return;
end pljsonString;

end;
/

--------------------------------------------------------------------------------

create or replace type body pljsonNumber is

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

constructor function pljsonNumber
  ( self in out nocopy pljsonNumber,
    val  in number )
  return self as result
is
begin
  self."~" := 'ys1Y2sh2gm8QK5z5u04M5rIS';
  self.value := val;
  return;
end pljsonNumber;

end;
/

