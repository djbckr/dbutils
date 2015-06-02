# Ruby Willow Oracle Database Utilities

This is a collection of utilities that we have used over the years. 
We find them quite useful for various purposes and we hope you do too.

This README is a general overview of what this repository contains. For 
details, be sure to look at the package specs where applicable, as there 
is lots more documentation there.

### Some collection types

- `strTable` :: a table of varchar2(4000 char)
- `numTable` :: a table of number
- `rawTable` :: a table of raw(32)
- `tsTable` :: a table of timestamp
- `tstzTable` :: a table of timestamp with time zone
- `anyTable` :: a table of anydata
- ===
- `strArray` :: a varray(100) of varchar2(4000 char)
- `numArray` :: a varray(100) of number
- `rawArray` :: a varray(100) of raw(32);
- `tsArray` :: a varray(100) of timestamp
- `tstzArray` :: a varray(100) of timestamp with time zone
- `anyArray` :: a varray(100) of anydata

These definitions are useful when you need a collection in SQL and PL/SQL. 
They translate from one to the other seamlessly.

These collections are available to use in table definitions. When used in a 
table definition, a nested table (table of...) must use a separate table 
storage clause and is always stored in its own table. We rarely find a use 
for this, since that would be a standard relation. However, a VARRAY is stored 
inline (or as a BLOB if it gets too big) so we find this more advantageous 
when we need to have a small collection in a table, and don't want to 
define another table for it.

### The UTL package
This package also defines some types that are quite useful:

- `text` :: varchar2(32760)
- `stribstr` :: table of text index by text
- `stribint` :: table of text index by binary_integer
- `numibstr` :: table of number index by text
- `numibint` :: table of number index by binary_integer
- `tsibstr` :: table of timestamp index by text
- `tsibint` :: table of timestamp index by binary_integer
- `tstzibstr` :: table of timestamp with time zone index by text
- `tstzibint` :: table of timestamp with time zone index by binary_integer

The `utl.text` type can be used anywhere in your PL/SQL code where you would 
otherwise define `VARCHAR2(n)`. We find it cleaner.

The collections defined here (associative arrays, or index-by tables) are not 
available in SQL, but are quite handy in PL/SQL.

In addition to the defined types, several helpful functions are available:

- `split_string_strtable()` and `split_string_strarray()` :: both of these are 
   identical except of course for the return type. Given a string with 
   delimiters, this will return a list of strings. Note that the delimiter is 
   a regular expression and is actually an implementation of Java 
   `String.split()`. Check the Java documentation for more information.

- `random_guid()` :: pretty straightforward. Calls Java's `UUID.randomUUID()` 
   to generate a GUID, similar to Oracle's `SYS_GUID()` SQL function, but of 
   course, random.

### The BOOL package
Since Oracle insists on not having a boolean datatype in SQL, we're forced to 
muck about with boolean conversions and definitions. The BOOL package helps to 
ease this pain a bit.

First, it defines "True" as `'*'` (star/asterisk/splat) and false as `' '` (a 
white space) declared as `cTrue` and `cFalse`. We have gone down all the roads 
of Y/N, T/F, 1/0, etc, and frankly do not like any of these. 
The splat/space notation solves a few issues:

- The value of true/false is not determined by language: (Yes, No, True, False)
   (sí, no, verdadero, falso) (oui, non, vrai, faux) (да, нет, истина, ложь) etc...
- Using numbers is a tiny bit slower than characters, but more importantly the 
   storage width of 1 is different than the storage width of 0. That means 
   whenever you change the value, the row gets moved in the block, so updates 
   can fragment the block.
- Using splat/space is easier to see in a grid. It's much faster to spot
   True/False values in this manner, as opposed to letters and numbers.

Since the code is open-source, you are welcome to change the definition.
We were careful to define these values in one single place, so it's safe 
to change it if you like.

Since SQL can only call PL/SQL functions and not package constants, two 
functions are defined that return these true/false character values 
specifically in queries: `fTrue` and `fFalse`.

Finally, there are the `toBool()` and `toChar()` functions to use in 
your PL/SQL programs.

