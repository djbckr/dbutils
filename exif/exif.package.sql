create or replace package exif authid definer is
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

/*  FUNCTION getMediaInfo

    Given a media file (photograph, video, flash, whatever)
    returns the metadata regarding the file. For non-media or
    otherwise invalid files, the result record contains NULLs.

    Do not expect that all fields will be filled. Very often,
    some fields are blank.

    Usually file_type, mime_type, width, and height are filled.
*/

-- result type used for getMediaInfo()
type rMediaInfo is record (
  file_type         varchar2(100),                -- "File Type"
  mime_type         varchar2(100),                -- "MIME Type"
  create_date       timestamp,                    -- "Create Date"
  duration          interval day(1) to second(0), -- "Duration"
  width             integer,                      -- "Image Width"
  height            integer                       -- "Image Height"
);

function getMediaInfo
  ( media   in  BLOB )
  return rMediaInfo;

/*  FUNCTION getMediaInfoRaw
    Same as above, but returns the raw output of exiftool as a string.
    Each line is a field, and the name/value is separated by tab. */

function getMediaInfoRaw
  ( media   in  BLOB )
  return varchar2;

end exif;
/
show errors package exif

grant execute on exif to public
/

create or replace public synonym exif for exif
/
