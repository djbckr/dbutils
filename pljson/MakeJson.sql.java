create or replace java source named "MakeJson" as
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

import java.io.Writer;
import java.math.BigDecimal;
import java.sql.Array;
import java.sql.Clob;
import java.sql.ResultSet;
import java.sql.Struct;

import oracle.sql.CLOB;

import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonNull;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

public class MakeJson {
  // //////////////////////////////////////////////////////////////////////////////
  // // makeJson :: from a tree of Oracle Objects to a JSON string //////////
  // //////////////////////////////////////////////////////////////////////////////
  public static Clob makeJson(Struct pson, int pretty, String[] err) {
    Clob rslt = null;
    err[0] = null;

    try {
      JsonElement element;
      // the hard part: recursively traverse the Oracle Type
      // tree and create a GSON equivalent tree.
      element = parseElement(pson);

      // the easy part: have GSON serialize its tree
      rslt = doSerialize(element, pretty != 0);
    } catch (Exception e) {
      err[0] = Utility.fmtError(e);
    }
    return rslt;
  }

  // called recursively for each JSON type
  private static JsonElement parseElement(Struct pson) throws Exception {
    String objTyp = pson.getSQLTypeName();
    // we are parsing based on the SQL Type Name; since it is returned
    // "fully qualified", we have to check .endsWith()
    if (objTyp.endsWith(PLJSON.psonString))
      return parseString(pson);
    else if (objTyp.endsWith(PLJSON.psonNumber))
      return parseNumber(pson);
    else if (objTyp.endsWith(PLJSON.psonObject))
      return parseObject(pson);
    else if (objTyp.endsWith(PLJSON.psonArray))
      return parseArray(pson);
    else if (objTyp.endsWith(PLJSON.psonNull))
      return parseNull(pson);
    else if (objTyp.endsWith(PLJSON.psonBoolean))
      return parseBoolean(pson);
    else {
      Utility.doOutput("failure to parse element: '" + objTyp + "'");
      return null;
    }
  }

  private static JsonElement parseString(Struct s) throws Exception {
    String val = (String) s.getAttributes()[1];
    if (val == null) {
      val = "";
    }
    return new JsonPrimitive(val);
  }

  private static JsonElement parseNumber(Struct n) throws Exception {
    BigDecimal val = (BigDecimal) n.getAttributes()[1];
    if (val == null)
      return JsonNull.INSTANCE;
    return new JsonPrimitive(val);
  }

  private static JsonElement parseBoolean(Struct b) throws Exception {
    String val = (String) b.getAttributes()[1];
    return new JsonPrimitive(val != null && val.equals("*"));
  }

  private static JsonElement parseNull(Struct n) throws Exception {
    return JsonNull.INSTANCE;
  }

  private static JsonElement parseArray(Struct a) throws Exception {
    Array val = (Array) a.getAttributes()[1];
    ResultSet rs = val.getResultSet();
    JsonArray ja = new JsonArray();
    while (rs.next()) {
      // the second position in the result set is a psonElement
      // recursively parse that element
      ja.add(parseElement((Struct) rs.getObject(2)));
    }
    return ja;
  }

  private static JsonElement parseObject(Struct o) throws Exception {
    Array val = (Array) o.getAttributes()[1];
    ResultSet rs = val.getResultSet();
    JsonObject jo = new JsonObject();
    while (rs.next()) {
      // the second position in the result set is a psonObjectEntry
      Struct entry = (Struct) rs.getObject(2);

      // psonObjectEntry contains two items: a string, and a psonElement
      String name = (String) entry.getAttributes()[0];
      Struct value = (Struct) entry.getAttributes()[1];
      // recursively parse that element
      jo.add(name, parseElement(value));
    }
    return jo;
  }

  // convert the GSON objects to a string
  protected static Clob doSerialize(JsonElement element, boolean pretty)
      throws Exception {

    if (element == null)
      return null;

    Clob clob = CLOB.createTemporary(Utility.getConn(), true, CLOB.DURATION_SESSION);

    Writer writer;
    writer = clob.setCharacterStream(1);

    GsonBuilder gb = new GsonBuilder();

    gb.serializeNulls();

    if (pretty) {
      gb.setPrettyPrinting();
    }

    gb.create().toJson(element, writer);

    writer.flush();
    writer.close();

    return clob;
  }

}
/
