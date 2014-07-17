-- // note, this is really a SQL file with a .java extension.
create or replace and compile java source named "Zip" as
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
import java.util.ArrayList;
import java.util.zip.*;
import java.sql.Connection;

import oracle.sql.*;

public class Zip {

  static final int BUFF_SIZE = 8192; // manage in 8KB chunks

  public static void zipCompress (
        ARRAY in,
        BLOB[] result,
        String[] err )
  {
    try {
      Connection conn = Utility.getConn();

      // create the LOB we're going to ZIP to
      BLOB rslt = BLOB.createTemporary(conn, false, BLOB.DURATION_CALL);

      // make a buffered output stream to write to the LOB
      ZipOutputStream outputstream = new ZipOutputStream(new BufferedOutputStream(rslt.setBinaryStream(1L)));
      outputstream.setLevel(Deflater.BEST_COMPRESSION);

      // initialize a buffer
      byte[] buffer = new byte[BUFF_SIZE];

      // convert the input array to an array of oracle.sql.STRUCT
      Datum[] ZipTyp = ((ARRAY)in).getOracleArray();

      // for each element being sent to us...
      for (int i = 0; i < java.lang.reflect.Array.getLength(ZipTyp); i++)
      {
        // get the attributes of the ZIP_TAB object
        Datum[] attrs = ((STRUCT)ZipTyp[i]).getOracleAttributes();

        // the [1] element is the LOB locator... transform into a buffered input stream
        BLOB b = (BLOB)attrs[1];
        BufferedInputStream inputstream = new BufferedInputStream(b.getBinaryStream(1L));

        // put the entry in the Zip file (the [0] element is the file name)
        ZipEntry ze = new ZipEntry(((CHAR)attrs[0]).stringValue());
        ze.setSize(b.length()); // I'm not sure this does anything useful
        outputstream.putNextEntry(ze);

        // copy the LOB into the Zip file
        int bytesRead;
        do
        {
          bytesRead = inputstream.read(buffer, 0, BUFF_SIZE);
          if (bytesRead > 0)
            outputstream.write(buffer, 0, bytesRead);
        } while (bytesRead == BUFF_SIZE);
        inputstream.close();
        outputstream.closeEntry();

      }
      // flush and close the Zip file
      outputstream.flush();
      outputstream.close();

      // return the finished product
      result[0] = rslt;
    } catch (Exception e) {
      err[0] = Utility.fmtError(e);
    }
  }

  // extract the LOB (as a zip file) into a ZIP_TAB object
  public static void zipExtract (
        BLOB in,
        ARRAY[] result,
        String[] err )
  {
    try {
      Connection conn = Utility.getConn();

      InputStream x = in.getBinaryStream(1L);

      // our inputstream is being read from the input LOB
      ZipInputStream inputstream = new ZipInputStream(new BufferedInputStream(x));

      // initialize a buffer
      byte[] buffer = new byte[BUFF_SIZE];

      // we need a descriptor object for ZIP_TYP so we can create the objects in java
      StructDescriptor structdesc = StructDescriptor.createDescriptor("ZIP_TYPE", conn);

      // this is our variable Array
      ArrayList<STRUCT> vArray = new ArrayList<STRUCT>();

      // loop through the entries in the ZIP file
      ZipEntry ze;
      while ((ze = inputstream.getNextEntry()) != null)
      {

        BLOB b = null;
        BufferedOutputStream outputstream = null;

        int bytesRead = inputstream.read(buffer, 0, BUFF_SIZE);
        while (bytesRead > 0)
        {
          if (b == null)
          {
            b = BLOB.createTemporary(conn, false, BLOB.DURATION_CALL);
            outputstream = new BufferedOutputStream(b.setBinaryStream(1L));
          }
          outputstream.write(buffer, 0, bytesRead);
          bytesRead = inputstream.read(buffer, 0, BUFF_SIZE);
        }

        if (outputstream != null) {
          // close up this LOB and convert to our ZIP_TYP structure
          outputstream.flush();
          outputstream.close();
          Object[] o = {ze.getName(), b};
          vArray.add(new STRUCT(structdesc, conn, o));
        }
      }

      // close up the source LOB
      inputstream.close();

      // put all of our data into the ZIP_TAB array
      ArrayDescriptor adesc = ArrayDescriptor.createDescriptor("ZIP_TABLE", conn);
      result[0] = new ARRAY(adesc, conn, vArray.toArray());
    } catch (Exception e) {
      err[0] = Utility.fmtError(e);
    }
  }

}
/
