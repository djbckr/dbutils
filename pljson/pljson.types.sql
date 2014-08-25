create type pljsonElement oid '96590F8B68C0B283BF683389525F318F' authid definer is object (

/* ::::::::::::::: FULL DOCUMENTATION BELOW :::::::::::::::

Copyright 2014, Ruby Willow, Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of Ruby Willow, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#PLJSON Library

The PLJSON library is a unit that allows you to do three things:

- Parse a JSON document into a SQL Object tree for easy traversal.
- Create a SQL Object tree to make a corresponding JSON document.
- Create a JSON document in a couple of formats from a ref-cursor. This library supports Object Types, Nested Tables, nested cursors, and ANYDATA data.

This library is divided into three layers:

- A set of SQL Objects and PL/SQL that you can see and have access to.
- The [GSON library](http://code.google.com/p/google-gson/) which is the underlying engine.
- The Java "glue" that translates between PL/SQL and GSON.

### Part 1 - Dealing with JSON in SQL

JSON defines a few particulars (go [here](http://json.org/) for details):

- Value: This can be a primitive type (string, number, Boolean), an Object, an Array, or a NULL. A string is identified by surrounding double-quotes. A number does not have quotes and may be scientific-notated. Boolean is either the literal `true` or `false`. A NULL uses the literal `null`.
- Object: this is a collection of one or more "name":value pairs (herein referred to as tuple in this document). The value could be a primitive type, a NULL value, an Array, or another Object. The name must be a string type. An Object is denoted by an opening and closing brace: "{" and "}". Each tuple is separated by a comma.
- Array: this is an ordered list of zero or more values. The value could a primitive type, a NULL value, another Array, or an Object. An Array is denoted by an opening and closing bracket: "[" and "]". Each item in the array is separated by a comma. The values need not be the same type for each element in the array.
- Strings have certain escape sequences, but you need not worry about that; the GSON library takes care of translating these for you.

JavaScript is a weakly typed and fully dynamic language, and that concept is diametrically opposed to the nature of SQL Objects and the PL/SQL language. This makes the translation to/from the two languages somewhat difficult. The attempt of this library was to make this as graceful as possible, but there is one item to keep in mind:

- Do not attempt to use or modify the "~" attribute of the `pljsonElement` type. It is intended to be private/abstract, but SQL Types must have at least one public attribute, even if they are abstract. This attribute is used internally in the Java layer of this library, so modifying it will create problems for you.

### Part 2 - The SQL Types

The SQL Types are defined as follows:

### pljsonElement

This is the root type for all JSON objects that can be instantiated. It has one attribute that should not be referenced by your code, and therefore has that unusual attribute name. This type is abstract and cannot be instantiated.

`pljsonElement` has a number of member methods:

    member function isObject    return boolean
    member function isArray     return boolean
    member function isPrimitive return boolean
    member function isNull      return boolean
    member function isString    return boolean
    member function isNumber    return boolean
    member function isBoolean   return boolean

    member function getString   return varchar2
    member function getNumber   return number
    member function getBoolean  return boolean

    member function makeJSON
      ( self in out nocopy pljsonElement,
        pretty in boolean default false )
      return CLOB,

    static function parseJSON
      ( json  in  CLOB )
      return pljsonElement,

    static function refCursorToJson
      ( input    in sys_refcursor,
        compact  in boolean  default false,
        rootName in varchar2 default 'json',
        pretty   in boolean  default false,
        dateFmt  in varchar2 default 'yyyy-MM-dd HH:mm:ss' )
      return CLOB

You will likely use the `makeJSON`, `parseJSON`, and `refCursorToJson` functions most often. They are pretty straightforward. Given a `pljsonElement` (well, one of the sub-types), call `makeJSON()`, and it will return a CLOB of JSON. The CLOB is temporary, so you should eventually free it using `dbms_lob.freeTemporary()`.

The other two methods are static, so you would say `pljsonElement.parseJSON()` and `pljsonElement.refCursorToJson()`. You can't call these from an instantiated object.

The `parseJSON()` function takes a JSON document and returns the root element. The element could either be an object or an array. This is the slowest operation you will encounter, especially for large documents, since the document must be parsed, translated into the GSON object tree, then translated into a SQL object tree. Some databases appear to work better than others, but it hasn't been determined what makes them better or worse.

The `refCursorToJson()` static method requires some more explanation, so go to the bottom of this document for a complete picture.

Note that `getString`, `getNumber`, and `getBoolean` are considered convenience methods and will return "best-effort"
for primitive types. `getString` will return a string-ified value for a number, and for Boolean, the character BOOL.cTrue (asterisk/star)
for a true value and a BOOL.cFalse (space) for a false value. If a type can't be readily translated, NULL is returned.
For example, a call to `getNumber` for a Boolean type will return NULL.

### pljsonObject
Subtype of `pljsonElement`. This is the most complex of the types. It is defined as follows:

    tuple  pljsonObjectEntries,

    constructor function pljsonObject
      ( self in out nocopy pljsonObject )
      return self as result,

    member function getIndex
      ( self   in out nocopy pljsonObject,
        aName  in varchar2 )
      return binary_integer,

    member function getMember
      ( self   in out nocopy pljsonObject,
        aName  in  varchar2 )
      return pljsonElement,

    member procedure addMember
      ( self    in out nocopy pljsonObject,
        aName   in  varchar2,
        element in pljsonElement ),

    -- convenience methods to quickly add primitives
    member procedure addMember
      ( self    in out nocopy pljsonObject,
        aName   in  varchar2,
        element in  varchar2 ),

    member procedure addMember
      ( self    in out nocopy pljsonObject,
        aName   in  varchar2,
        element in  number ),

    member procedure addMember
      ( self    in out nocopy pljsonObject,
        aName   in  varchar2,
        element in  boolean ),

    member procedure deleteMember
      ( self    in out nocopy pljsonObject,
        aName   in varchar2 )

Using `tuple` is the best way to represent a dynamic list of members, and it is a nested table `pljsonObjectEntries`, which is a table of `pljsonObjectEntry`, which is defined as:

    name    varchar2(4000),
    value   pljsonElement

In general, you shouldn't need to access the tuple directly, but you can if you like. You can treat it like any other nested table object. If you want to iterate through the table, be aware that it could be "sparse" and so you want to use the appropriate [iteration method](http://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#BEIBJDBF).

- `constructor function pljsonObject` is the no-value constructor to create this object.
- `getIndex` returns the index offset of the named entry. If the entry doesn't exist, NULL is returned.
- `getMember` returns the `pljsonElement` of the named entry. If the entry doesn't exist, NULL is returned.
- `addMember` adds a `pljsonElement` to the entries. If the named entry already exists, it is overwritten.
- `deleteMember` removes the named member from the entries if it exists. Nothing happens if it doesn't.
- The convenience methods create the correct primitive type to be used in the tuple.

### pljsonArray

Subtype of `pljsonElement`. This represents a JSON array, and is defined as follows:

    elements  pljsonElements,

    constructor function pljsonArray
      ( self in out nocopy pljsonArray )
      return self as result,

    member procedure addElement
      ( self    in out nocopy pljsonArray,
        element in pljsonElement ),

    -- convenience methods to quickly add primitives
    member procedure addElement
      ( self    in out nocopy pljsonArray,
        element in  varchar2 ),

    member procedure addElement
      ( self    in out nocopy pljsonArray,
        element in  number ),

    member procedure addElement
      ( self    in out nocopy pljsonArray,
        element in  boolean ),

    member procedure deleteElement
      ( self     in out nocopy pljsonArray,
        position in  binary_integer )

The elements in this object is a `pljsonElements` which is simply a table of `pljsonElement`. Like `pljsonObject`, you can iterate through elements using the proper technique.

- `constructor function pljsonArray` is the no-value constructor to create this object.

### pljsonPrimitive

Subtype of `pljsonElement`. This is simply the base type of the four primitive types.  It is not instantiable (that is, it's abstract), has no additional methods, and is typically never referenced in your code. It is here simply to provide structure.

### pljsonNull
Subtype of `pljsonPrimitive`. This is the most reasonable way to represent that a particular JSON value is actually NULL. It has no additional attributes, and has a no-value constructor.

### pljsonString
Subtype of `pljsonPrimitive`.  It has one additional attribute:

    value    varchar2(32760 char)

and has a constructor where you provide the value.

Note that strings stored here will be properly escaped when serialized in JSON output. When a JSON document creates this object, the string is restored "un-escaped".

### pljsonNumber
Subtype of `pljsonPrimitive`.  It has one additional attribute:

    value    number

and has a constructor where you provide the value.

When serialized in JSON output, the number will always be represented in non-scientific notation. Be aware that very large numbers can be silently truncated when parsed by a standard Javascript engine.

### pljsonBoolean

Subtype of `pljsonPrimitive`.  It has one additional attribute and one method:

    bval   varchar2(1),  -- the value stored here is defined in the BOOL package

    member function value
      return boolean,    -- use this function to be sure of the correct value

and has constructor where you provide the initial value.

You should use the `value()` method in your code, or use the `getBoolean()` method from `pljsonElement`. When serialized in JSON output, this primitive is properly converted to use the words `true` and `false` appropriately in the document.

## An explanation of refCursorToJson()

The JSON document that is returned always starts with an object with one member, specified by rootName. That member is always an array.

    {"json":[...]}

From there, you have a choice of formats: Normal, and Compact. The normal format returns an array of objects. Each object is one row of the cursor. Each object contains all of the field values of the row. If a column is NULL, the JSON object will be serialized as NULL.

Given the following query:

    select cast(dbms_random.string('a',12) as varchar2(30)) as "varChar2",
           round(cast(dbms_random.value(1, 100000) as number), 7) as num,
           cast(sysdate+dbms_random.value(-1000, 1000) as date) as dt
      from dual connect by level < 5

We get the JSON document as follows:

    { "json":[
        { "varChar2":"wWFzTFdjrXvL",
          "NUM":92142.4009135,
          "DT":"2017-02-16 01:32:41" },
        { "varChar2":"hjGEmlwAvNrV",
          "NUM":20319.5043451,
          "DT":"2014-12-18 10:06:16" },
        { "varChar2":"LVpQrxzKgzeY",
          "NUM":62212.153137,
          "DT":"2014-07-14 11:17:45" },
        { "varChar2":"fXdlfMdSVENV",
          "NUM":92895.0227431,
          "DT":"2016-01-25 22:25:32" }
      ]
    }

A few things to note: If you specify a case-sensitive label (x AS "something"), the object attribute will reflect that. See how "varChar2" is labeled. Also note, that dates are serialized as strings based on the dateFmt. dateFmt is a Java SimpleDateFormat format string. Refer to the Java documentation for the elements in the format string.

Specifying compact returns the data in a slightly more compact fashion:

    { "json":[
        [ "varChar2",
          "NUM",
          "DT" ],
        [ "rQceaTAjUuVc",
          94043.4734433,
          "2013-03-05 17:30:29" ],
        [ "ImdRIamaZVog",
          64596.3543953,
          "2014-07-21 03:02:35" ],
        [ "qmDjNbpHTeHB",
          36919.665535,
          "2012-01-22 01:42:45" ],
        [ "zZxnyHkeezvW",
          16774.7550996,
          "2015-04-10 12:46:39" ]
      ]
    }

This results in an array of arrays, where the first array contains the column labels, and the subsequent arrays contain the column data.

As noted at the beginning of this document, objects, nested tables, and nested cursors are supported. Given the following query:

    select cast(dbms_random.string('a',12) as varchar2(30)) "varChar2",
           round(cast(dbms_random.value(1, 100000) as number), 7) num,
           cursor(select cast(dbms_random.string('a',10) as varchar2(10)) "subField1",
                         round(dbms_random.value(1, 100000000000), 4) "subNumber2"
                    from dual connect by level < 4) crsr
      from dual connect by level < 5

The normal JSON looks like:

    { "json": [
        { "varChar2": "UjfDosEGMNBm",
          "NUM": 93428.8585544,
          "CRSR": [
            { "subField1": "XnDcBzoHLp",
              "subNumber2": 35653935772.037 },
            { "subField1": "DQOQOlKxhv",
              "subNumber2": 91540154112.4731 },
            { "subField1": "vMMppIKxrx",
              "subNumber2": 22582327522.4681 }
          ]
        },
        { "varChar2": "GbYeoKgowuDH",
          "NUM": 48212.818676,
          "CRSR": [
            { "subField1": "kMNkiqZGiJ",
              "subNumber2": 75010070169.8976 },
            { "subField1": "yevTKNgdGv",
              "subNumber2": 74665741685.6596 },
            { "subField1": "kdslLwfFXZ",
              "subNumber2": 59021183992.4713 }
          ]
        },
        { "varChar2": "FXqxLFudaHtF",
          "NUM": 13884.848568,
          "CRSR": [
            { "subField1": "QAwGorsHUt",
              "subNumber2": 49869676584.8504 },
            { "subField1": "rfWDVlRtdi",
              "subNumber2": 79279821361.3168 },
            { "subField1": "dxZhNvxgNa",
              "subNumber2": 75694323505.735 }
          ]
        },
        { "varChar2": "NLtnDNPYaXHt",
          "NUM": 15641.151077,
          "CRSR": [
            { "subField1": "ulkLDVBWgm",
              "subNumber2": 35259647752.7328 },
            { "subField1": "HgOXdqJnMD",
              "subNumber2": 54007481353.2732 },
            { "subField1": "phKClYGiHo",
              "subNumber2": 21291801388.0795 }
          ]
        }
      ]
    }

And the compact JSON looks like:

{
  "json":[
    [ "varChar2",
      "NUM",
      "CRSR" ],
    [ "wKERFDSiWKjP",
      82270.5508032,
      [ [ "subField1",
          "subNumber2" ],
        [ "glzwoRKHDi",
          84303519002.5887 ],
        [ "sLdpoKtUtV",
          18084687027.1173 ],
        [ "gxxSIPwiXe",
          65519335329.8466 ] ]
    ],
    [ "PnwTHzjNYcYK",
      23459.6877103,
      [ [ "subField1",
          "subNumber2" ],
        [ "cffSbtkNaR",
          41661787803.74 ],
        [ "lgcmRDUDku",
          39830007084.9897 ],
        [ "dEIMkzimlL",
          45167351872.926 ] ]
    ],
    [ "YmIMPJmtYYia",
      68969.8186501,
      [ [ "subField1",
          "subNumber2" ],
        [ "YeEiZYUlPG",
          81177093819.4247 ],
        [ "IjPWdSgcsI",
          74672220578.6526 ],
        [ "lsQSKfVZyp",
          99434537851.8094 ] ]
    ],
    [ "pMipnDmEDmei",
      18938.6663589,
      [ [ "subField1",
          "subNumber2" ],
        [ "qPBLmpkJaC",
          8345850947.9432 ],
        [ "tblfRbbuXw",
          30032882289.2958 ],
        [ "owPOuxTbPw",
          11520490169.0549 ] ]
    ]
  ]
}

We will leave it as an exercise to the reader to try objects and nested tables. However, since objects and nested tables cannot easily be "compacted", they are always presented as "normal".

*/

  "~"  varchar2(24),

  member function isObject
    return boolean,

  member function isArray
    return boolean,

  member function isPrimitive
    return boolean,

  member function isNull
    return boolean,

  member function isString
    return boolean,

  member function isNumber
    return boolean,

  member function isBoolean
    return boolean,

  -- convenience functions: getString() will return a value
  -- for any of the primitive types, otherwise returns NULL
  member function getString
    return varchar2,

  -- if this is a number, returns its value, otherwise returns NULL
  member function getNumber
    return number,

  -- if this is a boolean, returns its value, otherwise return NULL
  member function getBoolean
    return boolean,

  -- using this element as the root, create a JSON document.
  -- the returned CLOB is temporary and should eventually
  -- be freed using dbms_lob.freeTemporary()
  member function makeJSON
    ( self in out nocopy pljsonElement,
      pretty in boolean default false )
    return CLOB,

  -- parse a JSON document and get a root element.
  static function parseJSON
    ( json  in  CLOB )
    return pljsonElement,

  -- pass a ref-cursor and get a JSON document
  -- the returned CLOB is temporary and should eventually
  -- be freed using dbms_lob.freeTemporary()
  static function refCursorToJson
    ( input    in sys_refcursor,
      compact  in boolean  default false,
      rootName in varchar2 default 'json',
      pretty   in boolean  default false,
      dateFmt  in varchar2 default 'yyyy-MM-dd HH:mm:ss' )
    return CLOB

) not final not instantiable;
/

