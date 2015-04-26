create or replace java source named "RefCursorToJson" as
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

import java.io.BufferedWriter;
import java.math.BigDecimal;
import java.sql.Clob;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.GregorianCalendar;

import oracle.jdbc.OracleResultSet;
import oracle.sql.ANYDATA;
import oracle.sql.ARRAY;
import oracle.sql.CLOB;
import oracle.sql.Datum;
import oracle.sql.STRUCT;

import com.google.gson.stream.JsonWriter;

public class RefCursorToJson {

  private static JsonWriter out;
  private static final char[] hexArray = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

  /*
   * This method streams the result-set directly to a CLOB, but uses the nicely
   * written GSON library to do it, doing proper escapes and what-not. It uses
   * rather little memory and is pretty fast all in all.
   */

  public static Clob refCursorToJson(ResultSet rsltSet, String rtName, int compact, int pretty, String dateFormat, String[] err) {

    Clob rslt = null;

    try {

      rslt = CLOB.createTemporary(Utility.getConn(), true, CLOB.DURATION_SESSION);

      SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
      out = new JsonWriter(new BufferedWriter(rslt.setCharacterStream(1)));

      // set behaviors
      out.setHtmlSafe(true);
      out.setLenient(false);
      out.setSerializeNulls(true);
      if (pretty != 0)
        out.setIndent("  ");

      // start output
      out.beginObject();
      out.name(rtName);
      processResultSet((OracleResultSet) rsltSet, compact, sdf);
      out.endObject();

      // wrap it up
      out.flush();
      out.close();

    } catch (Exception e) {
      String s = Utility.fmtError(e);
      Utility.doOutput(s);
      err[0] = s;
    }
    return rslt;
  }

  private static void processResultSet(OracleResultSet rsltSet, int compact, SimpleDateFormat sdf) throws Exception {

    ResultSetMetaData md = rsltSet.getMetaData();
    String[] cols = new String[md.getColumnCount()];
    for (int i = 0; i < cols.length; i++) {
      cols[i] = md.getColumnLabel(i + 1);
    }

    out.beginArray(); // outer array open

    // if compact, make an array of column names
    if (compact != 0) {
      out.beginArray();
      for (int i = 0; i < cols.length; i++)
        out.value(cols[i]);
      out.endArray();
    }

    while (rsltSet.next()) {

      // if normal, make an object, else make an array
      if (compact == 0)
        out.beginObject();
      else
        out.beginArray();

      for (int i = 0, j = 1; i < cols.length; i++, j++) {

        // if normal, assign member name
        if (compact == 0)
          out.name(cols[i]);

        // this writes a value, be it a primitive, or complex type
        processObject(rsltSet.getObject(j), compact, sdf);

      }

      // if normal, close object, else close array
      if (compact == 0)
        out.endObject();
      else
        out.endArray();

    }
    out.endArray(); // outer array close
  }

