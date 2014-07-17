create or replace package pljson authid current_user is

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

--------------------------------------------------------------------------------
/*  parseJson

    supply a JSON document (as a VARCHAR2 or a CLOB)
    and get back an object tree that represents the document

*/
  function parseJson
    ( json  in  CLOB )
    return pljsonElement;

--------------------------------------------------------------------------------
/*  makeJson

    supply an object tree that represents what you want, and
    get back a JSON document as a CLOB. Specify pretty to
    get the document in a more readable format.

    The returned CLOB should be freed using DBMS_LOB.FREETEMPORARY();

*/
  function makeJson
    ( pljson in pljsonElement,
      pretty in boolean default false )
    return CLOB;

--------------------------------------------------------------------------------
/*  refCursorToJson

    supply a ref-cursor that represents what you want, and
    get back a JSON document as a CLOB. The returned data is an object
    with an array of arrays. Datatypes supported are: any CHAR/VARCHAR type,
    any NUMBER type, DATE and TIMESTAMP, nested CURSORs, and UDT's.

    TIMESTAMP WITH [LOCAL] TIME ZONE are not supported. Since JSON doesn't natively
    support dates, it's a good idea to use TO_CHAR(...) in your SELECT statment for
    any DATE/TIMESTAMP, but you can supply a dateFmt in Java SimpleDateFormat syntax
    if you like.

    The standard format returned is:

    {"json":[row1,row2,rowX]}

    where each row is an array of column values in the form of:
    [{"columnName":jsonValue},{"columnName":jsonValue}]

    Specify compact to return the data in a more compact format, where
    the first row is an array of column names, and each subsequent row
    is an array of values corresponding to the specified columns:

    ["columnName","columnName",...],[jsonValue,jsonValue,...],[jsonValue,jsonValue,...]

    Specify pretty to get the document in a more readable format.

    The returned CLOB should be freed using DBMS_LOB.FREETEMPORARY();

*/
  function refCursorToJson
    ( input    in sys_refcursor,
      compact  in boolean  default false,
      rootName in varchar2 default 'json',
      pretty   in boolean  default false,
      dateFmt  in varchar2 default 'yyyy-MM-dd HH:mm:ss' )
    return CLOB;

/******************************************************************************
    Most of the following functions are due to the restrictive nature of
    PL/SQL regarding recursive references. It would be nice to have true
    abstract classes and self referencing types, but SQL doesn't allow it
    for good reason.

    The following createXxx functions are the "constructors" for the objects
    you will use. Do not call constructors directly.

 ******************************************************************************/
  function createObject    return pljsonObject;
  function createArray     return pljsonArray;
  function createNull      return pljsonNull;

  function createString  ( val in varchar2 ) return pljsonString;
  function createNumber  ( val in number )   return pljsonNumber;
  function createBoolean ( val in boolean )  return pljsonBoolean;

/******************************************************************************
    Conversion Functions: again because PL/SQL doesn't allow recursive
    references, we have to convert a pljsonElement to a pljsonObject or pljsonArray
    this way. Since we do this, we'll do the other types this way as well.
 ******************************************************************************/
  function getObject  ( e  in pljsonElement ) return pljsonObject;
  function getArray   ( e  in pljsonElement ) return pljsonArray;
  function getString  ( e  in pljsonElement ) return varchar2;
  function getNumber  ( e  in pljsonElement ) return number;
  function getBoolean ( e  in pljsonElement ) return boolean;

/******************************************************************************
    These are "private". Don't use these. Instead use pljsonElement.isXxx.
 ******************************************************************************/
  function "isObject "( e  in  pljsonElement ) return boolean;
  function "isArray  "( e  in  pljsonElement ) return boolean;
  function "isString "( e  in  pljsonElement ) return boolean;
  function "isNumber "( e  in  pljsonElement ) return boolean;
  function "isBoolean"( e  in  pljsonElement ) return boolean;
  function "isNull   "( e  in  pljsonElement ) return boolean;

end pljson;
/
