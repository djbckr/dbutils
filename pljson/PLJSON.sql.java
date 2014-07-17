create or replace java source named "PLJSON" as
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

/*
 * Class PJSON is pretty much a utility class that centralizes some information
 * and processing for the rest of the system. As you can see, there isn't much.
 */
public class PLJSON
{
  // Identifying strings in psonElement.typ (attribute[0])
  // Reason for this: A SQL TYPE must have at least one
  // attribute/field, even for an abstract type. The only
  // thing that made sense was to identify what kind of element
  // the type would be. While you can find out by type-casting,
  // this works so long as things are encapsulated.
  // Don't change these, as PLJSON will break if you do.
  protected static final String cObject = "daElVTjd5yGxxlulG2Pv4mmh";
  protected static final String cArray = "ZZyQnZyETd0uEhQCh1Qqc45S";
  protected static final String cString = "LavdJ6qDpIwVQHGSNVD9d3U4";
  protected static final String cNumber = "ys1Y2sh2gm8QK5z5u04M5rIS";
  protected static final String cBoolean = "dhAKeRQTw1k2Rpo9q9H86mMI";
  protected static final String cNull = "N4rsqsFXfWQYuS2tekZMU7Xx";

  // type names used to instantiate the Oracle objects
  protected static final String psonArray = "PLJSONARRAY";
  protected static final String psonElements = "PLJSONELEMENTS";
  protected static final String psonObjectEntry = "PLJSONOBJECTENTRY";
  protected static final String psonObjectEntries = "PLJSONOBJECTENTRIES";
  protected static final String psonObject = "PLJSONOBJECT";
  protected static final String psonBoolean = "PLJSONBOOLEAN";
  protected static final String psonNumber = "PLJSONNUMBER";
  protected static final String psonString = "PLJSONSTRING";
  protected static final String psonNull = "PLJSONNULL";

}
/
