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

member function isObject    return boolean is begin return pljson."isObject "(self); end isObject    ;
member function isArray     return boolean is begin return pljson."isArray  "(self); end isArray     ;
member function isNull      return boolean is begin return pljson."isNull   "(self); end isNull      ;
member function isString    return boolean is begin return pljson."isString "(self); end isString    ;
member function isNumber    return boolean is begin return pljson."isNumber "(self); end isNumber    ;
member function isBoolean   return boolean is begin return pljson."isBoolean"(self); end isBoolean   ;
member function isPrimitive return boolean is begin return self is of (pljsonPrimitive); end isPrimitive ;

member function getString   return varchar2 is begin return pljson.getString(self); end getString;
member function getNumber   return number   is begin return pljson.getNumber(self); end getNumber;
member function getBoolean  return boolean  is begin return pljson.getBoolean(self); end getBoolean;

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
  addMember(aName, pljson.createString(element));
end addMember;

member procedure addMember
  ( self    in out nocopy pljsonObject,
    aName   in  varchar2,
    element in  number )
is
begin
  addMember(aName, pljson.createNumber(element));
end addMember;

member procedure addMember
  ( self    in out nocopy pljsonObject,
    aName   in  varchar2,
    element in  boolean )
is
begin
  addMember(aName, pljson.createBoolean(element));
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
is begin return nvl(val, ' ') = '*'; end;
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
  addElement(pljson.createString(element));
end addElement;

member procedure addElement
  ( self    in out nocopy pljsonArray,
    element in  number )
is
begin
  addElement(pljson.createNumber(element));
end addElement;

member procedure addElement
  ( self    in out nocopy pljsonArray,
    element in  boolean )
is
begin
  addElement(pljson.createBoolean(element));
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
