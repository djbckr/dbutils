# TRACE/LOGGING package

This package is intended to help you instrument your code.
The output of this package is the `TRACE` view.
If you want to see your own (session) trace information, 
use the `TRACE_ME` view.

Besides basic logging, this package includes the ability to record timing (interval)
information, setting log-levels (much like Apache httpd log levels) and
purging of old trace data asychronously.

At its simplest, call `trc.trc()`. The `trc` procedure is defined as:

    procedure trc
    ( iAdditionalInfo   in  varchar2 default null,
      iLogLevel         in  rw       default llNotice,
      iAutonomous       in  boolean  default true );

You can specify anything you want (up to 4000 characters) in `iAdditionalInfo`.  
The log-level is discussed below.  
By default, when this procedure is called, the data is recorded and
committed immediately using an autonomous transaction. If you wish to
record information in the context of a standard transaction, pass
FALSE to `iAutonomous`. Be aware of two things with this setting:

- A transaction rollback will cause any logging to be rolled back as well.
- If you are logging during a query (SELECT...), an exception will be thrown.

### About Log-Level ###

When you call the `trc()` procedure, you specify a log level (default `llNotice`).
Depending on the global or session log-level settings, the call may or may not
be logged. For example, if the log-level is currently at `llAlert`, then tracing
an `llNotice` will not get logged; it is simply ignored.

The levels in order of severity are:

- `llEmerg`
- `llAlert`
- `llCrit`
- `llError`
- `llWarn`
- `llNotice`
- `llInfo`
- `llDebug`

NOTE: The default system-wide log level is `llError`, and can be changed at any time by
      another session. You cannot assume a particular setting will be in effect.
      Naturally the more detailed the level is set, the slower the system could
      become. It is suggested that the default level be set to `llError` for most situations.

You should sprinkle your code throughout with things like:

    trc.trc('performing step x in this process', trc.llDebug);

In this example, if the log-level is higher than `llDebug`, this call is ignored.

NOTE: It is suggested that when using TRC in an error handler, you should specify `llError`
      so it more likely gets logged.

### Using Timers ###

To time things in your system, you can call

    procedure timerStart
      ( iComment   in  varchar2 );

This anchors a start time, then when you later call `trc()`, the difference in
time between `timerStart()` and then is recorded in the trace record, along
with the comment specified.

The `timerStop()` procedure is available, but typically is not something you
would use, as `trc()` stops timing anyway.

### Setting the Log-Level ###

    procedure setLogLevel
      ( iLogLevel    in  rw,
        iScope       in  rw default llScopeSession );

Here, you specify the log-level you wish to trace. By default, calling this
only affects the log-level of your session. To change the setting globally,
specify `trc.llScopeGlobal`.

### Purging Trace Data ###

From time-to-time you should purge the trace table. To do this, simply call:

    procedure purgeTraceData
      ( iBeforeTimestamp  in timestamp );

And specify the timestamp where you wish to end the deletion.

NOTE: Everything is logged in UTC (Zulu) so it's suggested that if you want
to delete everything older than 24 hours, you use something like this:

    trc.purgeTraceData(sys_extract_utc(systimestamp-numtodsInterval(1, 'day')));

Since the potential is there for very long/slow deletes, this procedure 
spawns a scheduler job and returns immediately. Your database administrator
should have the scheduler engine running, and give it time to finish processing.

### What is the "rw" type I see?
This type is defined in the `trc` package as RAW(1) and is used extensively here. All
of the log-level settings and scope settings are this type, and you should use the
defined constants listed above to avoid any data-type translation errors.
Use the constants!