create type pljsonObjectEntry oid '06C6F3EA71E57DDB2CC016CCCD3FF056' authid definer is object (

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

  /* an Object Entry is a name/value pair.
     The value can be any pljsonElement subtype */

  name    varchar2(4000),
  value   pljsonElement

) final instantiable;
/

-- an Object has a table of Object Entries
create type pljsonObjectEntries oid '39F7ABDECD755CA979565FB1039D7F70' is table of pljsonObjectEntry;
/

create type pljsonObject oid '360141B0610AD5BB7AAB8A56C8943AB4' authid definer under pljsonElement (

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

  /* a JSON object has a table of Object Entries */
  tuple  pljsonObjectEntries,

  constructor function pljsonObject
    ( self in out nocopy pljsonObject )
    return self as result,

  member function getIndex
    ( self   in out nocopy pljsonObject,
      aName  in varchar2 )
    return binary_integer,

  member function getMember
    ( self   in out nocopy pljsonObject,
      aName  in  varchar2 )
    return pljsonElement,

  member procedure addMember
    ( self    in out nocopy pljsonObject,
      aName   in  varchar2,
      element in pljsonElement ),

  -- convenience methods to quickly add primitives
  member procedure addMember
    ( self    in out nocopy pljsonObject,
      aName   in  varchar2,
      element in  varchar2 ),

  member procedure addMember
    ( self    in out nocopy pljsonObject,
      aName   in  varchar2,
      element in  number ),

  member procedure addMember
    ( self    in out nocopy pljsonObject,
      aName   in  varchar2,
      element in  boolean ),

  member procedure deleteMember
    ( self    in out nocopy pljsonObject,
      aName   in varchar2 )

) final instantiable;
/

