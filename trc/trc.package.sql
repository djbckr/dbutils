create or replace package trc authid definer is
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

/*
    TRACE/LOGGING package

    This package is intended to help you instrument your code.
    The output of this package is the TRACE view.
    If you want to see your own (session) trace information, use the TRACE_ME view

    Besides basic logging, this package includes the ability to record timing (interval)
    information, setting log-levels (much like Apache httpd log levels) and
    purging of old trace data asychronously.

*/
  -- convenience subtype
  subtype rw is raw(1);

-------------------------------------------------------------------------------
/*  PROCEDURE timerStart
    An easy way to log timing information in your program. Simply call this
    procedure before the thing you want to time. When you call TRC.TRC, the
    duration between this call and log is recorded, along with the timer comment.

    input values:
    --  iComment: a string of text you want to store with the timing information.
*/
  procedure timerStart
    ( iComment   in  varchar2 );

-------------------------------------------------------------------------------
/*  RECORD timerInfo
    This record is used for the return data from trc.timerStop (see below).

    timing is an "interval day to second" data type
    timing_comment is a varchar2(250) data type
*/
  type timerInfo is record (
    timing            trace.timing%type,
    timing_comment    trace.timing_comment%type
  );

/*  PROCEDURE timerStop
    This typically will not be called by your program, but it is available if you want it.

    It simply returns a timerInfo record, which contains the interval between "now" and
    the call to timerStart, along with the comment specified at the start.

    input values:
      -- iClear - If you want to keep the start-time anchor, specify FALSE in iClear.

    output values:
      -- timerInfo - see above

    NOTE: This procedure is called when TRC.TRC is invoked, and will clear the start time anchor.
*/
  function timerStop
    ( iClear     in  boolean default true )
    return timerInfo;

-------------------------------------------------------------------------------
/*  Log-Level values; use these constants in your code when you want to change the
    level of detail you wish to record in the log.

    NOTE: The default system-wide log level is llError, and can be changed at any time by
          another session. You cannot assume a particular setting will be in effect.
          Naturally the more detailed the level is set, the slower the system may
          become. It is suggested that the default level be set to llError for most situations.

    NOTE: It is suggested that when using TRC in an error handler, you should specify llError
          so it more likely gets logged.
*/
  llEmerg   constant rw := '01';
  llAlert   constant rw := '02';
  llCrit    constant rw := '03';
  llError   constant rw := '04';
  llWarn    constant rw := '05';
  llNotice  constant rw := '06';
  llInfo    constant rw := '07';
  llDebug   constant rw := '08';

/*  PROCEDURE trc

    This is the procedure you would call most of the time. Note that the default iLogLevel
    is llNotice, and the default (and recommended) system-wide log-level setting is llError,
    meaning the default settings will not record information in the TRACE view.

    It is suggested that if you use TRC in an exception handler, to specify at least llError
    as the iLogLevel, since that is generally an error condition.

    input values:
      -- iAdditionalInfo - up to 2000 characters can be passed and will be recorded in
                           the TRACE view.
      -- iLogLevel - specify the severity of the event you wish to log.
      -- iAutonomous - by default, when this procedure is called, the data is recorded and
                       committed immediately using an autonomous transaction. If you wish to
                       record information in the context of a standard transaction, pass
                       FALSE here.
*/
  procedure trc
  ( iAdditionalInfo   in  varchar2 default null,
    iLogLevel         in  rw       default llNotice,
    iAutonomous       in  boolean  default true );

-------------------------------------------------------------------------------
/*  PROCEDURE setLogLevel
    This modifies what log events will be recorded in the TRACE view
    at the session level. To change the log-level globally, use
    trc_admin.setLogLevel()

    input values:
      -- iLogLevel - anything from llEmerg to llDebug. Specifying llDebug
                     records the most information, and could possibly slow
                     the system down if you specify llScopeGlobal - as all
                     session will record as much data as possible.

*/
  procedure setLogLevel
    ( iLogLevel    in  rw );

end trc;
/
show errors package trc
grant execute on trc to public
/
create or replace public synonym trc for trc
/
