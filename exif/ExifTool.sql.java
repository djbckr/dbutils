-- // note, this is really a SQL file with a .java extension.
create or replace and compile java source named "ExifTool" as
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
import java.sql.Array;
import java.util.ArrayList;
import java.sql.Connection;

import oracle.sql.*;

public class ExifTool {

  static final int BUFF_SIZE = 8192; // manage in 8KB chunks

  private static ArrayList<String> intExifTool(
        BLOB media,
        String execFile ) throws Exception
  {
      // make command list
      ArrayList<String> lst = new ArrayList<String>();

      if (execFile == null || execFile.equals(""))
        throw new Exception("The ExecFile is empty!");

      lst.add(execFile);
      lst.add("-t");
      lst.add("-");

      // create the input stream from the media
      InputStream instream = media.getBinaryStream(1L);

      // build the process
      ProcessBuilder builder = new ProcessBuilder(lst);
      builder.redirectErrorStream(true);
      Process proc = builder.start();

      // get the input/output streams and pass the media into the process
      OutputStream outstream = proc.getOutputStream();
      BufferedReader stdout = new BufferedReader(new InputStreamReader(proc.getInputStream()));
      copyStream(instream, outstream);

      // get the output of the process
      String line = null;
      lst.clear();
      while ((line = stdout.readLine()) != null) {
        lst.add(line);
      }

      // wait for the process to end
      proc.waitFor();
      return lst;
  }

  public static void exiftoolraw(
        BLOB media,
        String execFile,
        String[] output,
        String[] err )
  {
    try {
      ArrayList<String> lst = intExifTool(media, execFile);
      StringBuilder rslt = new StringBuilder();
      for (String str : lst) {
        rslt.append(str);
        rslt.append("\n");
      }
      output[0] = rslt.toString();
    } catch (Exception e) {
      err[0] = Utility.fmtError(e);
    }
  }

  public static void exiftool(
        BLOB media,
        String execFile,
        Array[] names,
        Array[] values,
        String[] err )
  {
    try {
      ArrayList<String> lst = intExifTool(media, execFile);
      // parse the output
      ArrayList<String> vNames = new ArrayList<String>(lst.size());
      ArrayList<String> vValues = new ArrayList<String>(lst.size());
      for (String str : lst) {
        parseLine(str, vNames, vValues);
      }

      Connection conn = Utility.getConn();

      names[0] = new ARRAY(ArrayDescriptor.createDescriptor("STRARRAY", conn), conn, vNames.toArray());
      values[0] = new ARRAY(ArrayDescriptor.createDescriptor("STRARRAY", conn), conn, vValues.toArray());

    } catch (Exception e) {
      err[0] = Utility.fmtError(e);
    }
  }

  private static void parseLine(
        String str,
        ArrayList<String> vNames,
        ArrayList<String> vValues )
  {
    int indx = str.indexOf( "\t" );
    String sName;
    String sValue;
    if (indx > -1) {
      vNames.add(str.substring( 0, indx ));
      vValues.add(str.substring( indx+1 ));
    } else {
      vNames.add(str.trim());
      vValues.add("");
    }
  }

  private static void copyStream( InputStream input, OutputStream output ) {
    byte[] buffer = new byte[BUFF_SIZE];
    int bytesRead;
    try {
      while ( ( bytesRead = input.read( buffer ) ) != -1 ) {
        output.write( buffer, 0, bytesRead );
      }
      output.flush();
      output.close();
      input.close();
    } catch ( java.io.IOException e ) {
      // do nothing, this is a normal thing for exiftool
      try {
        input.close();
      } catch ( java.io.IOException x ) {}
    }
  }

}
/