-- an array has a table of elements
create type pljsonElements oid 'EB1A892742A0E6511D9C83F15C2C6CFF' is table of pljsonElement;
/

create type pljsonArray oid '14BECEF1F6E64EBA45635485EB426F32' authid definer under pljsonElement (

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

  /* a JSON array has a table of Elements */
  elements  pljsonElements,

  constructor function pljsonArray
    ( self in out nocopy pljsonArray )
    return self as result,

  member procedure addElement
    ( self    in out nocopy pljsonArray,
      element in pljsonElement ),

  -- convenience methods to quickly add primitives
  member procedure addElement
    ( self    in out nocopy pljsonArray,
      element in  varchar2 ),

  member procedure addElement
    ( self    in out nocopy pljsonArray,
      element in  number ),

  member procedure addElement
    ( self    in out nocopy pljsonArray,
      element in  boolean ),

  member procedure deleteElement
    ( self     in out nocopy pljsonArray,
      position in  binary_integer )

) final instantiable;
/

create type pljsonPrimitive oid 'F3032476FFB7F89CDA56884E0B64AC1D' authid definer under pljsonElement (
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
) not final not instantiable;
/

create type pljsonNull oid 'FB2A64820A8665856C506B7CCADB3B55' authid definer under pljsonPrimitive (
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
  -- concrete element value of Null

  constructor function pljsonNull
    ( self in out nocopy pljsonNull )
    return self as result

) final instantiable;
/

create type pljsonString oid 'C1068B34CE7EFE2506837A1669EA8F42' authid definer under pljsonPrimitive (
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
  -- concrete primitive value of String
  value    varchar2(32760 char),

  constructor function pljsonString
    ( self in out nocopy pljsonString,
      val  in varchar2 )
    return self as result

) final instantiable;
/

create type pljsonNumber oid '68DB9E5A9341332C951AA0C463AB6532' authid definer under pljsonPrimitive (
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
  -- concrete primitive value of Number
  value    number,

  constructor function pljsonNumber
    ( self in out nocopy pljsonNumber,
      val  in number )
    return self as result

) final instantiable;
/

create type pljsonBoolean oid 'D68D68058D04CBE0F1499A6216A5E29D' authid definer under pljsonPrimitive (
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
  -- concrete primitive value of Boolean
  bval   varchar2(1),    -- the value stored here is defined in the BOOL package

  member function value
    return boolean,      -- use this function to be sure of the correct value

  constructor function pljsonBoolean
    ( self in out nocopy pljsonBoolean,
      val  in boolean )
    return self as result

) final instantiable;
/
