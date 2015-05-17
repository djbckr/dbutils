create or replace package i18n is

  -- get text string from Namespace, ID, and optional Language
  function get
    ( iNamespace in varchar2,
      iID        in varchar2,
      iLang      in varchar2 default null )
    return varchar2;

  -- get text string from PUBLIC Namespace and default configured Language
  function get
    ( iID        in varchar2 )
    return varchar2;

end i18n;
/
create or replace public synonym i18n for i18n;
grant execute on i18n to public;
