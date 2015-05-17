create or replace package body i18n_adm is
-------------------------------------------------------------------------------
function getCanonicalName
  ( iNamespace  in varchar2 )
  return varchar2
is
  vNamespace varchar2(9999);
begin
  dbms_utility.canonicalize(iNamespace, vNamespace, length(iNamespace));
  return nvl(vNamespace, 'PUBLIC');
end getCanonicalName;
-------------------------------------------------------------------------------
procedure set
  ( iNamespace in  varchar2,
    iID        in  varchar2,
    iLang      in  varchar2,
    iText      in  varchar2 )
is
begin

  merge into "i18n_translation" dst
    using ( select  getCanonicalName(iNamespace) namespace,
                    iID identifier,
                    iLang language_id,
                    iText text
              from dual ) src
    on (src.namespace = dst.namespace and
        src.identifier = dst.identifier and
        src.language_id = dst.language_id)
    when matched then update
      set dst.text = src.text
    when not matched then insert
        (dst.namespace, dst.identifier, dst.language_id, dst.text)
      values
        (src.namespace, src.identifier, src.language_id, src.text);

end set;
-------------------------------------------------------------------------------
procedure clear
  ( iNamespace in  varchar2,
    iID        in  varchar2,
    iLang      in  varchar2 default null )
is
begin

  delete "i18n_translation"
    where namespace = getCanonicalName(iNamespace)
      and identifier = iID
      and language_id = nvl(iLang, language_id);

end clear;
-------------------------------------------------------------------------------
end i18n_adm;
/
