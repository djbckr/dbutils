# WHIRLPOOL

[Whirlpool](http://en.wikipedia.org/wiki/Whirlpool_(cryptography)) is an open-source 
public-domain [ISO standard](http://www.iso.org/iso/catalogue_detail?csnumber=39876) 
hashing algorithm. This package simply interfaces to the 
[reference implementation](http://www.larc.usp.br/~pbarreto/WhirlpoolPage.html).

In our opinion, Whirlpool is a superior hashing algorithm than anything else 
available. It's perfect for hashing passwords, among other things.

### The whirlpool___ functions

Each function takes the appropriate string, raw, clob, or blob data and returns
a 64-byte digest. Each has its own name since PL/SQL has overloading problems
with string/raw types.

    function whirlpoolString
      ( input   in  varchar2,
        charset in  varchar2 default 'UTF-8' )
      return raw deterministic;

    function whirlpoolRaw
      ( input  in   raw )
      return raw deterministic;

    function whirlpoolClob
      ( input   in  CLOB,
        charset in  varchar2 default 'UTF-8' )
      return raw deterministic;

    function whirlpoolBlob
      ( input  in   BLOB )
      return raw deterministic;


Note: The whirlpoolString and whirlpoolClob functions have the possibility of
mangling strings if the charset is incorrect. It uses java's
String.getBytes(charset) to get the byte-array to pass to the hash function.
Check the Java documentation if you are dealing with anything other than UTF-8.
