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
import java.sql.Array;
import java.sql.Blob;
import java.util.ArrayList;
import java.util.zip.*;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Struct;

public class Zip {

  static final int BUFF_SIZE = 8192; // manage in 8KB chunks

  public static void zipCompress(
          Array in,
          Blob[] result,
          String[] err ) {
    try {
      Connection conn = Utility.getConn();

      // create the LOB we're going to ZIP to
      Blob rslt = conn.createBlob();

      ZipOutputStream outputstream = new ZipOutputStream( new BufferedOutputStream( rslt.setBinaryStream( 1L ) ) );
      try {
        outputstream.setLevel( Deflater.BEST_COMPRESSION );

        // initialize a buffer
        byte[] buffer = new byte[BUFF_SIZE];

        // for each element being sent to us...
        ResultSet rs = in.getResultSet();
        while ( rs.next() ) {
          // get the attributes of the ZIP_TAB object

          // the second element is the LOB locator... transform into a buffered input stream
          Blob b = rs.getBlob( 2 );

          BufferedInputStream inputstream = new BufferedInputStream( b.getBinaryStream() );
          try {
            // put the entry in the Zip file (the first element is the file name)
            ZipEntry ze = new ZipEntry( rs.getString( 1 ) );
            ze.setSize( b.length() ); // I'm not sure this does anything useful
            outputstream.putNextEntry( ze );

            // copy the LOB into the Zip file
            int bytesRead;
            do {
              bytesRead = inputstream.read( buffer, 0, BUFF_SIZE );
              if ( bytesRead > 0 ) {
                outputstream.write( buffer, 0, bytesRead );
              }
            } while ( bytesRead == BUFF_SIZE );
          } finally {
            inputstream.close();
          }

          outputstream.closeEntry();

        }
        // flush and close the Zip file
        outputstream.flush();
      } finally {
        outputstream.close();
      }

      // return the finished product
      result[0] = rslt;
    } catch ( Exception e ) {
      err[0] = Utility.fmtError( e );
    }
  }

  // extract the LOB (as a zip file) into a ZIP_TAB object
  public static void zipExtract(
          Blob in,
          Array[] result,
          String[] err ) {
    try {
      Connection conn = Utility.getConn();

      InputStream x = in.getBinaryStream();

      ArrayList<Struct> vArray;
      // our inputstream is being read from the input LOB
      ZipInputStream inputstream = new ZipInputStream( new BufferedInputStream( x ) );
      try {
        // initialize a buffer
        byte[] buffer = new byte[BUFF_SIZE];
        // this is our variable Array
        vArray = new ArrayList<Struct>();
        // loop through the entries in the ZIP file
        ZipEntry ze;
        while ( ( ze = inputstream.getNextEntry() ) != null ) {
          Blob b = null;
          BufferedOutputStream outputstream = null;

          int bytesRead = inputstream.read( buffer, 0, BUFF_SIZE );
          while ( bytesRead > 0 ) {
            if ( b == null ) {
              b = conn.createBlob();
              outputstream = new BufferedOutputStream( b.setBinaryStream( 1L ) );
            }
            outputstream.write( buffer, 0, bytesRead );
            bytesRead = inputstream.read( buffer, 0, BUFF_SIZE );
          }

          if ( outputstream != null ) {
            // close up this LOB and convert to our ZIP_TYPE structure
            outputstream.flush();
            outputstream.close();
            Object[] o = { ze.getName(), b };
            Struct s = conn.createStruct( "ZIP_TYPE", o );
            vArray.add( s );
          }
        }
      } finally {
        // close up the source LOB
        inputstream.close();
      }

      // put all of our data into the ZIP_TAB array
      result[0] = ( (oracle.jdbc.OracleConnectionWrapper) conn ).createOracleArray( "ZIP_TABLE", vArray.toArray() );
    } catch ( Exception e ) {
      err[0] = Utility.fmtError( e );
    }
  }

}
/
