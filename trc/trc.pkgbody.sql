create or replace package body trc is
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

  -- easier to type
  subtype str is varchar2(32767);
  subtype ids is interval day to second;

  -- configuration constant
  cTrcLogLvl       constant varchar2(14) := 'trace.loglevel';
  cTrcPurgeMaxRows constant varchar2(20) := 'trace.purge.max.rows';

  -- since these variables are in a package, they are both "session" variables
  -- however, gSessionLogLevel is used to actually determine what this session
  -- will do when procedure LOG is invoked.
  gSessionLogLevel rw;

  -- the gGlobalLogLevel is used only to determine if the configuration has changed
  -- on a global level, and if that occurs, it sets the session level to the global level.
  gGlobalLogLevel  rw;

  -- this is used to record timing data if we want it
  gTimer           timestamp;
  gTimerComment    str;

  gDateFmt         constant str := 'YYYYMMDDHH24MISSFF2';

-------------------------------------------------------------------------------
-- simple INSERT into TRACE table.
-- This is called only from logAuto or logNorm
procedure performInsert
  ( iCallStack        in  varchar2,
    iErrStack         in  varchar2,
    iErrBack          in  varchar2,
    iAdditionalInfo   in  varchar2,
    iTiming           in  timerInfo,
    iLogLevel         in  rw )
is
begin

  insert into "trc"
    ( tmstmp, call_stack, err_stack, err_backtrace,
      additional_info, timing, timing_comment,
      log_level, log_lvl_setting, web_user )
    values
    ( sys_extract_utc(systimestamp), iCallStack, iErrStack, iErrBack,
      iAdditionalInfo, iTiming.timing, iTiming.timing_comment,
      iLogLevel, gSessionLogLevel, owa_sec.get_user_id );

end performInsert;
-------------------------------------------------------------------------------
-- this just fires up an autonomous transaction for the insert to trace
procedure logAuto
  ( iCallStack        in  varchar2,
    iErrStack         in  varchar2,
    iErrBack          in  varchar2,
    iAdditionalInfo   in  varchar2,
    iTiming           in  timerInfo,
    iLogLevel         in  rw )
is
  pragma autonomous_transaction;
begin
  performInsert(iCallStack, iErrStack, iErrBack,
                iAdditionalInfo, iTiming, iLogLevel);
  commit;
end logAuto;
-------------------------------------------------------------------------------
procedure logNorm
  ( iCallStack        in  varchar2,
    iErrStack         in  varchar2,
    iErrBack          in  varchar2,
    iAdditionalInfo   in  varchar2,
    iTiming           in  timerInfo,
    iLogLevel         in  rw )
is
begin
  performInsert(iCallStack, iErrStack, iErrBack,
                iAdditionalInfo, iTiming, iLogLevel);
end logNorm;
-------------------------------------------------------------------------------
procedure trc
  ( iAdditionalInfo   in  varchar2 default null,
    iLogLevel         in  rw       default llNotice,
    iAutonomous       in  boolean  default true )
is
  vCallStack        str;
  vErrStack         str;
  vErrBack          str;
  vAddlInfo         str;
  vTiming           timerInfo;
  vGlobalLogLevel   rw;
begin

  -- get our timing information first, since timing is semi-critical
  vTiming := timerStop(true);

  -- get the system-wide log-level
  vGlobalLogLevel := cfg.getCfgRaw(cTrcLogLvl);

  -- and see if it changed. If so, reset our session variables
  if gGlobalLogLevel != vGlobalLogLevel then
    gSessionLogLevel := vGlobalLogLevel;
    gGlobalLogLevel  := vGlobalLogLevel;
  end if;

  if iLogLevel > gSessionLogLevel then
    return;
  end if;

  -- grab stack information here, so we don't get additional
  -- stack information when we call the subroutines.
  vCallStack := dbms_utility.format_call_stack;
  vErrStack  := dbms_utility.format_error_stack;
  vErrBack   := dbms_utility.format_error_backtrace;

  -- make sure we don't exceed column max
  vAddlInfo  := substr(iAdditionalInfo, 1, 4000);

  -- most logging should be autonomous, but if we don't want it...
  if iAutonomous then
    logAuto(vCallStack, vErrStack, vErrBack, vAddlInfo, vTiming, iLogLevel);
  else
    logNorm(vCallStack, vErrStack, vErrBack, vAddlInfo, vTiming, iLogLevel);
  end if;

