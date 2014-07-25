create or replace package body trc_admin is
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

  -- configuration constants
  cTrcLogLvl       constant varchar2(14) := 'trace.loglevel';
  cTrcPurgeMaxRows constant varchar2(20) := 'trace.purge.max.rows';

  gDateFmt         constant utl.text := 'YYYY-MM-DD HH24:MI:SS.FF6 TZH:TZM';

-------------------------------------------------------------------------------
procedure setLogLevel
  ( iLogLevel    in  rw )
is
  pragma autonomous_transaction;
begin

  if not (iLogLevel between trc.llEmerg and trc.llDebug) then
    raise_application_error(-20001, 'Invalid Log Level Specified');
  end if;

  cfg_admin.setCfgRaw(cTrcLogLvl, iLogLevel);

  commit;

end setLogLevel;
-------------------------------------------------------------------------------
/*  Since this has the potential to take a very long time, we create a job
    to do it. If the job already exists, an error occurs. */
procedure purgeTraceData
  ( iBeforeTimestamp  in timestamp with time zone
      default systimestamp - numtodsinterval(2.5, 'DAY') )
is
  cJobName  constant utl.text := 'PURGE_TRACE_DATA';
begin

  dbms_scheduler.create_job (
   job_name            => cJobName,
   job_type            => 'STORED_PROCEDURE',
   job_action          => 'trc_admin.purgeTraceDataInternal',
   number_of_arguments => 1,
   comments            => 'A purge request was made for Trace Data');

  dbms_scheduler.set_job_argument_value (
   job_name            => cJobName,
   argument_position   => 1,
   argument_value      => to_char(iBeforeTimestamp, gDateFmt) );

  dbms_scheduler.enable ( name => cJobName );

  commit;

end purgeTraceData;
-------------------------------------------------------------------------------
/* This is called from the job created above. A couple of things:
   -> The potential for very large sets of deletions is there, and
      since deletes take a very long time, and generate enormous
      amounts of redo, this procedure performs the deletes
      in bite-size chunks. 10,000 records at a go seems reasonable
      but can be changed in CFG.
   -> Since this could take a while, it's performed as a job so the
      user that invoked it can get on with their life while the delete
      takes place.
*/
procedure purgeTraceDataInternal
  ( iBeforeTimestamp  in varchar2 )
is
  maxRows   integer;
  rowCnt    integer;
  totalRows integer := 0;
  ts        timestamp with time zone;
begin
  maxRows := cfg.getCfgNumber(cTrcPurgeMaxRows);

  if maxRows is null then
    maxRows := 10000;
    cfg_admin.setCfgNumber(cTrcPurgeMaxRows, maxRows);
  end if;

  trc.timerStart('Time to purge trace data');
  ts := to_timestamp_tz(iBeforeTimestamp, gDateFmt);

  <<mainLoop>>
  loop

    delete "trc"
      where rowid in (select rowid
                        from "trc"
                        where tmstmp < ts
                          and rownum < maxRows);

    rowCnt := sql%rowcount;
    totalRows := totalRows + rowCnt;

    exit mainLoop when rowCnt = 0;
    commit;

  end loop mainLoop;

  trc.trc
    ( 'purgeTraceDataInternal complete: row count='||to_char(totalRows),
      iAutonomous => false );

  commit;

end purgeTraceDataInternal;
-------------------------------------------------------------------------------

end trc_admin;
/
show errors package body trc_admin
