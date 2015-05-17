create or replace package i18n_adm is

function getCanonicalName
  ( iNamespace  in varchar2 )
  return varchar2
  deterministic;

-- Set a string with namespace.
procedure set
  ( iNamespace in  varchar2,
    iID        in  varchar2,
    iLang      in  varchar2,
    iText      in  varchar2 );

-- Remove one or more strings in a namespace.
-- Not providing iLang or passing NULL will
-- remove all entries for iID.
procedure clear
  ( iNamespace in  varchar2,
    iID        in  varchar2,
    iLang      in  varchar2 default null );

end i18n_adm;
/
create or replace public synonym i18n_adm for i18n_adm;
grant execute on i18n_adm to i18n_adm;
