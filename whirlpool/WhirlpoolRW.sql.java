-- // note, this is really a SQL file with a .java extension.
create or replace and compile java source named "WhirlpoolRW" as
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
import java.sql.Blob;
import java.sql.Clob;
import net.rubywillow.security.Whirlpool;

public class WhirlpoolRW {

  static final int BUFF_SIZE = 8192; // manage in 8KB chunks

  private static oracle.sql.RAW whirlpool( byte[] input, int rounds ) {
    Whirlpool w = new Whirlpool();
    w.add(input);
    byte[] rslt;
    if (rounds <= 1) {
      rslt = w.digest();
    } else {
      rslt = w.digestRounds(rounds);
    }
    return new oracle.sql.RAW(rslt);
  }

  public static void whirlpoolString(
          String cleartext,
          String charset,
          int rounds,
          oracle.sql.RAW[] rslt,
          String[] err ) {
    try {
      if (cleartext == null) {
        cleartext = "";
      }
      rslt[0] = whirlpool( cleartext.getBytes( charset ), rounds );
    } catch ( Exception e ) {
      err[0] = Utility.fmtError( e );
    }
  }

  public static void whirlpoolRaw(
          oracle.sql.RAW cleartext,
          int rounds,
          oracle.sql.RAW[] rslt,
          String[] err ) {
    try {
      byte[] src;
      if (cleartext != null) {
        src = (byte[]) cleartext.toJdbc();
      } else {
        src = new byte[0];
      }
      rslt[0] = whirlpool( src, rounds );
    } catch ( Exception e ) {
      err[0] = Utility.fmtError( e );
    }
  }

  public static void whirlpoolCLOB(
          Clob cleartext,
          String charset,
          oracle.sql.RAW[] rslt,
          String[] err ) {
    try {
      int len;
      char[] buffer = new char[BUFF_SIZE];
      Reader instream = cleartext.getCharacterStream();
      Whirlpool w = new Whirlpool();
      len = instream.read( buffer );
      while ( len > 0 ) {
        w.add( new String( buffer, 0, len ).getBytes( charset ) );
        len = instream.read( buffer );
      }
      rslt[0] = new oracle.sql.RAW( w.digest() );
    } catch ( Exception e ) {
      err[0] = Utility.fmtError( e );
    }
  }

  public static void whirlpoolBLOB(
          Blob cleartext,
          oracle.sql.RAW[] rslt,
          String[] err ) {
    try {
      int len;
      byte[] buffer = new byte[BUFF_SIZE];
      InputStream instream = cleartext.getBinaryStream();
      Whirlpool w = new Whirlpool();
      len = instream.read( buffer );
      while ( len > 0 ) {
        w.add( buffer );
        len = instream.read( buffer );
      }
      rslt[0] = new oracle.sql.RAW( w.digest() );
    } catch ( Exception e ) {
      err[0] = Utility.fmtError( e );
    }
  }

}
/