end trc;
-------------------------------------------------------------------------------
procedure timerStart
  ( iComment   in  varchar2 )
is
begin
  -- to be on the safe side, we'll use UTC for everything
  gTimer := sys_extract_utc(systimestamp);
  gTimerComment := iComment;
end timerStart;
-------------------------------------------------------------------------------
function timerStop
  ( iClear     in  boolean default true )
  return timerInfo
is
  rslt timerInfo;
begin

  if gTimer is not null then

    rslt.timing         := sys_extract_utc(systimestamp) - gTimer;
    rslt.timing_comment := gTimerComment;

    if iClear then
      gTimer := null;
      gTimerComment := null;
    end if;

  end if;

  return rslt;

end timerStop;
-------------------------------------------------------------------------------
procedure setGlobalLogLevel
  ( iLogLevel    in rw )
is
  pragma autonomous_transaction;
begin

  -- set the session's global level (for use for comparison in the LOG procedure)
  gGlobalLogLevel := iLogLevel;

  -- set the database-wide level
  cfg.setCfgRaw(cTrcLogLvl, iLogLevel);

  -- commit autonomous trxn
  commit;

end setGlobalLogLevel;
-------------------------------------------------------------------------------
procedure setLogLevel
  ( iLogLevel    in  rw,
    iScope       in  rw default llScopeSession )
is
begin

  if not (iLogLevel between llEmerg and llDebug) then
    raise_application_error(-20001, 'Invalid Log Level Specified');
  end if;

  -- set the local session level (which trumps the global level)
  gSessionLogLevel := iLogLevel;

  if iScope = llScopeGlobal then
    setGlobalLogLevel( iLogLevel );
  end if;

end setLogLevel;
-------------------------------------------------------------------------------
/*  Since this has the potential to take a very long time, we create a job
    to do it. If the job already exists, an error occurs. */
procedure purgeTraceData
  ( iBeforeTimestamp  in timestamp )
is
  cJobName  constant str := 'PURGE_TRACE_DATA';
begin

  dbms_scheduler.create_job (
   job_name            => cJobName,
   job_type            => 'STORED_PROCEDURE',
   job_action          => 'trc.purgeTraceDataInternal',
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
  ts      timestamp;
  ti      timerInfo;
begin
  maxRows := cfg.getCfgNumber(cTrcPurgeMaxRows);

  if maxRows is null then
    maxRows := 10000;
    cfg.setCfgNumber(cTrcPurgeMaxRows, maxRows);
  end if;

  timerStart('Time to purge trace data');
  ts := to_timestamp(iBeforeTimestamp, gDateFmt);

  <<mainLoop>>
  loop

    delete "trc"
      where rowid in (select rowid
                        from "trc"
                        where tmstmp < sys_extract_utc(ts)
                          and rownum < maxRows);

    rowCnt := sql%rowcount;
    totalRows := totalRows + rowCnt;

    commit;

    exit mainLoop when rowCnt = 0;

  end loop mainLoop;

  trc ( 'purgeTraceDataInternal complete: row count='||to_char(totalRows),
        iAutonomous => false );

  commit;

end purgeTraceDataInternal;
-------------------------------------------------------------------------------
-- initialize the package log level
procedure init
is
begin

  -- get the log-level from CFG
  gSessionLogLevel := nvl(cfg.getCfgRaw(cTrcLogLvl), HexToRaw('FF'));

  if gSessionLogLevel = HexToRaw('FF') then
    setLogLevel(llError, llScopeGlobal);
  end if;

end init;
-------------------------------------------------------------------------------

begin

  -- package initialization
  init;

end trc;
/
show errors package body trc
