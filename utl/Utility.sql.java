-- // note, this is really a SQL file with a .java extension.
create or replace and compile java source named "Utility" as
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
import java.io.*;
import java.math.BigDecimal;
import java.sql.Array;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.util.UUID;
import java.util.ArrayList;

import oracle.sql.*;

public class Utility {

  private static PreparedStatement dbmsout;

  public static void splitString (
        String      strToSplit,
        String      delimiter,
        String      returnType,
        BigDecimal  trim,
        Array[]     rslt,
        String[]    err )
  {
    try {

      if (strToSplit == null || strToSplit.length() == 0 || delimiter == null
          || delimiter.length() == 0)
        return;

      Object[] strArray = strToSplit.split(delimiter);

      if (trim.intValue() != 0) {
        ArrayList<String> arr = new ArrayList<String>(strArray.length);

        for (String str : (String[]) strArray) {

          if (str == null)
            continue;

          String fin = str.trim();

          if (fin.length() == 0)
            continue;

          arr.add(fin);
        }

        strArray = arr.toArray();
      }

      Connection conn = getConn();

      rslt[0] = new ARRAY(ArrayDescriptor.createDescriptor(returnType, conn), conn, strArray);

    } catch (Exception e) {
      err[0] = fmtError(e);
    }
  }

  public static String randomGuid() {
    return UUID.randomUUID().toString().toUpperCase().replaceAll("-", "");
  }

  protected static String fmtError(Exception e) {
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    e.printStackTrace(pw);
    pw.flush();
    pw.close();
    sw.flush();
    return e.getMessage() + "\n" + sw.toString();
  }

  protected static Connection getConn() throws Exception {
    return DriverManager.getConnection("jdbc:default:connection:");
  }

  protected static void doOutput( String stat ) {
    try {
      if ( dbmsout == null ) {
        dbmsout = getConn().prepareStatement("begin dbms_output.put_line(:v); end;");
      }
      dbmsout.setString(1, stat);
      dbmsout.execute();
    }
    catch ( Exception e ) {
      // hope this doesn't happen, but if it does, just let it be
    }
  }

}
/
