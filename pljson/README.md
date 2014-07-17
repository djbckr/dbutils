Copyright &copy; 2012, Ruby Willow, Inc. All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of Ruby Willow, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#PLJSON Library

The PLJSON library is a unit that allows you to do three things:

-Parse a JSON document into a SQL Object tree for easy traversal.
-Create a SQL Object tree to make a corresponding JSON document.
-Create a JSON document in a couple of formats from a ref-cursor. This library supports Object Types, Nested Tables, nested cursors, and ANYDATA data.

This library is divided into three layers:

-A set of SQL Objects and PL/SQL that you can see and have access to.
-The [GSON library](http://code.google.com/p/google-gson/) which is the underlying engine.
-The Java "glue" that translates between PL/SQL and GSON.

### Part 1 - Dealing with JSON in SQL

JSON defines a few particulars (go [here](http://json.org/) for details):

- Value: This can be a primitive type (string, number, Boolean), an Object, an Array, or a NULL. A string is identified by surrounding double-quotes. A number does not have quotes and may be scientific-notated. Boolean is either the literal true or false. A NULL uses the literal null.
- Object: this is a collection of one or more "name":value pairs (herein referred to as tuple in this document). The value could be a primitive type, a NULL value, an Array, or another Object. The name must be a string type. An Object is denoted by an opening and closing brace: "{" and "}". Each tuple is separated by a comma.
- Array: this is an ordered list of zero or more values. The value could a primitive type, a NULL value, another Array, or an Object. An Array is denoted by an opening and closing bracket: "[" and "]". Each item in the array is separated by a comma. The values need not be the same type for each element in the array.
- Strings have certain escape sequences, but you need not worry about that; the GSON library takes care of translating these for you.

JavaScript is a weakly typed and fully dynamic language, and that concept is diametrically opposed to the nature of SQL Objects and the PL/SQL language. This makes the translation to/from the two languages somewhat difficult. The attempt of this library was to make this as graceful as possible, but there are a couple of items to keep in mind.

- Do not instantiate the PLJSON objects using normal constructors. Instead, use the PLJSON package functions "createXxxx". This is partly because of the following point:
- Do not attempt to use or modify the "~" attribute of the `pljsonElement` type. It is intended to be private/abstract, but SQL Types must have at least one public attribute, even if they are abstract. This attribute is used internally in the Java layer of this library, so modifying it will create problems for you.

### Part 2 - The SQL Types

The SQL Types are defined as follows:

`PLJSONELEMENT`

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

Note that `getString`, `getNumber`, and `getBoolean` are considered convenience methods and will return "best-effort"
for primitive types. `getString` will return a string-ified value for a number, and for Boolean, the character BOOL.cTrue (asterisk/star) for a true value and a BOOL.cFalse (space)
for a false value. If a type can't be readily translated, NULL is returned. For example, a call to `getNumber` for a Boolean type will return NULL.

`PLJSONOBJECT`
Subtype of `pljsonElement`. This is the most complex of the types. It is defined as follows:

`  tuple  pljsonObjectEntries,

  `member` `function` getIndex
    `(` aName  `in` `varchar2` `)`
    `return` `binary_integer`,

  `member` `function` getMember
    `(` aName  `in`  `varchar2` `)`
    `return` pljsonElement,

  `member` `procedure` addMember
    `(` aName  `in`  `varchar2`,
      `element` `in` pljsonElement `)`,

  `--`` ``convenience`` ``methods`` ``to`` ``quickly`` ``add`` ``primitives`
  `member` `procedure` addMember
    `(` aName   `in`  `varchar2`,
      `element` `in`  `varchar2` `)`,

  `member` `procedure` addMember
    `(` aName   `in`  `varchar2`,
      `element` `in`  `number` `)`,

  `member` `procedure` addMember
    `(` aName   `in`  `varchar2`,
      `element` `in`  `boolean` `)`
`

<p>Using <strong>tuple</strong> is the best way to represent a dynamic list of members, and it is a nested table `pljsonObjectEntries`, which is a table of `pljsonObjectEntry`, which is defined as:</p>

<pre>`  `name`    `varchar2``(`<span class="syntax-DIGIT">4000``)`,
  <span class="syntax-KEYWORD2">value`   pljsonElement
`</pre>

<p>In general, you shouldn't need to access the tuple directly, but you can if you like. You can treat it like any other nested table object. If you want to iterate through the table, be aware that it could be "sparse" and so you want to use the appropriate <a href="http://docs.oracle.com/cd/E11882_01/appdev.112/e25519/composites.htm#BEIBJDBF" target="_blank">iteration method</a>.</p>

<p>`getIndex` returns the index offset of the named entry. If the entry doesn't exist, NULL is returned.</p>
<p>`getMember` returns the `pljsonElement` of the named entry. If the entry doesn't exist, NULL is returned.</p>
<p>`addMember` adds a `pljsonElement` to the entries. If the named entry already exists, it is overwritten.</p>
<p>The one method that you don't see is "`removeMember`". This is because of a particular limitation of PL/SQL reassigning the tuple back to itself inside the object. But you can delete out of the tuple as follows:</p>
<pre>  obj.tuple.delete(obj.getIndex('memberName'));</pre>
<p>Where `obj` is your object variable. Hopefully you won't need to do this much.</p>
<p>The convenience methods create the correct primitive type to be used in the tuple.</p>
<h3>PLJSONARRAY (`pljsonArray`)</h3>
<p>Subtype of `pljsonElement`. This represents a JSON array, and is defined as follows:</p>

<pre>`  elements  pljsonElements,

  `member` `procedure` addElement
    `(` `element` `in` pljsonElement `)`,

  `--`` ``convenience`` ``methods`` ``to`` ``quickly`` ``add`` ``primitives`
  `member` `procedure` addElement
    `(` `element` `in`  `varchar2` `)`,

  `member` `procedure` addElement
    `(` `element` `in`  `number` `)`,

  `member` `procedure` addElement
    `(` `element` `in`  `boolean` `)`
`</pre>

<p>The elements in this object is a `pljsonElements` which is simply a table of `pljsonElement`. Like `pljsonObject`, you can iterate through elements using the proper technique. As well, to delete from elements, use the same method described above.</p>

<p>The convenience methods create the correct primitive type to be used.</p>

<h3>PLJSONPRIMITIVE (`pljsonPrimitive`)</h3>

<p>Subtype of `pljsonElement`. This is simply the base type of the four primitive types.  It is not instantiable (that is, it's abstract), has no additional methods, and is typically never referenced in your code. It is here simply to provide structure.</p>

<h3>PLJSONNULL (`pljsonNull`)</h3>
<p>Subtype of `pljsonPrimitive`. This is the most reasonable way to represent that a particular JSON value is actually NULL. It has no additional attributes or methods.</p>

<h3>PLJSONSTRING (`pljsonString`)</h3>
<p>Subtype of `pljsonPrimitive`.  It has one additional attribute:</p>

<pre>`  <span class="syntax-KEYWORD2">value`    `varchar2``(`<span class="syntax-DIGIT">32000` `char``)`
`</pre>

<p>Note that strings stored here will be properly escaped when serialized in JSON output. When a JSON document creates this object, the string is restored "un-escaped".</p>

<h3>PLJSONNUMBER (`pljsonNumber`)</h3>
<p>Subtype of `pljsonPrimitive`.  It has one additional attribute:</p>

<pre>`  <span class="syntax-KEYWORD2">value`    `number`
`</pre>

<p>When serialized in JSON output, the number will always be represented in non-scientific notation.</p>

<h3>PLJSONBOOLEAN (`pljsonBoolean`)</h3>

<p>Subtype of `pljsonPrimitive`.  It has one additional attribute and one method:<p>

<pre>`  val    `varchar2``(`<span class="syntax-DIGIT">1``)`,    `--`` ``anything`` ``other`` ``than`` ``'*'`` ``is`` ``false`

  `member` `function` <span class="syntax-KEYWORD2">value`
    `return` `boolean`       `--`` ``but`` ``use`` ``this`` ``function`` ``to`` ``be`` ``sure`
`</pre>

<p>You should use the `value` method in your code, or use the `getBoolean` method from `pljsonElement`. When serialized in JSON output, this primitive is properly converted to use the words <strong>true</strong> and <strong>false</strong> appropriately in the document.</p>
<a href="#pt0">back to top</a>
<a name="pt4"></a>
<h2>Part 4 - The PLJSON Package</h2>

<p>This package is quite simple.</p>
<ul>
<li>First, it implements the three main tasks mentioned at the beginning of this document.</li>
<li>Second, it has the "constructors" for the objects you may need to create.</li>
<li>Third, it has conversion tools to allow you to convert one object type to another.</li>
</ul>

<p>The three main tasks:</p>

<pre>`  `function` parseJson
    `(` json  `in`  `CLOB` `)`
    `return` pljsonElement;
`</pre>

<p>This function takes a JSON document and returns the root element. The element could either be an object or an array. This is the slowest operation you will encounter, especially for large documents, since the document must be parsed, translated into the GSON object tree, then translated into a SQL object tree. Some databases appear to work better than others, but it hasn't been determined what makes them better or worse.</p>

<pre>`  `function` makeJson
    `(` pljson `in` pljsonElement,
      pretty `in` `boolean` `default` `false` `)`
    `return` `CLOB`;
`</pre>

<p>This function takes a root element (an object or an array) and returns a JSON document. Specify pretty to get the output in a more human-readable format. The returned CLOB is session-temporary, and you should free it using `dbms_lob.freeTemporary(...);` to avoid any TEMP tablespace issues.</p>

<pre>`  `function` refCursorToJson
    `(` input    `in` sys_refcursor,
      compact  `in` `boolean`  `default` `false`,
      rootName `in` `varchar2` `default` <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">json`<span class="syntax-LITERAL1">'`,
      pretty   `in` `boolean`  `default` `false`,
      dateFmt  `in` `varchar2` `default` <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">yyyy-MM-dd`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">HH:mm:ss`<span class="syntax-LITERAL1">'` `)`
    `return` `CLOB`;
`</pre>

<p>This function processes an open ref-cursor and turns it into a JSON document. This process is done entirely in Java, and bypasses the PL/SQL object creation mechanism, so it is quite fast. This uses the GSON serializer directly to the result CLOB, so large datasets should not be an issue. The returned CLOB is session-temporary, and you should free it using `dbms_lob.freeTemporary(...);` to avoid any TEMP tablespace issues.</p>

<p>The JSON document that is returned always starts with an object with one member, specified by `rootName`. That member is always an array.</p>

<pre>{"json":[...]}</pre>

<p>From there, you have a choice of formats: Normal, and Compact. The normal format returns an array of objects. Each object is one row of the cursor. Each object contains all of the field values of the row. If a column is NULL, the JSON object will be serialized as NULL.</p>

<p>Given the following query:</p>

<pre>``select` <span class="syntax-KEYWORD2">cast``(`<span class="syntax-KEYWORD3">dbms_random`.`string``(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1">'`,<span class="syntax-DIGIT">12``)` `as` `varchar2``(`<span class="syntax-DIGIT">30``)``)` `as` <span class="syntax-LITERAL2">&quot;`<span class="syntax-LITERAL2">varChar2`<span class="syntax-LITERAL2">&quot;`,
       <span class="syntax-KEYWORD2">round``(`<span class="syntax-KEYWORD2">cast``(`<span class="syntax-KEYWORD3">dbms_random`.<span class="syntax-KEYWORD2">value``(`<span class="syntax-DIGIT">1`, <span class="syntax-DIGIT">100000``)` `as` `number``)`, <span class="syntax-DIGIT">7``)` `as` num,
       <span class="syntax-KEYWORD2">cast``(`<span class="syntax-KEYWORD2">sysdate``+`<span class="syntax-KEYWORD3">dbms_random`.<span class="syntax-KEYWORD2">value``(``-`<span class="syntax-DIGIT">1000`, <span class="syntax-DIGIT">1000``)` `as` `date``)` `as` dt
  `from` dual `connect` `by` `level` `&lt;` <span class="syntax-DIGIT">5`
`</pre>

<p>We get the JSON document as follows:</p>

<pre>{ "json": [
    { "varChar2": "xEPnPeRCmuOv",
      "NUM": 21349.6088119,
      "DT": "2010-07-21 02:58:16" },
    { "varChar2": "JQrGaYJlgvbm",
      "NUM": 49904.2727362,
      "DT": "2013-09-11 06:02:49" },
    { "varChar2": "SXijRbUUMghW",
      "NUM": 40663.8263266,
      "DT": "2015-01-10 07:05:42" },
    { "varChar2": "hXOvoqnZGAMz",
      "NUM": 97087.044715,
      "DT": "2012-08-14 13:33:33" }
  ]
}</pre>

<p>A few things to note: If you specify a case-sensitive label (x AS "something"), the object attribute will reflect that. See how "varChar2" is labeled. Also note, that dates are serialized as strings based on the `dateFmt`. `dateFmt` is a Java `SimpleDateFormat` format string. Refer to the Java documentation for the elements in the format string.</p>

<p>Specifying compact returns the data in a slightly more compact fashion:</p>

<pre>{ "json": [
    [ "varChar2", "NUM", "DT" ],
    [ "GDRXvWZmQahh", 81298.3390885, "2013-01-21 11:40:43" ],
    [ "qefRYoMzzHwu", 76503.384392, "2014-08-25 10:29:59" ],
    [ "rsEflMMgFiPe", 69963.8523149, "2012-10-29 03:03:20" ],
    [ "hmLJmYyhzhra", 36927.5054318, "2010-04-21 11:18:28" ]
  ]
}</pre>

<p>This results in an array of arrays, where the first array contains the column labels, and the subsequent arrays contain the column data.</p>

<p>As noted at the beginning of this document, objects, nested tables, and nested cursors are supported. Given the following query:</p>

<pre>``select` <span class="syntax-KEYWORD2">cast``(`<span class="syntax-KEYWORD3">dbms_random`.`string``(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1">'`,<span class="syntax-DIGIT">12``)` `as` `varchar2``(`<span class="syntax-DIGIT">30``)``)` <span class="syntax-LITERAL2">&quot;`<span class="syntax-LITERAL2">varChar2`<span class="syntax-LITERAL2">&quot;`,
       <span class="syntax-KEYWORD2">round``(`<span class="syntax-KEYWORD2">cast``(`<span class="syntax-KEYWORD3">dbms_random`.<span class="syntax-KEYWORD2">value``(`<span class="syntax-DIGIT">1`, <span class="syntax-DIGIT">100000``)` `as` `number``)`, <span class="syntax-DIGIT">7``)` num,
       `cursor``(``select` <span class="syntax-KEYWORD2">cast``(`<span class="syntax-KEYWORD3">dbms_random`.`string``(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1">'`,<span class="syntax-DIGIT">10``)` `as` `varchar2``(`<span class="syntax-DIGIT">10``)``)` <span class="syntax-LITERAL2">&quot;`<span class="syntax-LITERAL2">subField1`<span class="syntax-LITERAL2">&quot;`,
                     <span class="syntax-KEYWORD2">round``(`<span class="syntax-KEYWORD3">dbms_random`.<span class="syntax-KEYWORD2">value``(`<span class="syntax-DIGIT">1`, <span class="syntax-DIGIT">100000000000``)`, <span class="syntax-DIGIT">4``)` <span class="syntax-LITERAL2">&quot;`<span class="syntax-LITERAL2">subNumber2`<span class="syntax-LITERAL2">&quot;`
                `from` dual `connect` `by` `level` `&lt;` <span class="syntax-DIGIT">4``)` crsr
  `from` dual `connect` `by` `level` `&lt;` <span class="syntax-DIGIT">5`
`</pre>

<p>The normal JSON looks like:</p>

<pre>{ "json": [
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
}</pre>

<p>And the compact JSON looks like:</p>

<pre>{ "json": [
    [ "varChar2", "NUM", "CRSR" ],
    [ "AXTRVAPeSvEb", 43237.6318831,
      [ [ "subField1", "subNumber2" ],
        [ "ElfrRjwTgh", 90999917723.145 ],
        [ "OCHDtvWXdG", 63444436634.8586 ],
        [ "FNNwfrESep", 2308724396.9671 ]
      ]
    ],
    [ "gwJZgItHYbsD", 30981.9794112,
      [ [ "subField1", "subNumber2" ],
        [ "hwzeZKMdSx", 133901885.8896 ],
        [ "gPFBAFWKTO", 18405286462.1886 ],
        [ "ShKjVCaIhO", 83805533569.5954 ]
      ]
    ],
    [ "ZnlLyWTBBABy", 84937.3157598,
      [ [ "subField1", "subNumber2" ],
        [ "OhhOGYpVdm", 93433700854.0266 ],
        [ "LOOBBBYhnI", 67318870030.6331 ],
        [ "rfVgATtrKM", 64340538077.558 ]
      ]
    ],
    [ "AHHnAvixMTaX", 46866.7575258,
      [ [ "subField1", "subNumber2" ],
        [ "NeMZpazxQZ", 45895664191.2099 ],
        [ "gjMktjORQG", 43920800115.6553 ],
        [ "jOhiAQzhKA", 51185780635.0626 ]
      ]
    ]
  ]
}</pre>

<p>We will leave it as an exercise to the reader to try objects and nested tables. However, since objects and nested tables cannot easily be "compacted", they are always presented as "normal".</p>

<p>Lastly, we have constructors and converters:</p>

<p>Constructors:</p>

<pre>`  `function` createObject    `return` pljsonObject;
  `function` createArray     `return` pljsonArray;
  `function` createNull      `return` pljsonNull;

  `function` createString  `(` val `in` `varchar2` `)` `return` pljsonString;
  `function` createNumber  `(` val `in` `number` `)`   `return` pljsonNumber;
  `function` createBoolean `(` val `in` `boolean` `)`  `return` pljsonBoolean;
`</pre>

<p>These should be self-explanitory. In general, you should not change the value of a primitive after it has been created. Instead, simply construct a new primitive.</p>

<p>After creating an Object or an Array, you add members to the object, and add elements to the array using the member methods.</p>

<p>Converters:</p>

<pre>`  `function` getObject  `(` e  `in` pljsonElement `)` `return` pljsonObject;
  `function` getArray   `(` e  `in` pljsonElement `)` `return` pljsonArray;
  `function` getString  `(` e  `in` pljsonElement `)` `return` `varchar2`;
  `function` getNumber  `(` e  `in` pljsonElement `)` `return` `number`;
  `function` getBoolean `(` e  `in` pljsonElement `)` `return` `boolean`;
`</pre>

<p>These also should be self-explanatory. Note that if you pass an invalid type to a converter, an exception will be thrown.</p>
<a href="#pt0">back to top</a>
<a name="pt5"></a>
<h2>Part 5: Example Code</h2>

<p>The following complete script can be run in SQL*Plus. Copy it into a text file and run it in a database that has PLJSON installed. Notice on the Object and Array demos that you can select from the items (tuple or elements). Or in the last example, you can programmatically look for a particular item.</p>

<pre>`column `name` format a40
column val format a60
var rc refcursor
var clb  `clob`
<span class="syntax-KEYWORD2">set` head off

`--`` ``demonstrate`` ``an`` ``object`` ``with`` ``a`` ``bunch`` ``of`` ``string`` ``members`
`declare`
  `object`    pljsonObject;
`begin`

  `object` `:=` pljson.createObject`(``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">aaa`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">is`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">test`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">bbb`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">of`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">the`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">emergency`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">broadcast`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">system`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">ccc`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">is`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">only`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">test`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">ggg`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">if`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">were`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">an`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">actual`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">emergency`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">fff`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">you`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">would`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">have`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">been`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">instructed`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">zzz`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">shouldn`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">t`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">be`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">here`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">eee`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">to`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">put`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">your`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">head`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">between`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">your`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">knees`<span class="syntax-LITERAL1">'``)`;
  `object`.addMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">ddd`<span class="syntax-LITERAL1">'`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">and`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">kiss`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">your`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">a**`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">goodbye`<span class="syntax-LITERAL1">'``)`;

  `--`` ``deletes`` ``have`` ``to`` ``go`` ``like`` ``this`
  `object`.tuple.`delete``(``object`.getIndex`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">zzz`<span class="syntax-LITERAL1">'``)``)`;

  `--`` ``select`` ``member`` ``data`` ``from`` ``the`` ``object`
  `open` :rc `for` `select` p.<span class="syntax-KEYWORD2">value`.getString`(``)` val
               `from` `table``(``object`.tuple`)` p
               `where` p.`name` `in` `(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">ggg`<span class="syntax-LITERAL1">'`,<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">aaa`<span class="syntax-LITERAL1">'``)`;

  `--`` ``make`` ``the`` ``JSON`
  :clb `:=` pljson.makeJson`(``object`, `true``)`;

`end`;
`/`

print rc

`select` :clb `from` dual;


`--`` ``demonstrate`` ``an`` ``array`` ``of`` ``string`` ``elements`
`declare`
  `vArray` pljsonArray;
`begin`
  `vArray` `:=` pljson.createArray`(``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">is`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">test`<span class="syntax-LITERAL1">'``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">of`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">the`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">emergency`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">broadcast`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">system`<span class="syntax-LITERAL1">'``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">is`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">only`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">a`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">test`<span class="syntax-LITERAL1">'``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">had`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">this`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">been`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">an`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">actual`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">emergency`<span class="syntax-LITERAL1">'``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">you`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">would`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">have`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">been`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">instructed`<span class="syntax-LITERAL1">'``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">to`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">put`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">your`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">head`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">between`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">your`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">knees`<span class="syntax-LITERAL1">'``)`;
  `vArray`.addElement`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">and`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">kiss`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">your`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">a**`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">goodbye`<span class="syntax-LITERAL1">'``)`;

  :clb `:=` pljson.makeJson`(``vArray`, `true``)`;

  `open` :rc `for` `select` <span class="syntax-KEYWORD2">value``(`p`)`.getString`(``)` val `from` `table``(``vArray`.elements`)` p;

`end`;
`/`

print rc

`select` :clb `from` dual;

var json `varchar2``(`<span class="syntax-DIGIT">4000``)`
`begin`
  :json `:=` <span class="syntax-LITERAL1">q'!`
<span class="syntax-LITERAL1">{&quot;web-app&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{&quot;servlet&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">[{&quot;servlet-name&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxCDS&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-class&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.cds.CDSServlet&quot;,&quot;init-param&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;configGlossary:installationAt&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;Philadelphia,`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">PA&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;configGlossary:adminEmail&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;ksm@pobox.com&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;configGlossary:poweredBy&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;Cofax&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;configGlossary:poweredByIcon&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/images/cofax.gif&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;configGlossary:staticPath&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/content/static&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;templateProcessorClass&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.WysiwygTemplate&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;templateLoaderClass&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.FilesTemplateLoader&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;templatePath&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;templates&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;templateOverridePath&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;defaultListTemplate&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;listTemplate.htm&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;defaultFileTemplate&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;articleTemplate.htm&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;useJSP&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">false,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;jspListTemplate&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;listTemplate.jsp&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;jspFileTemplate&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;articleTemplate.jsp&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePackageTagsTrack&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">200,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePackageTagsStore&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">200,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePackageTagsRefresh&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">60,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cacheTemplatesTrack&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">100,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cacheTemplatesStore&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">50,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cacheTemplatesRefresh&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">15,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePagesTrack&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">200,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePagesStore&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">100,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePagesRefresh&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">10,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cachePagesDirtyRead&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">10,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;searchEngineListTemplate&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;forSearchEnginesList.htm&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;searchEngineFileTemplate&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;forSearchEngines.htm&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;searchEngineRobotsDb&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;WEB-INF/robots.db&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;useDataStore&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">true,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreClass&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.SqlDataStore&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;redirectionClass&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.SqlRedirection&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreName&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofax&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreDriver&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;com.microsoft.jdbc.sqlserver.SQLServerDriver&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreUrl&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreUser&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;sa&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStorePassword&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreTestQuery&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreTestQuery&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;SET`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">NOCOUNT`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">ON;select`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">test='test';&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreLogFile&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/usr/local/tomcat/logs/datastore.log&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreInitConns&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">10,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreMaxConns&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">100,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreConnUsageLimit&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">100,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataStoreLogLevel&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;debug&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;maxUrlLength&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">500}},{&quot;servlet-name&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxEmail&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-class&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.cds.EmailServlet&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;init-param&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{&quot;mailHost&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;mail1&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;mailHostOverride&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;mail2&quot;}},{&quot;servlet-name&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxAdmin&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-class&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.cds.AdminServlet&quot;},{&quot;servlet-name&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;fileServlet&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-class&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.cds.FileServlet&quot;},`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-name&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxTools&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-class&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;org.cofax.cms.CofaxToolsServlet&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;init-param&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;templatePath&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;toolstemplates/&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;log&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">1,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;logLocation&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/usr/local/tomcat/logs/CofaxTools.log&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;logMaxSize&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataLog&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">1,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataLogLocation&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/usr/local/tomcat/logs/dataLog.log&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;dataLogMaxSize&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;removePageCache&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/content/admin/remove?cache=pages&amp;id=&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;removeTemplateCache&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/content/admin/remove?cache=templates&amp;id=&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;fileTransferFolder&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/usr/local/tomcat/webapps/content/fileTransferFolder&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;lookInContext&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">1,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;adminGroupID&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">4,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;betaServer&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">true}}],`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;servlet-mapping&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxCDS&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxEmail&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/cofaxutil/aemail/*&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxAdmin&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/admin/*&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;fileServlet&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/static/*&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofaxTools&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/tools/*&quot;},`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;taglib&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">{`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;taglib-uri&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;cofax.tld&quot;,`
<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;taglib-location&quot;:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">&quot;/WEB-INF/tlds/cofax.tld&quot;}}}`<span class="syntax-LITERAL1">!'`;
`end`;
`/`

`--`` ``demonstrate`` ``parsing`` ``and`` ``traversing`` ``a`` ``JSON`` ``tree`
`declare`
  root   pljsonElement;

  t1 `timestamp`;
  t2 `timestamp`;

  `--`` ``forward`` ``declarations`
  `procedure` processElement`(`e pljsonElement, lvl `binary_integer``)`;
  `procedure` parseObject`(`o pljsonObject, lvl `binary_integer``)`;
  `procedure` parseArray`(``a` pljsonArray, lvl `binary_integer``)`;

  `--`` ``helper`
  `procedure` doOutput `(`o `varchar2`, lvl `binary_integer``)`
  `is`
  `begin`
    <span class="syntax-KEYWORD3">dbms_output`.put_line`(`<span class="syntax-KEYWORD2">lpad``(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`o, <span class="syntax-KEYWORD2">length``(`o`)``+`lvl`+`<span class="syntax-DIGIT">2`, <span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">-`<span class="syntax-LITERAL1">'``)``)`;
  `end` doOutput;

  `--`` ``an`` ``object`` ``contains`` ``a`` ``&quot;tuple&quot;,`` ``which`` ``is`` ``a`` ``pljsonObjectEntries`` ``nested`` ``table`
  `--`` ``each`` ``element`` ``in`` ``the`` ``tuple`` ``is`` ``a`` ``pljsonObjectEntry`` ``object,`` ``which`` ``is`` ``a`` ``name/value`` ``pair`
  `--`` ``the`` ``name`` ``is`` ``a`` ``string,`` ``the`` ``value`` ``is`` ``a`` ``pljsonElement`` ``object`
  `procedure` parseObject`(`o pljsonObject, lvl `binary_integer``)`
  `is`
    i   `binary_integer`;
    oe  pljsonObjectEntry;
  `begin`
    doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">OBJECT`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">START`<span class="syntax-LITERAL1">'`, lvl`)`;

    `--`` ``demonstrate`` ``looking`` ``for`` ``a`` ``particular`` ``member`` ``of`` ``an`` ``object`
    `declare`
      v1  pljsonElement;
    `begin`
      v1 `:=` o.getMember`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">jspFileTemplate`<span class="syntax-LITERAL1">'``)`;
      `if` v1 `is` `not` `null` `then`
        <span class="syntax-KEYWORD3">dbms_output`.put_line`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">****`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">FOUND`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">IT`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">****`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`v1.getString`(``)``)`;
      `end` `if`;
    `end`;

    `--`` ``demonstrate`` ``traversing`` ``the`` ``members`` ``of`` ``an`` ``object`
    i `:=` o.tuple.<span class="syntax-KEYWORD2">first`;
    `while` i `is` `not` `null`
    `loop`
      oe `:=` o.tuple`(`i`)`;
      doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">object`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">entry:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`oe.`name`, lvl`)`;
      processElement`(`oe.<span class="syntax-KEYWORD2">value`, lvl`+`<span class="syntax-DIGIT">1``)`;
      i `:=` o.tuple.next`(`i`)`;
    `end` `loop`;

    doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">OBJECT`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">END`<span class="syntax-LITERAL1">'`, lvl`)`;
  `end` parseObject;

  `--`` ``an`` ``array`` ``contains`` ``elements`` ``which`` ``is`` ``a`` ``pljsonElements`` ``nested`` ``table`
  `--`` ``each`` ``element`` ``in`` ``the`` ``array`` ``is`` ``a`` ``pljsonElement`` ``object`
  `procedure` parseArray`(``a` pljsonArray, lvl `binary_integer``)`
  `is`
    i `binary_integer`;
  `begin`
    `--`` ``demonstrate`` ``traversing`` ``the`` ``elements`` ``of`` ``an`` ``array`
    doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">ARRAY`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">START`<span class="syntax-LITERAL1">'`, lvl`)`;
    i `:=` `a`.elements.<span class="syntax-KEYWORD2">first`;
    `while` i `is` `not` `null`
    `loop`
      processElement`(``a`.elements`(`i`)`, lvl`+`<span class="syntax-DIGIT">1``)`;
      i `:=` `a`.elements.next`(`i`)`;
    `end` `loop`;
    doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">ARRAY`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">END`<span class="syntax-LITERAL1">'`, lvl`)`;
  `end` parseArray;

  `procedure` processElement`(`e pljsonElement, lvl `binary_integer``)`
  `is`
  `begin`
    `case` `when` e.isNull      `then` doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">NULL`<span class="syntax-LITERAL1">'`, lvl`)`;
         `when` e.isPrimitive `then` doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">primitive:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`e.getString`(``)`, lvl`)`;
         `when` e.isObject    `then` parseObject`(`pljson.getObject`(`e`)`, lvl`)`;
         `when` e.isArray     `then` parseArray`(`pljson.getArray`(`e`)`, lvl`)`;
    `end` `case`;
 `end`;

`begin`
  t1 `:=` <span class="syntax-KEYWORD2">systimestamp`;
  root `:=` pljson.parseJson`(`:json`)`;
  t2 `:=` <span class="syntax-KEYWORD2">systimestamp`;

  doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">time`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">to`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">parse:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`<span class="syntax-KEYWORD2">to_char``(`t2`-`t1`)`, <span class="syntax-DIGIT">0``)`;

  t1 `:=` <span class="syntax-KEYWORD2">systimestamp`;
  processElement`(`root, <span class="syntax-DIGIT">0``)`;
  t2 `:=` <span class="syntax-KEYWORD2">systimestamp`;

  doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">time`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">to`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">process:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`<span class="syntax-KEYWORD2">to_char``(`t2`-`t1`)`, <span class="syntax-DIGIT">0``)`;

  t1 `:=` <span class="syntax-KEYWORD2">systimestamp`;
  :clb `:=` pljson.makeJson`(`root, `false``)`;
  t2 `:=` <span class="syntax-KEYWORD2">systimestamp`;

  doOutput`(`<span class="syntax-LITERAL1">'`<span class="syntax-LITERAL1">time`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">to`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">stream:`<span class="syntax-LITERAL1"> `<span class="syntax-LITERAL1">'``||`<span class="syntax-KEYWORD2">to_char``(`t2`-`t1`)`, <span class="syntax-DIGIT">0``)`;
`end`;
`/`

`select` :clb `from` dual;

`exit`

`</pre>

<a href="#pt0">back to top</a>

</div></div></body>
</html>