### The CFG package
This package is designed to keep name/value configurations for you in a clean 
manner. You can store any datatypes in here, but there are convenience methods 
for Strings, Numbers, Timestamps, and Raw data. The underlying mechanism uses 
the ANYDATA datatype.

The `CONFIG` view displays - as much as it can - the contents of the underlying 
stored data.

This package is not intended to be a general store for application data; it's 
designed for application configuration, such as "do I want to enable tracing 
for certain code paths", or "are we past the cutoff date" types of data. 
Relatively low volume of updates, and lots of reads are what this is for.

### The TRC package
This is an application trace utility. Instrumenting your code is necessary, 
but can cause a great deal of overhead when done improperly. This package 
allows you to set a log-level (much like the Apache HTTP server). Whenever 
your code makes a `trc.trc()` call below the log-level threshold, nothing 
happens. If you set the log-level to `llDebug`, then everything gets 
logged. Your code should have debug trace calls on nearly every other line 
of code. The log level keeps the amount of logging low, unless of course 
you need it.

The `TRACE` view contains pretty much any information you could possibly need.

### The ZIP package
This one is pretty straightforward. To compress a bunch of "files" into a zip 
file, load up the `ZIP_TABLE` with a bunch of BLOBs and call `deflate()`. 
To uncompress a zip file into a bunch of files, pass a BLOB to `inflate()`. 
This uses the Java built-in zip library to do its work.

### The PLJSON package and objects
This set of objects and package is a JSON interface for PL/SQL. We will direct 
you to the README.md file there for usage information. We have been heavily 
using this in a production system for over a year and it works beautifully.

### The TABLE_AUDIT package
Oracle auditing is really very good, but where it lacks is an easy utility to 
do table-level data auditing. In fact, the Oracle documentation tells you how 
to do it, by creating a duplicate table and putting a trigger on the primary 
table, which can be a bit of a chore.

This package seeks to ease that task. Very simply, you call `audit_table()` 
and instantly the table you specify is being audited. To stop auditing, 
simply call `stop()`. It really couldn't be simpler. The package is designed 
so that if you alter the source table, simply calling `audit_table()` again 
synchronizes the shadow table and fixes the trigger.

### The WHIRLPOOL package
[Whirlpool](http://en.wikipedia.org/wiki/Whirlpool_(cryptography)) is an open-source 
public-domain [ISO standard](http://www.iso.org/iso/catalogue_detail?csnumber=39876) 
hashing algorithm. This package simply interfaces to the 
[reference implementation](http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html).

In our opinion, Whirlpool is a superior hashing algorithm than anything else 
available. It's perfect for hashing passwords, among other things.

### The MEM package
This package allows you to store any data in a memory dictionary. This makes a
great dynamic bind-variable store; better than SYS_CONTEXT(). Please refer
to the README in that directory for more information.

### The METAPHONE package
The [metaphone algorithm](http://en.wikipedia.org/wiki/Metaphone) is considered
to be a better, more accurate version of SOUNDEX. This uses the DoubleMetaphone
algorithm implemented by [Apache Commons Codec]
(http://commons.apache.org/proper/commons-codec/) so it returns two variations
of a word.

### The EXIF package
This package allows you to get EXIF (image metadata) from a large variety of 
media files. It uses the [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool/) 
program, and that program must be installed on the Oracle database server in order 
to work. This utility is a great example of how to call a command-line from Java 
through PL/SQL. This package is not automatically installed from the normal
installer script since there is a security issue there. You can look around
in the source code to see how it works and if you decide you want to install it,
just un-comment the line in the installer.

### INTERVAL DAY TO SECOND aggregation
Oracle doesn't have aggregation (`avg()`, `sum()`) on INTERVAL data types. We have
created two functions for just that purpose: `avg_dsinterval()` and `sum_dsinterval()`.
These functions should work fully on regular as well as parallel and analytic queries.

Note that INTERVAL YEAR TO MONTH is not supported, only DAY TO SECOND is. This also
gives you an idea of how to write your own aggregate functions if you like.
