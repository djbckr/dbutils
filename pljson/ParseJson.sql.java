create or replace java source named "ParseJson" as
package net.rubywillow;

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

import java.io.Reader;
import java.sql.Array;
import java.sql.Clob;
import java.sql.Struct;
import java.util.Map.Entry;
import java.util.Set;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonNull;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonPrimitive;

public class ParseJson
{

  ////////////////////////////////////////////////////////////////////////////////
  ////    parseJson :: from a JSON string to a tree of Oracle Objects    /////////
  ////////////////////////////////////////////////////////////////////////////////

  // parse a JSON string into an object tree, and return
  // the tree as a tree of psonElement
  public static Struct parseJson( Clob json, String[] err ) {
    Struct rslt = null;
    err[0] = null;
    Reader reader = null;
    try {
      reader = json.getCharacterStream();
      // the easy part; get GSON to parse the string
      JsonElement j = new JsonParser().parse(reader);

      // the hard part: recursively walk the tree
      // and return the Oracle type structures
      rslt = processElement(j);
    }
    catch ( Exception e ) {
      String s = Utility.fmtError(e);
      err[0] = s;
    }
    return rslt;
  }

  // called recursively for each JSON type
  private static Struct processElement( JsonElement j ) throws Exception {
    if ( j.isJsonNull() )
      return processNull((JsonNull) j);
    else if ( j.isJsonPrimitive() )
      return processPrimitive((JsonPrimitive) j);
    else if ( j.isJsonObject() )
      return processObject((JsonObject) j);
    else if ( j.isJsonArray() )
      return processArray((JsonArray) j);
    else {
      Utility.doOutput("processElement() error!");
      return null;
    }
  }

  // processArray()
  private static Struct processArray( JsonArray j ) throws Exception {

    // build the array of elements first
    Struct[] elementTbl = new Struct[j.size()];
    for ( int z = 0; z < j.size(); z++ ) {
      JsonElement e = j.get(z);
      elementTbl[z] = processElement(e); // recursive call
    }

    // construct the Array object to be used in psonArray
    Array tuple = null;
    tuple = new ARRAY(ArrayDescriptor.createDescriptor(PLJSON.psonElements, Utility.getConn()), Utility.getConn(), elementTbl);

    // construct the psonArray object
    Object[] z = new Object[2];
    z[0] = PLJSON.cArray;
    z[1] = tuple;
    return makeStruct(z, PLJSON.psonArray);
  }

  // processObject()
  private static Struct processObject( JsonObject j ) throws Exception {
    // an object is a set (array) of name/value pairs;
    // the name is a string, the value is an element
    Set<Entry<String, JsonElement>> entrySet = j.entrySet();

    // build the array of name/value pairs
    int i = 0;
    Struct[] objectEntryTbl = new Struct[entrySet.size()];
    for ( Entry<String, JsonElement> entry : entrySet ) {
      // construct the psonObjectEntry object...
      Object[] o = new Object[2];
      o[0] = entry.getKey();
      o[1] = processElement(entry.getValue());
      // and put it in the array
      objectEntryTbl[i++] = makeStruct(o, PLJSON.psonObjectEntry);
    }

    // construct the Array object to be used in psonObject
    Array tuple = null;
    tuple = new ARRAY(ArrayDescriptor.createDescriptor(PLJSON.psonObjectEntries, Utility.getConn()), Utility.getConn(), objectEntryTbl);

    // construct the psonObject object
    Object[] z = new Object[2];
    z[0] = PLJSON.cObject;
    z[1] = tuple;
    return makeStruct(z, PLJSON.psonObject);
  }

  // processPrimitive()
  private static Struct processPrimitive( JsonPrimitive j ) throws Exception {
    if ( j.isString() )
      return processString(j);
    else if ( j.isNumber() )
      return processNumber(j);
    else if ( j.isBoolean() )
      return processBoolean(j);
    else {
      Utility.doOutput("processPrimitive() error!");
      return null;
    }
  }

  // processBoolean()
  private static Struct processBoolean( JsonPrimitive j ) throws Exception {
    // since you can't have a SQL type with an actual boolean
    // value in Oracle, it has to be something else. We're
    // using a VARCHAR2(1) with a "*" to indicate TRUE and
    // " " to indicate FALSE
    Object[] o = new Object[2];
    o[0] = PLJSON.cBoolean;
    o[1] = j.getAsBoolean() ? "*" : " ";
    return makeStruct(o, PLJSON.psonBoolean);
  }

  // processNumber()
  private static Struct processNumber( JsonPrimitive j ) throws Exception {
    Object[] o = new Object[2];
    o[0] = PLJSON.cNumber;
    o[1] = j.getAsBigDecimal();
    return makeStruct(o, PLJSON.psonNumber);
  }

  // processString()
  private static Struct processString( JsonPrimitive j ) throws Exception {
    Object[] o = new Object[2];
    o[0] = PLJSON.cString;
    o[1] = j.getAsString();
    return makeStruct(o, PLJSON.psonString);
  }

  // processNull()
  private static Struct processNull( JsonNull j ) throws Exception {
    Object[] o = new Object[1];
    o[0] = PLJSON.cNull;
    return makeStruct(o, PLJSON.psonNull);
  }

  // now that we have the array of objects and a type name, we can
  // build the Oracle SQLType object...
  private static Struct makeStruct( Object[] o, String strctName ) throws Exception {
    return new STRUCT(StructDescriptor.createDescriptor(strctName, Utility.getConn()), Utility.getConn(), o);
  }

}
/