  private static void processObject(Object obj, int compact, SimpleDateFormat sdf) throws Exception {
    if (obj == null) out.nullValue();
    else if (obj instanceof java.lang.String)         out.value((String) obj);
    else if (obj instanceof java.math.BigDecimal)     out.value((BigDecimal) obj);
    else if (obj instanceof oracle.sql.CHAR)          out.value(((oracle.sql.CHAR) obj).stringValue());
    else if (obj instanceof oracle.sql.DATE)          out.value(sdf.format(((oracle.sql.DATE) obj).timestampValue()));
    else if (obj instanceof oracle.sql.NUMBER)        out.value(((oracle.sql.NUMBER) obj).bigDecimalValue());
    else if (obj instanceof java.lang.Float)          out.value(new BigDecimal((Float) obj));
    else if (obj instanceof java.lang.Double)         out.value(new BigDecimal((Double) obj));
    else if (obj instanceof java.sql.Timestamp)       out.value(sdf.format((Timestamp) obj));
    else if (obj instanceof oracle.sql.TIMESTAMP)     out.value(sdf.format(((oracle.sql.TIMESTAMP) obj).timestampValue()));
    else if (obj instanceof oracle.sql.TIMESTAMPTZ)   out.value(sdf.format(((oracle.sql.TIMESTAMPTZ) obj).timestampValue(Utility.getConn())));
    else if (obj instanceof oracle.sql.TIMESTAMPLTZ)  out.value(sdf.format(((oracle.sql.TIMESTAMPLTZ) obj).timestampValue(Utility.getConn(), new GregorianCalendar())));
    else if (obj instanceof oracle.sql.INTERVALYM)    out.value(((oracle.sql.INTERVALYM) obj).stringValue());
    else if (obj instanceof oracle.sql.INTERVALDS)    out.value(((oracle.sql.INTERVALDS) obj).stringValue());
    else if (obj instanceof oracle.sql.CLOB)          out.value(((oracle.sql.CLOB) obj).stringValue());
    else if (obj instanceof oracle.sql.NCLOB)         out.value(((oracle.sql.NCLOB) obj).stringValue());
    else if (obj instanceof oracle.sql.RAW)           out.value(bytesToHex(((oracle.sql.RAW) obj).getBytes()));
    else if (obj instanceof byte[])                   out.value(bytesToHex((byte[]) obj));
    else if (obj instanceof oracle.sql.STRUCT)        processSQLObject((oracle.sql.STRUCT) obj, compact, sdf);
    else if (obj instanceof oracle.sql.ARRAY)         processArray((oracle.sql.ARRAY) obj, compact, sdf);
    else if (obj instanceof ResultSet)                processResultSet((oracle.jdbc.OracleResultSet) obj, compact, sdf);
    else if (obj instanceof oracle.sql.ANYDATA)       processObject(((ANYDATA) obj).accessDatum(), compact, sdf);
    else if (obj instanceof oracle.sql.BINARY_DOUBLE) out.value(((oracle.sql.BINARY_DOUBLE) obj).bigDecimalValue());
    else if (obj instanceof oracle.sql.BINARY_FLOAT)  out.value(((oracle.sql.BINARY_FLOAT) obj).bigDecimalValue());
    else if (obj instanceof oracle.sql.OPAQUE)        processObject(new ANYDATA((oracle.sql.OPAQUE) obj).accessDatum(), compact, sdf);
    else throw new SQLException("An unsupported datatype was encountered: " + obj.getClass().getCanonicalName());
  }

  // nested array
  private static void processArray(ARRAY obj, int compact, SimpleDateFormat sdf) throws Exception {

    // An array is just a result set. The first column is just an index number,
    // the second column is the actual content we want
    OracleResultSet rs = (OracleResultSet) obj.getResultSet();

    out.beginArray();
    while (rs.next()) {
      processObject(rs.getOracleObject(2), compact, sdf);
    }
    out.endArray();

  }

  // nested object
  private static void processSQLObject(STRUCT obj, int compact, SimpleDateFormat sdf) throws Exception {

    // get information about the object
    ResultSetMetaData smd = obj.getDescriptor().getMetaData();
    if (smd == null)
      throw new SQLException("ResultSetMetaData on Object is NULL!");

    // get the object members
    Datum[] objData = obj.getOracleAttributes();

    // sanity check
    if (smd.getColumnCount() != objData.length)
      throw new SQLException("got a problem with the object metadata");

    // do output
    out.beginObject();
    for (int i = 0; i < objData.length; i++) {
      out.name(smd.getColumnName(i + 1));
      processObject(objData[i], compact, sdf);
    }
    out.endObject();
  }

  // take binary data and make it hexadecimal
  private static String bytesToHex(byte[] raw) {
    char[] hexChars = new char[raw.length * 2];
    int v;
    for (int j = 0; j < raw.length; j++) {
      v = raw[j] & 0x000000FF;
      hexChars[j << 1] = hexArray[v >>> 4];
      hexChars[(j << 1) + 1] = hexArray[v & 0x0000000F];
    }
    return new String(hexChars);
  }

}
/
