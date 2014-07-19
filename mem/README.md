# The MEM package

This package is used to help with dynamic SQL statements that require
varying amounts of bind variables. Very often you may find yourself
with the following type of code (a contrived example):

      execute immediate 'select something from t1 where f1 = :b1'
        using myVar;

While I won't get into the details in this document, this is occasionally difficult to manage in code when you have variations of a single statement and you need to provide different bind variables for similar statements.

You can use SYS_CONTEXT() to make bind variables, as follows:

    execute immediate q'[
      select something from t1 where f1 = sys_context('myctx','myvar')
    ]';

But this only supports strings, unless of course you use conversion functions.
It also requires that you CREATE CONTEXT... specifying a package to allow the
context to be set. Then you call your package to set the context.

The MEM package attempts to make all this a little easier. Under the hood, it creates 
an in-memory dictionary of ANYDATA. A contrived example is this:

    begin
      mem.setTimestamp('myts', systimestamp);
      delete from myTable
        where tmstmp < mem.getTimestamp('myts');
    end;

Note that you can access the mem package inside a Dynamic SQL statment:

    execute immediate q'[
      update myTable 
        set ... 
        where myCol = mem.getNumber('theNumber')
    ]';

You can use `mem.get...` functions anywhere a bind variable can be used.
Oracle treats it just like a bind variable.

Note that the names, like SYS_CONTEXT() are case-insensitive. That is,
'theNumber', 'THENUMBER', and 'thenumber' are identical.

You set Mems using one of the `set...` procedures:

    procedure setMem
      ( memName    in   varchar2,
        memValue   in   anydata );

    procedure setString
      ( memName    in   varchar2,
        memValue   in   varchar2 );

    procedure setNumber
      ( memName    in   varchar2,
        memValue   in   number );

    procedure setDate
      ( memName    in   varchar2,
        memValue   in   date );

    procedure setTimestamp
      ( memName    in   varchar2,
        memValue   in   timestamp );

    procedure setTimestampTZ
      ( memName    in   varchar2,
        memValue   in   timestamp with time zone );

    procedure setTimestampLTZ
      ( memName    in   varchar2,
        memValue   in   timestamp with local time zone );

    procedure setIntervalYM
      ( memName    in   varchar2,
        memValue   in   interval year to month );

    procedure setIntervalDS
      ( memName    in   varchar2,
        memValue   in   interval day to second );

    procedure setRaw
      ( memName    in   varchar2,
        memValue   in   raw );

The `setMem()` procedure accepts an ANYDATA data type. The rest of the
`set...()` procedures are for convenience. If there is a type (including
a UDT) that is not supported, you can write your own or just call:

    mem.setMem('myname', anyData.convertObject(myobject));

It will store anything that ANYDATA supports.

To retrieve data, simply use one of the `get...()` functions.

    function getMem
      ( memName    in   varchar2 )
      return anydata;

    function getString
      ( memName    in   varchar2 )
      return varchar2;

    function getNumber
      ( memName    in   varchar2 )
      return number;

    function getDate
      ( memName    in   varchar2 )
      return date;

    function getTimestamp
      ( memName    in   varchar2 )
      return timestamp;

    function getTimestampTZ
      ( memName    in   varchar2 )
      return timestamp with time zone;

    function getTimestampLTZ
      ( memName    in   varchar2 )
      return timestamp with local time zone;

    function getIntervalYM
      ( memName    in   varchar2 )
      return interval year to month;

    function getIntervalDS
      ( memName    in   varchar2 )
      return interval day to second;

    function getRaw
      ( memName    in   varchar2 )
      return raw;

Note that this package attempts to convert datatypes as is reasonable.
For example, if you did `mem.setDate('mydate', sysdate)` and then called 
`mem.getString('mydate')`, the function will in fact return a string-ified
version of the date, according to the session NLS settings.

If you call `mem.getDate('mystring')` on a string with an invalid date
string, an exception will be raised.

To clear all Mems, call the `reset()` procedure.
