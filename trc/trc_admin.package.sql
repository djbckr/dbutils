create or replace package trc_admin authid definer is
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

  -- This package can only be executed by users with the TRCADMIN role

  -- convenience subtype
  subtype rw is raw(1);

-------------------------------------------------------------------------------
/*  PROCEDURE setLogLevel
    This modifies what log events will be recorded in the TRACE view
    at the global level. To change the log-level at the session level,
    use trc.setLogLevel()

    input values:
      -- iLogLevel - anything from trc.llEmerg to trc.llDebug.
                     Specifying llDebug records the most information,
                     and could possibly slow the system down if you
                     specify llScopeGlobal - as all session will record
                     as much data as possible.

*/
  procedure setLogLevel
    ( iLogLevel    in  rw );

-------------------------------------------------------------------------------
/*  PROCEDURE purgeTraceData purges all trace data before the given timestamp.

    This creates a job that runs outside the scope of your session, so it returns
    immediately, regardless of the size of data you are purging.

    input values:
      -- iBeforeTimestamp - specify a timestamp which is the cutoff time you wish
                            to delete data. Keep in mind the timestamps in the TRACE
                            view are set to UTC, so you may want to consider using
                            sys_extract_utc(systimestamp) as your input.
*/
  procedure purgeTraceData
    ( iBeforeTimestamp  in timestamp with time zone
        default systimestamp - numtodsinterval(2.5, 'DAY') );

-------------------------------------------------------------------------------
/* This procedure is intended to be used internally (by the job).
   Do not call this from your code.
*/
  procedure purgeTraceDataInternal
    ( iBeforeTimestamp  in varchar2 );
-------------------------------------------------------------------------------
end trc_admin;
/
show errors package trc_admin
grant execute on trc_admin to trcadmin
/
create or replace public synonym trc_admin for trc_admin
/
