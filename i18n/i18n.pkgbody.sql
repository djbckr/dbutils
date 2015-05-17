create or replace package body i18n is

defaultlangcfg   constant utl.text := 'i18n.default.language';
gDefaultLanguage          utl.text;

-------------------------------------------------------------------------------
function get
  ( iNamespace in varchar2,
    iID        in varchar2,
    iLang      in varchar2 default null )
  return varchar2
is
  rslt         utl.text;
  vNamespace   utl.text;
begin

  vNamespace := i18n_adm.getCanonicalName(iNamespace);

  select nvl(t1.text, t2.text)
    into rslt
    from dual z
    left join "i18n_translation" t1
      on t1.namespace = vNamespace
     and t1.identifier = iID
     and t1.language_id = iLang
    left join "i18n_translation" t2
      on t2.namespace = vNamespace
     and t2.identifier = iID
     and t2.language_id = gDefaultLanguage;

  return rslt;

end get;
-------------------------------------------------------------------------------
function get
  ( iID        in varchar2 )
  return varchar2
is
begin
  return "GET"('PUBLIC', iID, gDefaultLanguage);
end get;
-------------------------------------------------------------------------------
procedure init
is
begin

  gDefaultLanguage := cfg.getCfgString(defaultlangcfg);

  if gDefaultLanguage is null then
    cfg_admin.setCfgString(defaultlangcfg, 'en');
    gDefaultLanguage := cfg.getCfgString(defaultlangcfg);
  end if;

end init;
-------------------------------------------------------------------------------
begin
  init();
end i18n;
/
