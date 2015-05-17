/*
    !!!! BE AWARE !!!

    This file contains true Unicode (UTF8) characters.
    Be sure you are running this on a system that understands Unicode.

 */
create table "country" (
  country_id       varchar2(3 byte),
  name             varchar2(100 char) constraint nl_country_name not null,
  native_name      varchar2(100 char) constraint nl_country_nativename not null,
  country_code2    varchar2(2 byte)   constraint nl_country_cntrycode2 not null,
  country_number   varchar2(3 byte)   constraint nl_country_cntrynumber not null,
  capital          varchar2(100 char),
  altspellings     strarray,
  region           varchar2(100 char),
  constraint pk_country primary key (country_id),
  constraint uq_country_cca2 unique (country_code2),
  constraint uq_country_ccn3 unique (country_number),
  constraint uq_country_name unique (name),
  constraint uq_country_native_name unique (native_name)
);

grant select, references on "country" to public;
create or replace public synonym countries for "country";

create table "currency" (
  currency_id      varchar2(3 byte),
  name             varchar2(100 char) constraint nl_currency_name not null,
  symbol           varchar2(100 char) constraint nl_currency_symbol not null,
  frac_name        varchar2(100 char),
  frac_amt         number(7,0),
  rate             number             default 1 constraint nl_currency_rate not null,
  constraint pk_currency primary key (currency_id)
);

grant select, references on "currency" to public;
create or replace public synonym currencies for "currency";

create table "language" (
  language_id      varchar2(2 byte),
  code3            varchar2(3 byte),
  name             varchar2(100 char),
  native_name      varchar2(100 char),
  constraint pk_language primary key (language_id)
);

grant select, references on "language" to public;
create or replace public synonym languages for "language";

create table "country_language" (
  country_id       ,
  language_id      ,
  constraint pk_country_language primary key (country_id, language_id),
  constraint fk_country_language_2_country foreign key (country_id) references "country" (country_id),
  constraint fk_country_language_2_language foreign key (language_id) references "language" (language_id)
) organization index;

create or replace view country_languages as
select co.country_id, co.name country_name, co.native_name country_native_name,
       la.language_id, la.name language_name, la.native_name language_native_name
  from "country_language" cl
  join "country" co
    on cl.country_id = co.country_id
  join "language" la
    on la.language_id = cl.language_id
  with read only
/

grant select on country_languages to public;
create or replace public synonym country_languages for country_languages;

create table "country_currency" (
  country_id       ,
  currency_id      ,
  constraint pk_country_currency primary key (country_id, currency_id),
  constraint fk_cntrycncy_2_country foreign key (country_id) references "country" (country_id),
  constraint fk_cntrycncy_2_currency foreign key (currency_id) references "currency" (currency_id)
) organization index;

create or replace view country_currencies as
select co.country_id, co.name country_name, co.native_name country_native_name,
       cu.currency_id, cu.name currency_name, cu.symbol currency_symbol, cu.frac_name, cu.frac_amt
  from "country_currency" cc
  join "country" co
    on co.country_id = cc.country_id
  join "currency" cu
    on cu.currency_id = cc.currency_id
  with read only
/

grant select on country_currencies to public;
create or replace public synonym country_currencies for country_currencies;

create table "i18n_translation" (
  namespace   varchar2(30 char),
  identifier  varchar2(100 char),
  language_id ,
  text        varchar2(4000 char),
  constraint pk_i18n_key primary key (namespace, identifier, language_id),
  constraint fk_i18n_2_language foreign key (language_id) references "language" (language_id)
) organization index overflow;

grant select on "i18n_translation" to public;
create or replace public synonym i18n_translations for "i18n_translation";

insert into "country"
  ( country_id, name, native_name, country_code2, country_number, capital, altspellings, region )
select 'AFG', 'Afghanistan', 'افغانستان', 'AF', '004', 'Kabul', utl.split_string_strarray('AF,Afġānistān',','), 'Asia' from dual union all
select 'ALA', 'Åland Islands', 'Åland', 'AX', '248', 'Mariehamn', utl.split_string_strarray('AX,Aaland,Aland,Ahvenanmaa',','), 'Europe' from dual union all
select 'ALB', 'Albania', 'Shqipëria', 'AL', '008', 'Tirana', utl.split_string_strarray('AL,Shqipëri,Shqipëria,Shqipnia',','), 'Europe' from dual union all
select 'DZA', 'Algeria', 'الجزائر', 'DZ', '012', 'Algiers', utl.split_string_strarray('DZ,Dzayer,Algérie',','), 'Africa' from dual union all
select 'ASM', 'American Samoa', 'American Samoa', 'AS', '016', 'Pago Pago', utl.split_string_strarray('AS,Amerika Sāmoa,Amelika Sāmoa,Sāmoa Amelika',','), 'Oceania' from dual union all
select 'AND', 'Andorra', 'Andorra', 'AD', '020', 'Andorra la Vella', utl.split_string_strarray('AD,Principality of Andorra,Principat d''Andorra',','), 'Europe' from dual union all
select 'AGO', 'Angola', 'Angola', 'AO', '024', 'Luanda', utl.split_string_strarray('AO,República de Angola,ʁɛpublika de an''ɡɔla',','), 'Africa' from dual union all
select 'AIA', 'Anguilla', 'Anguilla', 'AI', '660', 'The Valley', utl.split_string_strarray('AI',','), 'Americas' from dual union all
select 'ATG', 'Antigua and Barbuda', 'Antigua and Barbuda', 'AG', '028', 'Saint John''s', utl.split_string_strarray('AG',','), 'Americas' from dual union all
select 'ARG', 'Argentina', 'Argentina', 'AR', '032', 'Buenos Aires', utl.split_string_strarray('AR,Argentine Republic,República Argentina',','), 'Americas' from dual union all
select 'ARM', 'Armenia', 'Հայաստան', 'AM', '051', 'Yerevan', utl.split_string_strarray('AM,Hayastan,Republic of Armenia,Հայաստանի Հանրապետություն',','), 'Asia' from dual union all
select 'ABW', 'Aruba', 'Aruba', 'AW', '533', 'Oranjestad', utl.split_string_strarray('AW',','), 'Americas' from dual union all
select 'ASC', 'Ascension Island', 'Ascension Island', 'AC', 'ASC', 'Georgetown', utl.split_string_strarray('',','), 'Americas' from dual union all
select 'AUS', 'Australia', 'Australia', 'AU', '036', 'Canberra', utl.split_string_strarray('AU',','), 'Oceania' from dual union all
select 'AUT', 'Austria', 'Österreich', 'AT', '040', 'Vienna', utl.split_string_strarray('AT,Österreich,Osterreich,Oesterreich',','), 'Europe' from dual union all
select 'AZE', 'Azerbaijan', 'Azərbaycan', 'AZ', '031', 'Baku', utl.split_string_strarray('AZ,Republic of Azerbaijan,Azərbaycan Respublikası',','), 'Asia' from dual union all
select 'BHS', 'Bahamas', 'Bahamas', 'BS', '044', 'Nassau', utl.split_string_strarray('BS,Commonwealth of the Bahamas',','), 'Americas' from dual union all
select 'BHR', 'Bahrain', '‏البحرين', 'BH', '048', 'Manama', utl.split_string_strarray('BH,Kingdom of Bahrain,Mamlakat al-Baḥrayn',','), 'Asia' from dual union all
select 'BGD', 'Bangladesh', 'Bangladesh', 'BD', '050', 'Dhaka', utl.split_string_strarray('BD,People''s Republic of Bangladesh,Gônôprôjatôntri Bangladesh',','), 'Asia' from dual union all
select 'BRB', 'Barbados', 'Barbados', 'BB', '052', 'Bridgetown', utl.split_string_strarray('BB',','), 'Americas' from dual union all
select 'BLR', 'Belarus', 'Белару́сь', 'BY', '112', 'Minsk', utl.split_string_strarray('BY,Bielaruś,Republic of Belarus,Белоруссия,Республика Беларусь,Belorussiya,Respublika Belarus’',','), 'Europe' from dual union all
select 'BEL', 'Belgium', 'België', 'BE', '056', 'Brussels', utl.split_string_strarray('BE,België,Belgie,Belgien,Belgique,Kingdom of Belgium,Koninkrijk België,Royaume de Belgique,Königreich Belgien',','), 'Europe' from dual union all
select 'BLZ', 'Belize', 'Belize', 'BZ', '084', 'Belmopan', utl.split_string_strarray('BZ',','), 'Americas' from dual union all
select 'BEN', 'Benin', 'Bénin', 'BJ', '204', 'Porto-Novo', utl.split_string_strarray('BJ,Republic of Benin,République du Bénin',','), 'Africa' from dual union all
select 'BMU', 'Bermuda', 'Bermuda', 'BM', '060', 'Hamilton', utl.split_string_strarray('BM,The Islands of Bermuda,The Bermudas,Somers Isles',','), 'Americas' from dual union all
select 'BTN', 'Bhutan', 'ʼbrug-yul', 'BT', '064', 'Thimphu', utl.split_string_strarray('BT,Kingdom of Bhutan',','), 'Asia' from dual union all
select 'BOL', 'Bolivia', 'Bolivia', 'BO', '068', 'Sucre', utl.split_string_strarray('BO,Buliwya,Wuliwya,Plurinational State of Bolivia,Estado Plurinacional de Bolivia,Buliwya Mamallaqta,Wuliwya Suyu,Tetã Volívia',','), 'Americas' from dual union all
select 'BES', 'Bonaire', 'Bonaire', 'BQ', '535', 'Kralendijk', utl.split_string_strarray('BQ,Boneiru',','), 'Americas' from dual union all
select 'BIH', 'Bosnia and Herzegovina', 'Bosna i Hercegovina', 'BA', '070', 'Sarajevo', utl.split_string_strarray('BA,Bosnia-Herzegovina,Босна и Херцеговина',','), 'Europe' from dual union all
select 'BWA', 'Botswana', 'Botswana', 'BW', '072', 'Gaborone', utl.split_string_strarray('BW,Republic of Botswana,Lefatshe la Botswana',','), 'Africa' from dual union all
select 'BVT', 'Bouvet Island', 'Bouvetøya', 'BV', '074', '', utl.split_string_strarray('BV,Bouvetøya,Bouvet-øya',','), '' from dual union all
select 'BRA', 'Brazil', 'Brasil', 'BR', '076', 'Brasília', utl.split_string_strarray('BR,Brasil,Federative Republic of Brazil,República Federativa do Brasil',','), 'Americas' from dual union all
select 'IOT', 'British Indian Ocean Territory', 'British Indian Ocean Territory', 'IO', '086', 'Diego Garcia', utl.split_string_strarray('IO',','), 'Africa' from dual union all
select 'VGB', 'British Virgin Islands', 'British Virgin Islands', 'VG', '092', 'Road Town', utl.split_string_strarray('VG',','), 'Americas' from dual union all
select 'BRN', 'Brunei', 'Negara Brunei Darussalam', 'BN', '096', 'Bandar Seri Begawan', utl.split_string_strarray('BN,Nation of Brunei, the Abode of Peace',','), 'Asia' from dual union all
select 'BGR', 'Bulgaria', 'България', 'BG', '100', 'Sofia', utl.split_string_strarray('BG,Republic of Bulgaria,Република България',','), 'Europe' from dual union all
select 'BFA', 'Burkina Faso', 'Burkina Faso', 'BF', '854', 'Ouagadougou', utl.split_string_strarray('BF',','), 'Africa' from dual union all
select 'BDI', 'Burundi', 'Burundi', 'BI', '108', 'Bujumbura', utl.split_string_strarray('BI,Republic of Burundi,Republika y''Uburundi,République du Burundi',','), 'Africa' from dual union all
select 'KHM', 'Cambodia', 'Kâmpŭchéa', 'KH', '116', 'Phnom Penh', utl.split_string_strarray('KH,Kingdom of Cambodia',','), 'Asia' from dual union all
select 'CMR', 'Cameroon', 'Cameroon', 'CM', '120', 'Yaoundé', utl.split_string_strarray('CM,Republic of Cameroon,République du Cameroun',','), 'Africa' from dual union all
select 'CAN', 'Canada', 'Canada', 'CA', '124', 'Ottawa', utl.split_string_strarray('CA',','), 'Americas' from dual union all
select 'CPV', 'Cape Verde', 'Cabo Verde', 'CV', '132', 'Praia', utl.split_string_strarray('CV,Republic of Cabo Verde,República de Cabo Verde',','), 'Africa' from dual union all
select 'CYM', 'Cayman Islands', 'Cayman Islands', 'KY', '136', 'George Town', utl.split_string_strarray('KY',','), 'Americas' from dual union all
select 'CAF', 'Central African Republic', 'Ködörösêse tî Bêafrîka', 'CF', '140', 'Bangui', utl.split_string_strarray('CF,Central African Republic,République centrafricaine',','), 'Africa' from dual union all
select 'TCD', 'Chad', 'Tchad', 'TD', '148', 'N''Djamena', utl.split_string_strarray('TD,Tchad,Republic of Chad,République du Tchad',','), 'Africa' from dual union all
select 'CHL', 'Chile', 'Chile', 'CL', '152', 'Santiago', utl.split_string_strarray('CL,Republic of Chile,República de Chile',','), 'Americas' from dual union all
select 'CHN', 'China', '中国', 'CN', '156', 'Beijing', utl.split_string_strarray('CN,Zhōngguó,Zhongguo,Zhonghua,People''s Republic of China,中华人民共和国,Zhōnghuá Rénmín Gònghéguó',','), 'Asia' from dual union all
select 'CXR', 'Christmas Island', 'Christmas Island', 'CX', '162', 'Flying Fish Cove', utl.split_string_strarray('CX,Territory of Christmas Island',','), 'Oceania' from dual union all
select 'CCK', 'Cocos (Keeling) Islands', 'Cocos (Keeling) Islands', 'CC', '166', 'West Island', utl.split_string_strarray('CC,Territory of the Cocos (Keeling) Islands,Keeling Islands',','), 'Oceania' from dual union all
select 'COL', 'Colombia', 'Colombia', 'CO', '170', 'Bogotá', utl.split_string_strarray('CO,Republic of Colombia,República de Colombia',','), 'Americas' from dual union all
select 'HUN', 'Hungary', 'Magyarország', 'HU', '348', 'Budapest', utl.split_string_strarray('HU',','), 'Europe' from dual union all
select 'COM', 'Comoros', 'Komori', 'KM', '174', 'Moroni', utl.split_string_strarray('KM,Union of the Comoros,Union des Comores,Udzima wa Komori,al-Ittiḥād al-Qumurī',','), 'Africa' from dual union all
select 'COG', 'Republic of the Congo', 'République du Congo', 'CG', '178', 'Brazzaville', utl.split_string_strarray('CG,Congo-Brazzaville',','), 'Africa' from dual union all
select 'COD', 'Democratic Republic of the Congo', 'République démocratique du Congo', 'CD', '180', 'Kinshasa', utl.split_string_strarray('CD,DR Congo,Congo-Kinshasa,DRC',','), 'Africa' from dual union all
select 'COK', 'Cook Islands', 'Cook Islands', 'CK', '184', 'Avarua', utl.split_string_strarray('CK,Kūki ''Āirani',','), 'Oceania' from dual union all
select 'CRI', 'Costa Rica', 'Costa Rica', 'CR', '188', 'San José', utl.split_string_strarray('CR,Republic of Costa Rica,República de Costa Rica',','), 'Americas' from dual union all
select 'HRV', 'Croatia', 'Hrvatska', 'HR', '191', 'Zagreb', utl.split_string_strarray('HR,Hrvatska,Republic of Croatia,Republika Hrvatska',','), 'Europe' from dual union all
select 'CUB', 'Cuba', 'Cuba', 'CU', '192', 'Havana', utl.split_string_strarray('CU,Republic of Cuba,República de Cuba',','), 'Americas' from dual union all
select 'CUW', 'Curaçao', 'Curaçao', 'CW', '531', 'Willemstad', utl.split_string_strarray('CW,Curacao,Kòrsou,Country of Curaçao,Land Curaçao,Pais Kòrsou',','), 'Americas' from dual union all
select 'CYP', 'Cyprus', 'Κύπρος', 'CY', '196', 'Nicosia', utl.split_string_strarray('CY,Kýpros,Kıbrıs,Republic of Cyprus,Κυπριακή Δημοκρατία,Kıbrıs Cumhuriyeti',','), 'Europe' from dual union all
select 'CZE', 'Czech Republic', 'Česká republika', 'CZ', '203', 'Prague', utl.split_string_strarray('CZ,Česká republika,Česko',','), 'Europe' from dual union all
select 'DNK', 'Denmark', 'Danmark', 'DK', '208', 'Copenhagen', utl.split_string_strarray('DK,Danmark,Kingdom of Denmark,Kongeriget Danmark',','), 'Europe' from dual union all
select 'DJI', 'Djibouti', 'Djibouti', 'DJ', '262', 'Djibouti', utl.split_string_strarray('DJ,Jabuuti,Gabuuti,Republic of Djibouti,République de Djibouti,Gabuutih Ummuuno,Jamhuuriyadda Jabuuti',','), 'Africa' from dual union all
select 'DMA', 'Dominica', 'Dominica', 'DM', '212', 'Roseau', utl.split_string_strarray('DM,Dominique,Wai‘tu kubuli,Commonwealth of Dominica',','), 'Americas' from dual union all
select 'DOM', 'Dominican Republic', 'República Dominicana', 'DO', '214', 'Santo Domingo', utl.split_string_strarray('DO',','), 'Americas' from dual union all
select 'ECU', 'Ecuador', 'Ecuador', 'EC', '218', 'Quito', utl.split_string_strarray('EC,Republic of Ecuador,República del Ecuador',','), 'Americas' from dual union all
select 'EGY', 'Egypt', 'مصر‎', 'EG', '818', 'Cairo', utl.split_string_strarray('EG,Arab Republic of Egypt',','), 'Africa' from dual union all
select 'SLV', 'El Salvador', 'El Salvador', 'SV', '222', 'San Salvador', utl.split_string_strarray('SV,Republic of El Salvador,República de El Salvador',','), 'Americas' from dual union all
select 'GNQ', 'Equatorial Guinea', 'Guinea Ecuatorial', 'GQ', '226', 'Malabo', utl.split_string_strarray('GQ,Republic of Equatorial Guinea,República de Guinea Ecuatorial,République de Guinée équatoriale,República da Guiné Equatorial',','), 'Africa' from dual union all
select 'ERI', 'Eritrea', 'ኤርትራ', 'ER', '232', 'Asmara', utl.split_string_strarray('ER,State of Eritrea,ሃገረ ኤርትራ,Dawlat Iritriyá,ʾErtrā,Iritriyā',','), 'Africa' from dual union all
select 'EST', 'Estonia', 'Eesti', 'EE', '233', 'Tallinn', utl.split_string_strarray('EE,Eesti,Republic of Estonia,Eesti Vabariik',','), 'Europe' from dual union all
select 'ETH', 'Ethiopia', 'ኢትዮጵያ', 'ET', '231', 'Addis Ababa', utl.split_string_strarray('ET,ʾĪtyōṗṗyā,Federal Democratic Republic of Ethiopia,የኢትዮጵያ ፌዴራላዊ ዲሞክራሲያዊ ሪፐብሊክ',','), 'Africa' from dual union all
select 'FLK', 'Falkland Islands', 'Falkland Islands', 'FK', '238', 'Stanley', utl.split_string_strarray('FK,Islas Malvinas',','), 'Americas' from dual union all
select 'FRO', 'Faroe Islands', 'Føroyar', 'FO', '234', 'Tórshavn', utl.split_string_strarray('FO,Føroyar,Færøerne',','), 'Europe' from dual union all
select 'FJI', 'Fiji', 'Fiji', 'FJ', '242', 'Suva', utl.split_string_strarray('FJ,Viti,Republic of Fiji,Matanitu ko Viti,Fijī Gaṇarājya',','), 'Oceania' from dual union all
select 'FIN', 'Finland', 'Suomi', 'FI', '246', 'Helsinki', utl.split_string_strarray('FI,Suomi,Republic of Finland,Suomen tasavalta,Republiken Finland',','), 'Europe' from dual union all
select 'FRA', 'France', 'France', 'FR', '250', 'Paris', utl.split_string_strarray('FR,French Republic,République française',','), 'Europe' from dual union all
select 'GUF', 'French Guiana', 'Guyane française', 'GF', '254', 'Cayenne', utl.split_string_strarray('GF,Guiana,Guyane',','), 'Americas' from dual union all
select 'PYF', 'French Polynesia', 'Polynésie française', 'PF', '258', 'Papeetē', utl.split_string_strarray('PF,Polynésie française,French Polynesia,Pōrīnetia Farāni',','), 'Oceania' from dual union all
select 'ATF', 'French Southern and Antarctic Lands', 'Territoire des Terres australes et antarctiques françaises', 'TF', '260', 'Port-aux-Français', utl.split_string_strarray('TF',','), '' from dual union all
select 'GAB', 'Gabon', 'Gabon', 'GA', '266', 'Libreville', utl.split_string_strarray('GA,Gabonese Republic,République Gabonaise',','), 'Africa' from dual union all
select 'GMB', 'Gambia', 'Gambia', 'GM', '270', 'Banjul', utl.split_string_strarray('GM,Republic of the Gambia',','), 'Africa' from dual union all
select 'GEO', 'Georgia', 'საქართველო', 'GE', '268', 'Tbilisi', utl.split_string_strarray('GE,Sakartvelo',','), 'Asia' from dual union all
select 'DEU', 'Germany', 'Deutschland', 'DE', '276', 'Berlin', utl.split_string_strarray('DE,Federal Republic of Germany,Bundesrepublik Deutschland',','), 'Europe' from dual union all
select 'GHA', 'Ghana', 'Ghana', 'GH', '288', 'Accra', utl.split_string_strarray('GH',','), 'Africa' from dual union all
select 'GIB', 'Gibraltar', 'Gibraltar', 'GI', '292', 'Gibraltar', utl.split_string_strarray('GI',','), 'Europe' from dual union all
select 'GRC', 'Greece', 'Ελλάδα', 'GR', '300', 'Athens', utl.split_string_strarray('GR,Elláda,Hellenic Republic,Ελληνική Δημοκρατία',','), 'Europe' from dual union all
select 'GRL', 'Greenland', 'Kalaallit Nunaat', 'GL', '304', 'Nuuk', utl.split_string_strarray('GL,Grønland',','), 'Americas' from dual union all
select 'GRD', 'Grenada', 'Grenada', 'GD', '308', 'St. George''s', utl.split_string_strarray('GD',','), 'Americas' from dual union all
select 'GLP', 'Guadeloupe', 'Guadeloupe', 'GP', '312', 'Basse-Terre', utl.split_string_strarray('GP,Gwadloup',','), 'Americas' from dual union all
select 'GUM', 'Guam', 'Guam', 'GU', '316', 'Hagåtña', utl.split_string_strarray('GU,Guåhån',','), 'Oceania' from dual union all
select 'GTM', 'Guatemala', 'Guatemala', 'GT', '320', 'Guatemala City', utl.split_string_strarray('GT',','), 'Americas' from dual union all
select 'GGY', 'Guernsey', 'Guernsey', 'GG', '831', 'St. Peter Port', utl.split_string_strarray('GG,Bailiwick of Guernsey,Bailliage de Guernesey',','), 'Europe' from dual union all
select 'GIN', 'Guinea', 'Guinée', 'GN', '324', 'Conakry', utl.split_string_strarray('GN,Republic of Guinea,République de Guinée',','), 'Africa' from dual union all
select 'GNB', 'Guinea-Bissau', 'Guiné-Bissau', 'GW', '624', 'Bissau', utl.split_string_strarray('GW,Republic of Guinea-Bissau,República da Guiné-Bissau',','), 'Africa' from dual union all
select 'GUY', 'Guyana', 'Guyana', 'GY', '328', 'Georgetown', utl.split_string_strarray('GY,Co-operative Republic of Guyana',','), 'Americas' from dual union all
select 'HTI', 'Haiti', 'Haïti', 'HT', '332', 'Port-au-Prince', utl.split_string_strarray('HT,Republic of Haiti,République d''Haïti,Repiblik Ayiti',','), 'Americas' from dual union all
select 'HMD', 'Heard Island and McDonald Islands', 'Heard Island and McDonald Islands', 'HM', '334', '', utl.split_string_strarray('HM',','), '' from dual union all
select 'VAT', 'Vatican City', 'Vaticano', 'VA', '336', 'Vatican City', utl.split_string_strarray('VA,Vatican City State,Stato della Città del Vaticano',','), 'Europe' from dual union all
select 'HND', 'Honduras', 'Honduras', 'HN', '340', 'Tegucigalpa', utl.split_string_strarray('HN,Republic of Honduras,República de Honduras',','), 'Americas' from dual union all
select 'HKG', 'Hong Kong', '香港', 'HK', '344', 'City of Victoria', utl.split_string_strarray('HK',','), 'Asia' from dual union all
select 'ISL', 'Iceland', 'Ísland', 'IS', '352', 'Reykjavik', utl.split_string_strarray('IS,Island,Republic of Iceland,Lýðveldið Ísland',','), 'Europe' from dual union all
select 'IND', 'India', 'भारत', 'IN', '356', 'New Delhi', utl.split_string_strarray('IN,Bhārat,Republic of India,Bharat Ganrajya',','), 'Asia' from dual union all
select 'IDN', 'Indonesia', 'Indonesia', 'ID', '360', 'Jakarta', utl.split_string_strarray('ID,Republic of Indonesia,Republik Indonesia',','), 'Asia' from dual union all
select 'CIV', 'Ivory Coast', 'Côte d''Ivoire', 'CI', '384', 'Yamoussoukro', utl.split_string_strarray('CI,Ivory Coast,Republic of Côte d''Ivoire,République de Côte d''Ivoire',','), 'Africa' from dual union all
select 'IRN', 'Iran', 'Irān', 'IR', '364', 'Tehran', utl.split_string_strarray('IR,Islamic Republic of Iran,Jomhuri-ye Eslāmi-ye Irān',','), 'Asia' from dual union all
select 'IRQ', 'Iraq', 'العراق', 'IQ', '368', 'Baghdad', utl.split_string_strarray('IQ,Republic of Iraq,Jumhūriyyat al-‘Irāq',','), 'Asia' from dual union all
select 'IRL', 'Ireland', 'Éire', 'IE', '372', 'Dublin', utl.split_string_strarray('IE,Éire,Republic of Ireland,Poblacht na hÉireann',','), 'Europe' from dual union all
select 'IMN', 'Isle of Man', 'Isle of Man', 'IM', '833', 'Douglas', utl.split_string_strarray('IM,Ellan Vannin,Mann,Mannin',','), 'Europe' from dual union all
select 'ISR', 'Israel', 'יִשְׂרָאֵל', 'IL', '376', 'Jerusalem', utl.split_string_strarray('IL,State of Israel,Medīnat Yisrā''el',','), 'Asia' from dual union all
select 'ITA', 'Italy', 'Italia', 'IT', '380', 'Rome', utl.split_string_strarray('IT,Italian Republic,Repubblica italiana',','), 'Europe' from dual union all
select 'JAM', 'Jamaica', 'Jamaica', 'JM', '388', 'Kingston', utl.split_string_strarray('JM',','), 'Americas' from dual union all
select 'JPN', 'Japan', '日本', 'JP', '392', 'Tokyo', utl.split_string_strarray('JP,Nippon,Nihon',','), 'Asia' from dual union all
select 'JEY', 'Jersey', 'Jersey', 'JE', '832', 'Saint Helier', utl.split_string_strarray('JE,Bailiwick of Jersey,Bailliage de Jersey,Bailliage dé Jèrri',','), 'Europe' from dual union all
select 'JOR', 'Jordan', 'الأردن', 'JO', '400', 'Amman', utl.split_string_strarray('JO,Hashemite Kingdom of Jordan,al-Mamlakah al-Urdunīyah al-Hāshimīyah',','), 'Asia' from dual union all
select 'KAZ', 'Kazakhstan', 'Қазақстан', 'KZ', '398', 'Astana', utl.split_string_strarray('KZ,Qazaqstan,Казахстан,Republic of Kazakhstan,Қазақстан Республикасы,Qazaqstan Respublïkası,Республика Казахстан,Respublika Kazakhstan',','), 'Asia' from dual union all
select 'KEN', 'Kenya', 'Kenya', 'KE', '404', 'Nairobi', utl.split_string_strarray('KE,Republic of Kenya,Jamhuri ya Kenya',','), 'Africa' from dual union all
select 'KIR', 'Kiribati', 'Kiribati', 'KI', '296', 'South Tarawa', utl.split_string_strarray('KI,Republic of Kiribati,Ribaberiki Kiribati',','), 'Oceania' from dual union all
select 'KWT', 'Kuwait', 'الكويت', 'KW', '414', 'Kuwait City', utl.split_string_strarray('KW,State of Kuwait,Dawlat al-Kuwait',','), 'Asia' from dual union all
select 'KGZ', 'Kyrgyzstan', 'Кыргызстан', 'KG', '417', 'Bishkek', utl.split_string_strarray('KG,Киргизия,Kyrgyz Republic,Кыргыз Республикасы,Kyrgyz Respublikasy',','), 'Asia' from dual union all
select 'LAO', 'Laos', 'ສປປລາວ', 'LA', '418', 'Vientiane', utl.split_string_strarray('LA,Lao,Lao People''s Democratic Republic,Sathalanalat Paxathipatai Paxaxon Lao',','), 'Asia' from dual union all
select 'LVA', 'Latvia', 'Latvija', 'LV', '428', 'Riga', utl.split_string_strarray('LV,Republic of Latvia,Latvijas Republika',','), 'Europe' from dual union all
select 'LBN', 'Lebanon', 'لبنان', 'LB', '422', 'Beirut', utl.split_string_strarray('LB,Lebanese Republic,Al-Jumhūrīyah Al-Libnānīyah',','), 'Asia' from dual union all
select 'LSO', 'Lesotho', 'Lesotho', 'LS', '426', 'Maseru', utl.split_string_strarray('LS,Kingdom of Lesotho,Muso oa Lesotho',','), 'Africa' from dual union all
select 'LBR', 'Liberia', 'Liberia', 'LR', '430', 'Monrovia', utl.split_string_strarray('LR,Republic of Liberia',','), 'Africa' from dual union all
select 'LBY', 'Libya', '‏ليبيا', 'LY', '434', 'Tripoli', utl.split_string_strarray('LY,State of Libya,Dawlat Libya',','), 'Africa' from dual union all
select 'LIE', 'Liechtenstein', 'Liechtenstein', 'LI', '438', 'Vaduz', utl.split_string_strarray('LI,Principality of Liechtenstein,Fürstentum Liechtenstein',','), 'Europe' from dual union all
select 'LTU', 'Lithuania', 'Lietuva', 'LT', '440', 'Vilnius', utl.split_string_strarray('LT,Republic of Lithuania,Lietuvos Respublika',','), 'Europe' from dual union all
select 'LUX', 'Luxembourg', 'Luxembourg', 'LU', '442', 'Luxembourg', utl.split_string_strarray('LU,Grand Duchy of Luxembourg,Grand-Duché de Luxembourg,Großherzogtum Luxemburg,Groussherzogtum Lëtzebuerg',','), 'Europe' from dual union all
select 'MAC', 'Macau', '澳門', 'MO', '446', '', utl.split_string_strarray('MO,澳门,Macao Special Administrative Region of the People''s Republic of China,中華人民共和國澳門特別行政區,Região Administrativa Especial de Macau da República Popular da China',','), 'Asia' from dual union all
select 'MKD', 'Macedonia', 'Македонија', 'MK', '807', 'Skopje', utl.split_string_strarray('MK,Republic of Macedonia,Република Македонија',','), 'Europe' from dual union all
select 'MDG', 'Madagascar', 'Madagasikara', 'MG', '450', 'Antananarivo', utl.split_string_strarray('MG,Republic of Madagascar,Repoblikan''i Madagasikara,République de Madagascar',','), 'Africa' from dual union all
select 'MWI', 'Malawi', 'Malawi', 'MW', '454', 'Lilongwe', utl.split_string_strarray('MW,Republic of Malawi',','), 'Africa' from dual union all
select 'MYS', 'Malaysia', 'Malaysia', 'MY', '458', 'Kuala Lumpur', utl.split_string_strarray('MY',','), 'Asia' from dual union all
select 'MDV', 'Maldives', 'Maldives', 'MV', '462', 'Malé', utl.split_string_strarray('MV,Maldive Islands,Republic of the Maldives,Dhivehi Raajjeyge Jumhooriyya',','), 'Asia' from dual union all
select 'MLI', 'Mali', 'Mali', 'ML', '466', 'Bamako', utl.split_string_strarray('ML,Republic of Mali,République du Mali',','), 'Africa' from dual union all
select 'MLT', 'Malta', 'Malta', 'MT', '470', 'Valletta', utl.split_string_strarray('MT,Republic of Malta,Repubblika ta'' Malta',','), 'Europe' from dual union all
select 'MHL', 'Marshall Islands', 'M̧ajeļ', 'MH', '584', 'Majuro', utl.split_string_strarray('MH,Republic of the Marshall Islands,Aolepān Aorōkin M̧ajeļ',','), 'Oceania' from dual union all
select 'MTQ', 'Martinique', 'Martinique', 'MQ', '474', 'Fort-de-France', utl.split_string_strarray('MQ',','), 'Americas' from dual union all
select 'MRT', 'Mauritania', 'موريتانيا', 'MR', '478', 'Nouakchott', utl.split_string_strarray('MR,Islamic Republic of Mauritania,al-Jumhūriyyah al-ʾIslāmiyyah al-Mūrītāniyyah',','), 'Africa' from dual union all
select 'MUS', 'Mauritius', 'Maurice', 'MU', '480', 'Port Louis', utl.split_string_strarray('MU,Republic of Mauritius,République de Maurice',','), 'Africa' from dual union all
select 'MYT', 'Mayotte', 'Mayotte', 'YT', '175', 'Mamoudzou', utl.split_string_strarray('YT,Department of Mayotte,Département de Mayotte',','), 'Africa' from dual union all
select 'MEX', 'Mexico', 'México', 'MX', '484', 'Mexico City', utl.split_string_strarray('MX,Mexicanos,United Mexican States,Estados Unidos Mexicanos',','), 'Americas' from dual union all
select 'FSM', 'Micronesia', 'Micronesia', 'FM', '583', 'Palikir', utl.split_string_strarray('FM,Federated States of Micronesia',','), 'Oceania' from dual union all
select 'MDA', 'Moldova', 'Moldova', 'MD', '498', 'Chișinău', utl.split_string_strarray('MD,Republic of Moldova,Republica Moldova',','), 'Europe' from dual union all
select 'MCO', 'Monaco', 'Monaco', 'MC', '492', 'Monaco', utl.split_string_strarray('MC,Principality of Monaco,Principauté de Monaco',','), 'Europe' from dual union all
select 'MNG', 'Mongolia', 'Монгол улс', 'MN', '496', 'Ulan Bator', utl.split_string_strarray('MN',','), 'Asia' from dual union all
select 'MNE', 'Montenegro', 'Црна Гора', 'ME', '499', 'Podgorica', utl.split_string_strarray('ME,Crna Gora',','), 'Europe' from dual union all
select 'MSR', 'Montserrat', 'Montserrat', 'MS', '500', 'Plymouth', utl.split_string_strarray('MS',','), 'Americas' from dual union all
select 'MAR', 'Morocco', 'المغرب', 'MA', '504', 'Rabat', utl.split_string_strarray('MA,Kingdom of Morocco,Al-Mamlakah al-Maġribiyah',','), 'Africa' from dual union all
select 'MOZ', 'Mozambique', 'Moçambique', 'MZ', '508', 'Maputo', utl.split_string_strarray('MZ,Republic of Mozambique,República de Moçambique',','), 'Africa' from dual union all
select 'MMR', 'Myanmar', 'Myanma', 'MM', '104', 'Naypyidaw', utl.split_string_strarray('MM,Burma,Republic of the Union of Myanmar,Pyidaunzu Thanmăda Myăma Nainngandaw',','), 'Asia' from dual union all
select 'NAM', 'Namibia', 'Namibia', 'NA', '516', 'Windhoek', utl.split_string_strarray('NA,Namibië,Republic of Namibia',','), 'Africa' from dual union all
select 'NRU', 'Nauru', 'Nauru', 'NR', '520', 'Yaren', utl.split_string_strarray('NR,Naoero,Pleasant Island,Republic of Nauru,Ripublik Naoero',','), 'Oceania' from dual union all
select 'NPL', 'Nepal', 'नपल', 'NP', '524', 'Kathmandu', utl.split_string_strarray('NP,Federal Democratic Republic of Nepal,Loktāntrik Ganatantra Nepāl',','), 'Asia' from dual union all
select 'NLD', 'Netherlands', 'Nederland', 'NL', '528', 'Amsterdam', utl.split_string_strarray('NL,Holland,Nederland',','), 'Europe' from dual union all
select 'NCL', 'New Caledonia', 'Nouvelle-Calédonie', 'NC', '540', 'Nouméa', utl.split_string_strarray('NC',','), 'Oceania' from dual union all
select 'NZL', 'New Zealand', 'New Zealand', 'NZ', '554', 'Wellington', utl.split_string_strarray('NZ,Aotearoa',','), 'Oceania' from dual union all
select 'NIC', 'Nicaragua', 'Nicaragua', 'NI', '558', 'Managua', utl.split_string_strarray('NI,Republic of Nicaragua,República de Nicaragua',','), 'Americas' from dual union all
select 'NER', 'Niger', 'Niger', 'NE', '562', 'Niamey', utl.split_string_strarray('NE,Nijar,Republic of Niger,République du Niger',','), 'Africa' from dual union all
select 'NGA', 'Nigeria', 'Nigeria', 'NG', '566', 'Abuja', utl.split_string_strarray('NG,Nijeriya,Naíjíríà,Federal Republic of Nigeria',','), 'Africa' from dual union all
select 'NIU', 'Niue', 'Niuē', 'NU', '570', 'Alofi', utl.split_string_strarray('NU',','), 'Oceania' from dual union all
select 'NFK', 'Norfolk Island', 'Norfolk Island', 'NF', '574', 'Kingston', utl.split_string_strarray('NF,Territory of Norfolk Island,Teratri of Norf''k Ailen',','), 'Oceania' from dual union all
select 'PRK', 'North Korea', '북한', 'KP', '408', 'Pyongyang', utl.split_string_strarray('KP,Democratic People''s Republic of Korea,조선민주주의인민공화국,Chosŏn Minjujuŭi Inmin Konghwaguk',','), 'Asia' from dual union all
select 'ROU', 'Romania', 'România', 'RO', '642', 'Bucharest', utl.split_string_strarray('RO,Rumania,Roumania,România',','), 'Europe' from dual union all
select 'MNP', 'Northern Mariana Islands', 'Northern Mariana Islands', 'MP', '580', 'Saipan', utl.split_string_strarray('MP,Commonwealth of the Northern Mariana Islands,Sankattan Siha Na Islas Mariånas',','), 'Oceania' from dual union all
select 'NOR', 'Norway', 'Norge', 'NO', '578', 'Oslo', utl.split_string_strarray('NO,Norge,Noreg,Kingdom of Norway,Kongeriket Norge,Kongeriket Noreg',','), 'Europe' from dual union all
select 'OMN', 'Oman', 'عمان', 'OM', '512', 'Muscat', utl.split_string_strarray('OM,Sultanate of Oman,Salṭanat ʻUmān',','), 'Asia' from dual union all
select 'PAK', 'Pakistan', 'Pakistan', 'PK', '586', 'Islamabad', utl.split_string_strarray('PK,Pākistān,Islamic Republic of Pakistan,Islāmī Jumhūriya''eh Pākistān',','), 'Asia' from dual union all
select 'PLW', 'Palau', 'Palau', 'PW', '585', 'Ngerulmud', utl.split_string_strarray('PW,Republic of Palau,Beluu er a Belau',','), 'Oceania' from dual union all
select 'PSE', 'Palestine', 'فلسطين', 'PS', '275', 'Ramallah', utl.split_string_strarray('PS,State of Palestine,Dawlat Filasṭin',','), 'Asia' from dual union all
select 'PAN', 'Panama', 'Panamá', 'PA', '591', 'Panama City', utl.split_string_strarray('PA,Republic of Panama,República de Panamá',','), 'Americas' from dual union all
select 'PNG', 'Papua New Guinea', 'Papua Niugini', 'PG', '598', 'Port Moresby', utl.split_string_strarray('PG,Independent State of Papua New Guinea,Independen Stet bilong Papua Niugini',','), 'Oceania' from dual union all
select 'PRY', 'Paraguay', 'Paraguay', 'PY', '600', 'Asunción', utl.split_string_strarray('PY,Republic of Paraguay,República del Paraguay,Tetã Paraguái',','), 'Americas' from dual union all
select 'PER', 'Peru', 'Perú', 'PE', '604', 'Lima', utl.split_string_strarray('PE,Republic of Peru, República del Perú',','), 'Americas' from dual union all
select 'PHL', 'Philippines', 'Pilipinas', 'PH', '608', 'Manila', utl.split_string_strarray('PH,Republic of the Philippines,Repúblika ng Pilipinas',','), 'Asia' from dual union all
select 'PCN', 'Pitcairn Islands', 'Pitcairn Islands', 'PN', '612', 'Adamstown', utl.split_string_strarray('PN,Pitcairn Henderson Ducie and Oeno Islands',','), 'Oceania' from dual union all
select 'POL', 'Poland', 'Polska', 'PL', '616', 'Warsaw', utl.split_string_strarray('PL,Republic of Poland,Rzeczpospolita Polska',','), 'Europe' from dual union all
select 'PRT', 'Portugal', 'Portugal', 'PT', '620', 'Lisbon', utl.split_string_strarray('PT,Portuguesa,Portuguese Republic,República Portuguesa',','), 'Europe' from dual union all
select 'PRI', 'Puerto Rico', 'Puerto Rico', 'PR', '630', 'San Juan', utl.split_string_strarray('PR,Commonwealth of Puerto Rico,Estado Libre Asociado de Puerto Rico',','), 'Americas' from dual union all
select 'QAT', 'Qatar', 'قطر', 'QA', '634', 'Doha', utl.split_string_strarray('QA,State of Qatar,Dawlat Qaṭar',','), 'Asia' from dual union all
select 'KOS', 'Republic of Kosovo', 'Republika e Kosovës', 'XK', 'KOS', 'Pristina', utl.split_string_strarray('XK,Република Косово',','), 'Europe' from dual union all
select 'REU', 'Réunion', 'La Réunion', 'RE', '638', 'Saint-Denis', utl.split_string_strarray('RE,Reunion',','), 'Africa' from dual union all
select 'RUS', 'Russia', 'Россия', 'RU', '643', 'Moscow', utl.split_string_strarray('RU,Rossiya,Russian Federation,Российская Федерация,Rossiyskaya Federatsiya',','), 'Europe' from dual union all
select 'RWA', 'Rwanda', 'Rwanda', 'RW', '646', 'Kigali', utl.split_string_strarray('RW,Republic of Rwanda,Repubulika y''u Rwanda,République du Rwanda',','), 'Africa' from dual union all
select 'BLM', 'Saint Barthélemy', 'Saint-Barthélemy', 'BL', '652', 'Gustavia', utl.split_string_strarray('BL,St. Barthelemy,Collectivity of Saint Barthélemy,Collectivité de Saint-Barthélemy',','), 'Americas' from dual union all
select 'SHN', 'Saint Helena', 'Saint Helena', 'SH', 'SHN', 'Jamestown', utl.split_string_strarray('SH',','), 'Africa' from dual union all
select 'KNA', 'Saint Kitts and Nevis', 'Saint Kitts and Nevis', 'KN', '659', 'Basseterre', utl.split_string_strarray('KN,Federation of Saint Christopher and Nevis',','), 'Americas' from dual union all
select 'LCA', 'Saint Lucia', 'Saint Lucia', 'LC', '662', 'Castries', utl.split_string_strarray('LC',','), 'Americas' from dual union all
select 'MAF', 'Saint Martin', 'Saint-Martin', 'MF', '663', 'Marigot', utl.split_string_strarray('MF,Collectivity of Saint Martin,Collectivité de Saint-Martin',','), 'Americas' from dual union all
select 'SPM', 'Saint Pierre and Miquelon', 'Saint-Pierre-et-Miquelon', 'PM', '666', 'Saint-Pierre', utl.split_string_strarray('PM,Collectivité territoriale de Saint-Pierre-et-Miquelon',','), 'Americas' from dual union all
select 'VCT', 'Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines', 'VC', '670', 'Kingstown', utl.split_string_strarray('VC',','), 'Americas' from dual union all
select 'WSM', 'Samoa', 'Samoa', 'WS', '882', 'Apia', utl.split_string_strarray('WS,Independent State of Samoa,Malo Saʻoloto Tutoʻatasi o Sāmoa',','), 'Oceania' from dual union all
select 'SMR', 'San Marino', 'San Marino', 'SM', '674', 'City of San Marino', utl.split_string_strarray('SM,Republic of San Marino,Repubblica di San Marino',','), 'Europe' from dual union all
select 'STP', 'São Tomé and Príncipe', 'São Tomé e Príncipe', 'ST', '678', 'São Tomé', utl.split_string_strarray('ST,Democratic Republic of São Tomé and Príncipe,República Democrática de São Tomé e Príncipe',','), 'Africa' from dual union all
select 'SAU', 'Saudi Arabia', 'العربية السعودية', 'SA', '682', 'Riyadh', utl.split_string_strarray('SA,Kingdom of Saudi Arabia,Al-Mamlakah al-‘Arabiyyah as-Su‘ūdiyyah',','), 'Asia' from dual union all
select 'SEN', 'Senegal', 'Sénégal', 'SN', '686', 'Dakar', utl.split_string_strarray('SN,Republic of Senegal,République du Sénégal',','), 'Africa' from dual union all
select 'SRB', 'Serbia', 'Србија', 'RS', '688', 'Belgrade', utl.split_string_strarray('RS,Srbija,Republic of Serbia,Република Србија,Republika Srbija',','), 'Europe' from dual union all
select 'SYC', 'Seychelles', 'Seychelles', 'SC', '690', 'Victoria', utl.split_string_strarray('SC,Republic of Seychelles,Repiblik Sesel,République des Seychelles',','), 'Africa' from dual union all
select 'SLE', 'Sierra Leone', 'Sierra Leone', 'SL', '694', 'Freetown', utl.split_string_strarray('SL,Republic of Sierra Leone',','), 'Africa' from dual union all
select 'SGP', 'Singapore', 'Singapore', 'SG', '702', 'Singapore', utl.split_string_strarray('SG,Singapura,Republik Singapura,新加坡共和国',','), 'Asia' from dual union all
select 'SXM', 'Sint Maarten', 'Sint Maarten', 'SX', '534', 'Philipsburg', utl.split_string_strarray('SX',','), 'Americas' from dual union all
select 'SVK', 'Slovakia', 'Slovensko', 'SK', '703', 'Bratislava', utl.split_string_strarray('SK,Slovak Republic,Slovenská republika',','), 'Europe' from dual union all
select 'SVN', 'Slovenia', 'Slovenija', 'SI', '705', 'Ljubljana', utl.split_string_strarray('SI,Republic of Slovenia,Republika Slovenija',','), 'Europe' from dual union all
select 'SLB', 'Solomon Islands', 'Solomon Islands', 'SB', '090', 'Honiara', utl.split_string_strarray('SB',','), 'Oceania' from dual union all
select 'SOM', 'Somalia', 'Soomaaliya', 'SO', '706', 'Mogadishu', utl.split_string_strarray('SO,aṣ-Ṣūmāl,Federal Republic of Somalia,Jamhuuriyadda Federaalka Soomaaliya,Jumhūriyyat aṣ-Ṣūmāl al-Fiderāliyya',','), 'Africa' from dual union all
select 'ZAF', 'South Africa', 'South Africa', 'ZA', '710', 'Pretoria', utl.split_string_strarray('ZA,RSA,Suid-Afrika,Republic of South Africa',','), 'Africa' from dual union all
select 'SGS', 'South Georgia', 'South Georgia', 'GS', '239', 'King Edward Point', utl.split_string_strarray('GS,South Georgia and the South Sandwich Islands',','), 'Americas' from dual union all
select 'KOR', 'South Korea', '대한민국', 'KR', '410', 'Seoul', utl.split_string_strarray('KR,Republic of Korea',','), 'Asia' from dual union all
select 'SSD', 'South Sudan', 'South Sudan', 'SS', '728', 'Juba', utl.split_string_strarray('SS',','), 'Africa' from dual union all
select 'ESP', 'Spain', 'España', 'ES', '724', 'Madrid', utl.split_string_strarray('ES,Kingdom of Spain,Reino de España',','), 'Europe' from dual union all
select 'LKA', 'Sri Lanka', 'śrī laṃkāva', 'LK', '144', 'Colombo', utl.split_string_strarray('LK,ilaṅkai,Democratic Socialist Republic of Sri Lanka',','), 'Asia' from dual union all
select 'SDN', 'Sudan', 'السودان', 'SD', '729', 'Khartoum', utl.split_string_strarray('SD,Republic of the Sudan,Jumhūrīyat as-Sūdān',','), 'Africa' from dual union all
select 'SUR', 'Suriname', 'Suriname', 'SR', '740', 'Paramaribo', utl.split_string_strarray('SR,Sarnam,Sranangron,Republic of Suriname,Republiek Suriname',','), 'Americas' from dual union all
select 'SJM', 'Svalbard and Jan Mayen', 'Svalbard og Jan Mayen', 'SJ', '744', 'Longyearbyen', utl.split_string_strarray('SJ,Svalbard and Jan Mayen Islands',','), 'Europe' from dual union all
select 'SWZ', 'Swaziland', 'Swaziland', 'SZ', '748', 'Lobamba', utl.split_string_strarray('SZ,weSwatini,Swatini,Ngwane,Kingdom of Swaziland,Umbuso waseSwatini',','), 'Africa' from dual union all
select 'SWE', 'Sweden', 'Sverige', 'SE', '752', 'Stockholm', utl.split_string_strarray('SE,Kingdom of Sweden,Konungariket Sverige',','), 'Europe' from dual union all
select 'CHE', 'Switzerland', 'Schweiz', 'CH', '756', 'Bern', utl.split_string_strarray('CH,Swiss Confederation,Schweiz,Suisse,Svizzera,Svizra',','), 'Europe' from dual union all
select 'SYR', 'Syria', 'سوريا', 'SY', '760', 'Damascus', utl.split_string_strarray('SY,Syrian Arab Republic,Al-Jumhūrīyah Al-ʻArabīyah As-Sūrīyah',','), 'Asia' from dual union all
select 'TWN', 'Taiwan', '臺灣', 'TW', '158', 'Taipei', utl.split_string_strarray('TW,Táiwān,Republic of China,中華民國,Zhōnghuá Mínguó',','), 'Asia' from dual union all
select 'TJK', 'Tajikistan', 'Тоҷикистон', 'TJ', '762', 'Dushanbe', utl.split_string_strarray('TJ,Toçikiston,Republic of Tajikistan,Ҷумҳурии Тоҷикистон,Çumhuriyi Toçikiston',','), 'Asia' from dual union all
select 'TZA', 'Tanzania', 'Tanzania', 'TZ', '834', 'Dodoma', utl.split_string_strarray('TZ,United Republic of Tanzania,Jamhuri ya Muungano wa Tanzania',','), 'Africa' from dual union all
select 'THA', 'Thailand', 'ประเทศไทย', 'TH', '764', 'Bangkok', utl.split_string_strarray('TH,Prathet,Thai,Kingdom of Thailand,ราชอาณาจักรไทย,Ratcha Anachak Thai',','), 'Asia' from dual union all
select 'TLS', 'Timor-Leste', 'Timor-Leste', 'TL', '626', 'Dili', utl.split_string_strarray('TL,East Timor,Democratic Republic of Timor-Leste,República Democrática de Timor-Leste,Repúblika Demokrátika Timór-Leste',','), 'Asia' from dual union all
select 'TGO', 'Togo', 'Togo', 'TG', '768', 'Lomé', utl.split_string_strarray('TG,Togolese,Togolese Republic,République Togolaise',','), 'Africa' from dual union all
select 'TKL', 'Tokelau', 'Tokelau', 'TK', '772', 'Fakaofo', utl.split_string_strarray('TK',','), 'Oceania' from dual union all
select 'TON', 'Tonga', 'Tonga', 'TO', '776', 'Nuku''alofa', utl.split_string_strarray('TO',','), 'Oceania' from dual union all
select 'TTO', 'Trinidad and Tobago', 'Trinidad and Tobago', 'TT', 'TTO', 'Port of Spain', utl.split_string_strarray('TT,Republic of Trinidad and Tobago',','), 'Americas' from dual union all
select 'TUN', 'Tunisia', 'تونس', 'TN', '788', 'Tunis', utl.split_string_strarray('TN,Republic of Tunisia,al-Jumhūriyyah at-Tūnisiyyah',','), 'Africa' from dual union all
select 'TUR', 'Turkey', 'Türkiye', 'TR', '792', 'Ankara', utl.split_string_strarray('TR,Turkiye,Republic of Turkey,Türkiye Cumhuriyeti',','), 'Asia' from dual union all
select 'TKM', 'Turkmenistan', 'Türkmenistan', 'TM', '795', 'Ashgabat', utl.split_string_strarray('TM',','), 'Asia' from dual union all
select 'TCA', 'Turks and Caicos Islands', 'Turks and Caicos Islands', 'TC', '796', 'Cockburn Town', utl.split_string_strarray('TC',','), 'Americas' from dual union all
select 'TUV', 'Tuvalu', 'Tuvalu', 'TV', '798', 'Funafuti', utl.split_string_strarray('TV',','), 'Oceania' from dual union all
select 'UGA', 'Uganda', 'Uganda', 'UG', '800', 'Kampala', utl.split_string_strarray('UG,Republic of Uganda,Jamhuri ya Uganda',','), 'Africa' from dual union all
select 'UKR', 'Ukraine', 'Україна', 'UA', '804', 'Kiev', utl.split_string_strarray('UA,Ukrayina',','), 'Europe' from dual union all
select 'ARE', 'United Arab Emirates', 'دولة الإمارات العربية المتحدة', 'AE', '784', 'Abu Dhabi', utl.split_string_strarray('AE,UAE',','), 'Asia' from dual union all
select 'GBR', 'United Kingdom', 'United Kingdom', 'GB', '826', 'London', utl.split_string_strarray('GB,UK,Great Britain',','), 'Europe' from dual union all
select 'USA', 'United States', 'United States', 'US', '840', 'Washington D.C.', utl.split_string_strarray('US,USA,United States of America',','), 'Americas' from dual union all
select 'UMI', 'United States Minor Outlying Islands', 'United States Minor Outlying Islands', 'UM', '581', '', utl.split_string_strarray('UM',','), 'Americas' from dual union all
select 'VIR', 'United States Virgin Islands', 'United States Virgin Islands', 'VI', '850', 'Charlotte Amalie', utl.split_string_strarray('VI',','), 'Americas' from dual union all
select 'URY', 'Uruguay', 'Uruguay', 'UY', '858', 'Montevideo', utl.split_string_strarray('UY,Oriental Republic of Uruguay,República Oriental del Uruguay',','), 'Americas' from dual union all
select 'UZB', 'Uzbekistan', 'O‘zbekiston', 'UZ', '860', 'Tashkent', utl.split_string_strarray('UZ,Republic of Uzbekistan,O‘zbekiston Respublikasi,Ўзбекистон Республикаси',','), 'Asia' from dual union all
select 'VUT', 'Vanuatu', 'Vanuatu', 'VU', '548', 'Port Vila', utl.split_string_strarray('VU,Republic of Vanuatu,Ripablik blong Vanuatu,République de Vanuatu',','), 'Oceania' from dual union all
select 'VEN', 'Venezuela', 'Venezuela', 'VE', '862', 'Caracas', utl.split_string_strarray('VE,Bolivarian Republic of Venezuela,República Bolivariana de Venezuela',','), 'Americas' from dual union all
select 'VNM', 'Vietnam', 'Việt Nam', 'VN', '704', 'Hanoi', utl.split_string_strarray('VN,Socialist Republic of Vietnam,Cộng hòa Xã hội chủ nghĩa Việt Nam',','), 'Asia' from dual union all
select 'WLF', 'Wallis and Futuna', 'Wallis et Futuna', 'WF', '876', 'Mata-Utu', utl.split_string_strarray('WF,Territory of the Wallis and Futuna Islands,Territoire des îles Wallis et Futuna',','), 'Oceania' from dual union all
select 'ESH', 'Western Sahara', 'الصحراء الغربية', 'EH', '732', 'El Aaiún', utl.split_string_strarray('EH,Taneẓroft Tutrimt',','), 'Africa' from dual union all
select 'YEM', 'Yemen', 'اليَمَن', 'YE', '887', 'Sana''a', utl.split_string_strarray('YE,Yemeni Republic,al-Jumhūriyyah al-Yamaniyyah',','), 'Asia' from dual union all
select 'ZMB', 'Zambia', 'Zambia', 'ZM', '894', 'Lusaka', utl.split_string_strarray('ZM,Republic of Zambia',','), 'Africa' from dual union all
select 'ZWE', 'Zimbabwe', 'Zimbabwe', 'ZW', '716', 'Harare', utl.split_string_strarray('ZW,Republic of Zimbabwe',','), 'Africa' from dual
/

INSERT INTO "currency" (currency_id, name, symbol, frac_name, frac_amt)
select 'AED', 'United Arab Emirates dirham', 'د.إ', 'Fils', 100 from dual union all
select 'AFN', 'Afghan afghani', '؋', 'Pul', 100 from dual union all
select 'ALL', 'Albanian lek', 'L', 'Qindarkë', 100 from dual union all
select 'AMD', 'Armenian dram', '֏', 'Luma', 100 from dual union all
select 'ANG', 'Netherlands Antillean guilder', 'ƒ', 'Cent', 100 from dual union all
select 'AOA', 'Angolan kwanza', 'Kz', 'Cêntimo', 100 from dual union all
select 'ARS', 'Argentine peso', '$', 'Centavo', 100 from dual union all
select 'AUD', 'Australian dollar', '$', 'Cent', 100 from dual union all
select 'AWG', 'Aruban florin', 'ƒ', 'Cent', 100 from dual union all
select 'AZN', 'Azerbaijani manat', '₼', 'Qəpik', 100 from dual union all
select 'BAM', 'Bosnia and Herzegovina convertible mark', 'KM', 'Fening', 100 from dual union all
select 'BBD', 'Barbadian dollar', '$', 'Cent', 100 from dual union all
select 'BDT', 'Bangladeshi taka', '৳', 'Paisa', 100 from dual union all
select 'BGN', 'Bulgarian lev', 'лв', 'Stotinka', 100 from dual union all
select 'BHD', 'Bahraini dinar', '.د.ب', 'Fils', 1000 from dual union all
select 'BIF', 'Burundian franc', 'Fr', 'Centime', 100 from dual union all
select 'BMD', 'Bermudian dollar', '$', 'Cent', 100 from dual union all
select 'BND', 'Brunei dollar', '$', 'Sen', 100 from dual union all
select 'BOB', 'Bolivian boliviano', 'Bs.', 'Centavo', 100 from dual union all
select 'BRL', 'Brazilian real', 'R$', 'Centavo', 100 from dual union all
select 'BSD', 'Bahamian dollar', '$', 'Cent', 100 from dual union all
select 'BTN', 'Bhutanese ngultrum', 'Nu.', 'Chetrum', 100 from dual union all
select 'BWP', 'Botswana pula', 'P', 'Thebe', 100 from dual union all
select 'BYR', 'Belarusian ruble', 'Br', 'Kapyeyka', 100 from dual union all
select 'BZD', 'Belize dollar', '$', 'Cent', 100 from dual union all
select 'CAD', 'Canadian dollar', '$', 'Cent', 100 from dual union all
select 'CDF', 'Congolese franc', 'Fr', 'Centime', 100 from dual union all
select 'CHF', 'Swiss franc', 'Fr', 'Rappen', 100 from dual union all
select 'CLP', 'Chilean peso', '$', 'Centavo', 100 from dual union all
select 'CNY', 'Chinese yuan', '¥', 'Fen', 100 from dual union all
select 'COP', 'Colombian peso', '$', 'Centavo', 100 from dual union all
select 'CRC', 'Costa Rican colón', '₡', 'Céntimo', 100 from dual union all
select 'CUC', 'Cuban convertible peso', '$', 'Centavo', 100 from dual union all
select 'CUP', 'Cuban peso', '$', 'Centavo', 100 from dual union all
select 'CVE', 'Cape Verdean escudo', '$', 'Centavo', 100 from dual union all
select 'CZK', 'Czech koruna', 'Kč', 'Haléř', 100 from dual union all
select 'DJF', 'Djiboutian franc', 'Fr', 'Centime', 100 from dual union all
select 'DKK', 'Danish krone', 'kr', 'Øre', 100 from dual union all
select 'DOP', 'Dominican peso', '$', 'Centavo', 100 from dual union all
select 'DZD', 'Algerian dinar', 'د.ج', 'Santeem', 100 from dual union all
select 'EGP', 'Egyptian pound', '£', 'Piastre', 100 from dual union all
select 'ERN', 'Eritrean nakfa', 'Nfk', 'Cent', 100 from dual union all
select 'ETB', 'Ethiopian birr', 'Br', 'Santim', 100 from dual union all
select 'EUR', 'Euro', '€', 'Cent', 100 from dual union all
select 'FJD', 'Fijian dollar', '$', 'Cent', 100 from dual union all
select 'FKP', 'Falkland Islands pound', '£', 'Penny', 100 from dual union all
select 'GBP', 'British pound', '£', 'Penny', 100 from dual union all
select 'GEL', 'Georgian lari', 'ლ', 'Tetri', 100 from dual union all
select 'GHS', 'Ghana cedi', '₵', 'Pesewa', 100 from dual union all
select 'GIP', 'Gibraltar pound', '£', 'Penny', 100 from dual union all
select 'GMD', 'Gambian dalasi', 'D', 'Butut', 100 from dual union all
select 'GNF', 'Guinean franc', 'Fr', 'Centime', 100 from dual union all
select 'GTQ', 'Guatemalan quetzal', 'Q', 'Centavo', 100 from dual union all
select 'GYD', 'Guyanese dollar', '$', 'Cent', 100 from dual union all
select 'HKD', 'Hong Kong dollar', '$', 'Cent', 100 from dual union all
select 'HNL', 'Honduran lempira', 'L', 'Centavo', 100 from dual union all
select 'HRK', 'Croatian kuna', 'kn', 'Lipa', 100 from dual union all
select 'HTG', 'Haitian gourde', 'G', 'Centime', 100 from dual union all
select 'HUF', 'Hungarian forint', 'Ft', 'Fillér', 100 from dual union all
select 'IDR', 'Indonesian rupiah', 'Rp', 'Sen', 100 from dual union all
select 'ILS', 'Israeli new shekel', '₪', 'Agora', 100 from dual union all
select 'IMP', 'Manx pound', '£', 'Penny', 100 from dual union all
select 'INR', 'Indian rupee', '₹', 'Paisa', 100 from dual union all
select 'IQD', 'Iraqi dinar', 'ع.د', 'Fils', 1000 from dual union all
select 'IRR', 'Iranian rial', '﷼', 'Dinar', 100 from dual union all
select 'ISK', 'Icelandic króna', 'kr', 'Eyrir', 100 from dual union all
select 'JEP', 'Jersey pound', '£', 'Penny', 100 from dual union all
select 'JMD', 'Jamaican dollar', '$', 'Cent', 100 from dual union all
select 'JOD', 'Jordanian dinar', 'د.ا', 'Piastre', 100 from dual union all
select 'JPY', 'Japanese yen', '¥', 'Sen', 100 from dual union all
select 'KES', 'Kenyan shilling', 'Sh', 'Cent', 100 from dual union all
select 'KGS', 'Kyrgyzstani som', 'лв', 'Tyiyn', 100 from dual union all
select 'KHR', 'Cambodian riel', '៛', 'Sen', 100 from dual union all
select 'KMF', 'Comorian franc', 'Fr', 'Centime', 100 from dual union all
select 'KPW', 'North Korean won', '₩', 'Chon', 100 from dual union all
select 'KRW', 'South Korean won', '₩', 'Jeon', 100 from dual union all
select 'KWD', 'Kuwaiti dinar', 'د.ك', 'Fils', 1000 from dual union all
select 'KYD', 'Cayman Islands dollar', '$', 'Cent', 100 from dual union all
select 'KZT', 'Kazakhstani tenge', '₸', 'Tïın', 100 from dual union all
select 'LAK', 'Lao kip', '₭', 'Att', 100 from dual union all
select 'LBP', 'Lebanese pound', 'ل.ل', 'Piastre', 100 from dual union all
select 'LKR', 'Sri Lankan rupee', 'Rs or රු', 'Cent', 100 from dual union all
select 'LRD', 'Liberian dollar', '$', 'Cent', 100 from dual union all
select 'LSL', 'Lesotho loti', 'L', 'Sente', 100 from dual union all
select 'LTL', 'Lithuanian litas', 'Lt', 'Centas', 100 from dual union all
select 'LYD', 'Libyan dinar', 'ل.د', 'Dirham', 1000 from dual union all
select 'MAD', 'Moroccan dirham', 'د.م.', 'Centime', 100 from dual union all
select 'MDL', 'Moldovan leu', 'L', 'Ban', 100 from dual union all
select 'MGA', 'Malagasy ariary', 'Ar', 'Iraimbilanja', 5 from dual union all
select 'MKD', 'Macedonian denar', 'ден', 'Deni', 100 from dual union all
select 'MMK', 'Burmese kyat', 'Ks', 'Pya', 100 from dual union all
select 'MNT', 'Mongolian tögrög', '₮', 'Möngö', 100 from dual union all
select 'MOP', 'Macanese pataca', 'P', 'Avo', 100 from dual union all
select 'MRO', 'Mauritanian ouguiya', 'UM', 'Khoums', 5 from dual union all
select 'MUR', 'Mauritian rupee', '₨', 'Cent', 100 from dual union all
select 'MVR', 'Maldivian rufiyaa', '.ރ', 'Laari', 100 from dual union all
select 'MWK', 'Malawian kwacha', 'MK', 'Tambala', 100 from dual union all
select 'MXN', 'Mexican peso', '$', 'Centavo', 100 from dual union all
select 'MYR', 'Malaysian ringgit', 'RM', 'Sen', 100 from dual union all
select 'MZN', 'Mozambican metical', 'MT', 'Centavo', 100 from dual union all
select 'NAD', 'Namibian dollar', '$', 'Cent', 100 from dual union all
select 'NGN', 'Nigerian naira', '₦', 'Kobo', 100 from dual union all
select 'NIO', 'Nicaraguan córdoba', 'C$', 'Centavo', 100 from dual union all
select 'NOK', 'Norwegian krone', 'kr', 'Øre', 100 from dual union all
select 'NPR', 'Nepalese rupee', '₨', 'Paisa', 100 from dual union all
select 'NZD', 'New Zealand dollar', '$', 'Cent', 100 from dual union all
select 'OMR', 'Omani rial', 'ر.ع.', 'Baisa', 1000 from dual union all
select 'PAB', 'Panamanian balboa', 'B/.', 'Centésimo', 100 from dual union all
select 'PEN', 'Peruvian nuevo sol', 'S/.', 'Céntimo', 100 from dual union all
select 'PGK', 'Papua New Guinean kina', 'K', 'Toea', 100 from dual union all
select 'PHP', 'Philippine peso', '₱', 'Centavo', 100 from dual union all
select 'PKR', 'Pakistani rupee', '₨', 'Paisa', 100 from dual union all
select 'PLN', 'Polish złoty', 'zł', 'Grosz', 100 from dual union all
select 'PYG', 'Paraguayan guaraní', '₲', 'Céntimo', 100 from dual union all
select 'QAR', 'Qatari riyal', 'ر.ق', 'Dirham', 100 from dual union all
select 'RON', 'Romanian leu', 'lei', 'Ban', 100 from dual union all
select 'RSD', 'Serbian dinar', 'дин', 'Para', 100 from dual union all
select 'RUB', 'Russian ruble', '₽', 'Kopek', 100 from dual union all
select 'RWF', 'Rwandan franc', 'Fr', 'Centime', 100 from dual union all
select 'SAR', 'Saudi riyal', 'ر.س', 'Halala', 100 from dual union all
select 'SBD', 'Solomon Islands dollar', '$', 'Cent', 100 from dual union all
select 'SCR', 'Seychellois rupee', '₨', 'Cent', 100 from dual union all
select 'SDG', 'Sudanese pound', '£', 'Piastre', 100 from dual union all
select 'SEK', 'Swedish krona', 'kr', 'Öre', 100 from dual union all
select 'SGD', 'Singapore dollar', '$', 'Cent', 100 from dual union all
select 'SHP', 'Saint Helena pound', '£', 'Penny', 100 from dual union all
select 'SLL', 'Sierra Leonean leone', 'Le', 'Cent', 100 from dual union all
select 'SOS', 'Somali shilling', 'Sh', 'Cent', 100 from dual union all
select 'SRD', 'Surinamese dollar', '$', 'Cent', 100 from dual union all
select 'SSP', 'South Sudanese pound', '£', 'Piastre', 100 from dual union all
select 'STD', 'São Tomé and Príncipe dobra', 'Db', 'Cêntimo', 100 from dual union all
select 'SYP', 'Syrian pound', '£ or ل.س', 'Piastre', 100 from dual union all
select 'SZL', 'Swazi lilangeni', 'L', 'Cent', 100 from dual union all
select 'THB', 'Thai baht', '฿', 'Satang', 100 from dual union all
select 'TJS', 'Tajikistani somoni', 'ЅМ', 'Diram', 100 from dual union all
select 'TMT', 'Turkmenistan manat', 'm', 'Tennesi', 100 from dual union all
select 'TND', 'Tunisian dinar', 'د.ت', 'Millime', 1000 from dual union all
select 'TOP', 'Tongan paʻanga', 'T$', 'Seniti', 100 from dual union all
select 'TRY', 'Turkish lira', '₺', 'Kuruş', 100 from dual union all
select 'TTD', 'Trinidad and Tobago dollar', '$', 'Cent', 100 from dual union all
select 'TWD', 'New Taiwan dollar', '$', 'Cent', 100 from dual union all
select 'TZS', 'Tanzanian shilling', 'Sh', 'Cent', 100 from dual union all
select 'UAH', 'Ukrainian hryvnia', '₴', 'Kopiyka', 100 from dual union all
select 'UGX', 'Ugandan shilling', 'Sh', 'Cent', 100 from dual union all
select 'USD', 'United States dollar', '$', 'Cent', 100 from dual union all
select 'UYU', 'Uruguayan peso', '$', 'Centésimo', 100 from dual union all
select 'UZS', 'Uzbekistani som', 'лв', 'Tiyin', 100 from dual union all
select 'VEF', 'Venezuelan bolívar', 'Bs F', 'Céntimo', 100 from dual union all
select 'VND', 'Vietnamese đồng', '₫', 'Hào', 10 from dual union all
select 'VUV', 'Vanuatu vatu', 'Vt', null, NULL from dual union all
select 'WST', 'Samoan tālā', 'T', 'Sene', 100 from dual union all
select 'XAF', 'Central African CFA franc', 'Fr', 'Centime', 100 from dual union all
select 'XCD', 'East Caribbean dollar', '$', 'Cent', 100 from dual union all
select 'XOF', 'West African CFA franc', 'Fr', 'Centime', 100 from dual union all
select 'XPF', 'CFP franc', 'Fr', 'Centime', 100 from dual union all
select 'YER', 'Yemeni rial', '﷼', 'Fils', 100 from dual union all
select 'ZAR', 'South African rand', 'R', 'Cent', 100 from dual union all
select 'ZMW', 'Zambian kwacha', 'ZK', 'Ngwee', 100 from dual
/

INSERT INTO "language" (language_id, code3, name, native_name)
select 'ab', 'abk', 'Abkhaz',                                              'аҧсуа бызшәа, аҧсшәа' from dual union all
select 'aa', 'aar', 'Afar',                                                'Afaraf' from dual union all
select 'af', 'afr', 'Afrikaans',                                           'Afrikaans' from dual union all
select 'ak', 'aka', 'Akan',                                                'Akan' from dual union all
select 'sq', 'sqi', 'Albanian',                                            'Shqip' from dual union all
select 'am', 'amh', 'Amharic',                                             'አማርኛ' from dual union all
select 'ar', 'ara', 'Arabic',                                              'العربية' from dual union all
select 'an', 'arg', 'Aragonese',                                           'aragonés' from dual union all
select 'hy', 'hye', 'Armenian',                                            'Հայերեն' from dual union all
select 'as', 'asm', 'Assamese',                                            'অসমীয়া' from dual union all
select 'av', 'ava', 'Avaric',                                              'авар мацӀ, магӀарул мацӀ' from dual union all
select 'ae', 'ave', 'Avestan',                                             'avesta' from dual union all
select 'ay', 'aym', 'Aymara',                                              'aymar aru' from dual union all
select 'az', 'aze', 'Azerbaijani',                                         'azərbaycan dili' from dual union all
select 'bm', 'bam', 'Bambara',                                             'bamanankan' from dual union all
select 'ba', 'bak', 'Bashkir',                                             'башҡорт теле' from dual union all
select 'eu', 'eus', 'Basque',                                              'euskara, euskera' from dual union all
select 'be', 'bel', 'Belarusian',                                          'беларуская мова' from dual union all
select 'bn', 'ben', 'Bengali, Bangla',                                     'বাংলা' from dual union all
select 'bh', null , 'Bihari',                                              'भोजपुरी' from dual union all
select 'bi', 'bis', 'Bislama',                                             'Bislama' from dual union all
select 'bs', 'bos', 'Bosnian',                                             'bosanski jezik' from dual union all
select 'br', 'bre', 'Breton',                                              'brezhoneg' from dual union all
select 'bg', 'bul', 'Bulgarian',                                           'български език' from dual union all
select 'my', 'mya', 'Burmese',                                             'ဗမာစာ' from dual union all
select 'ca', 'cat', 'Catalan, Valencian',                                  'català, valencià' from dual union all
select 'ch', 'cha', 'Chamorro',                                            'Chamoru' from dual union all
select 'ce', 'che', 'Chechen',                                             'нохчийн мотт' from dual union all
select 'ny', 'nya', 'Chichewa, Chewa, Nyanja',                             'chiCheŵa, chinyanja' from dual union all
select 'zh', 'zho', 'Chinese',                                             '中文 (Zhōngwén), 汉语, 漢語' from dual union all
select 'cv', 'chv', 'Chuvash',                                             'чӑваш чӗлхи' from dual union all
select 'kw', 'cor', 'Cornish',                                             'Kernewek' from dual union all
select 'co', 'cos', 'Corsican',                                            'corsu, lingua corsa' from dual union all
select 'cr', 'cre', 'Cree',                                                'ᓀᐦᐃᔭᐍᐏᐣ' from dual union all
select 'hr', 'hrv', 'Croatian',                                            'hrvatski jezik' from dual union all
select 'cs', 'ces', 'Czech',                                               'čeština, český jazyk' from dual union all
select 'da', 'dan', 'Danish',                                              'dansk' from dual union all
select 'dv', 'div', 'Divehi, Dhivehi, Maldivian',                          null from dual union all
select 'nl', 'nld', 'Dutch',                                               'Nederlands, Vlaams' from dual union all
select 'dz', 'dzo', 'Dzongkha',                                            'རྫོང་ཁ' from dual union all
select 'en', 'eng', 'English',                                             'English' from dual union all
select 'eo', 'epo', 'Esperanto',                                           'Esperanto' from dual union all
select 'et', 'est', 'Estonian',                                            'eesti, eesti keel' from dual union all
select 'ee', 'ewe', 'Ewe',                                                 'Eʋegbe' from dual union all
select 'fo', 'fao', 'Faroese',                                             'føroyskt' from dual union all
select 'fj', 'fij', 'Fijian',                                              'vosa Vakaviti' from dual union all
select 'fi', 'fin', 'Finnish',                                             'suomi, suomen kieli' from dual union all
select 'fr', 'fra', 'French',                                              'français, langue française' from dual union all
select 'ff', 'ful', 'Fula, Fulah, Pulaar, Pular',                          'Fulfulde, Pulaar, Pular' from dual union all
select 'gl', 'glg', 'Galician',                                            'galego' from dual union all
select 'ka', 'kat', 'Georgian',                                            'ქართული' from dual union all
select 'de', 'deu', 'German',                                              'Deutsch' from dual union all
select 'el', 'ell', 'Greek (modern)',                                      'ελληνικά' from dual union all
select 'gn', 'grn', 'Guaraní',                                             'Avañe''ẽ' from dual union all
select 'gu', 'guj', 'Gujarati',                                            'ગુજરાતી' from dual union all
select 'ht', 'hat', 'Haitian, Haitian Creole',                             'Kreyòl ayisyen' from dual union all
select 'ha', 'hau', 'Hausa',                                               '(Hausa) هَوُسَ' from dual union all
select 'he', 'heb', 'Hebrew (modern)',                                     'עברית' from dual union all
select 'hz', 'her', 'Herero',                                              'Otjiherero' from dual union all
select 'hi', 'hin', 'Hindi',                                               'हिन्दी, हिंदी' from dual union all
select 'ho', 'hmo', 'Hiri Motu',                                           'Hiri Motu' from dual union all
select 'hu', 'hun', 'Hungarian',                                           'magyar' from dual union all
select 'ia', 'ina', 'Interlingua',                                         'Interlingua' from dual union all
select 'id', 'ind', 'Indonesian',                                          'Bahasa Indonesia' from dual union all
select 'ie', 'ile', 'Interlingue',                                         'Interlingue' from dual union all
select 'ga', 'gle', 'Irish',                                               'Gaeilge' from dual union all
select 'ig', 'ibo', 'Igbo',                                                'Asụsụ Igbo' from dual union all
select 'ik', 'ipk', 'Inupiaq',                                             'Iñupiaq, Iñupiatun' from dual union all
select 'io', 'ido', 'Ido',                                                 'Ido' from dual union all
select 'is', 'isl', 'Icelandic',                                           'Íslenska' from dual union all
select 'it', 'ita', 'Italian',                                             'italiano' from dual union all
select 'iu', 'iku', 'Inuktitut',                                           'ᐃᓄᒃᑎᑐᑦ' from dual union all
select 'ja', 'jpn', 'Japanese',                                            '日本語 (にほんご)' from dual union all
select 'jv', 'jav', 'Javanese',                                            'basa Jawa' from dual union all
select 'kl', 'kal', 'Kalaallisut, Greenlandic',                            'kalaallisut, kalaallit oqaasii' from dual union all
select 'kn', 'kan', 'Kannada',                                             'ಕನ್ನಡ' from dual union all
select 'kr', 'kau', 'Kanuri',                                              'Kanuri' from dual union all
select 'ks', 'kas', 'Kashmiri',                                            'कश्मीरी, كشميري‎' from dual union all
select 'kk', 'kaz', 'Kazakh',                                              'қазақ тілі' from dual union all
select 'km', 'khm', 'Khmer',                                               'ខ្មែរ, ខេមរភាសា, ភាសាខ្មែរ' from dual union all
select 'ki', 'kik', 'Kikuyu, Gikuyu',                                      'Gĩkũyũ' from dual union all
select 'rw', 'kin', 'Kinyarwanda',                                         'Ikinyarwanda' from dual union all
select 'ky', 'kir', 'Kyrgyz',                                              'Кыргызча, Кыргыз тили' from dual union all
select 'kv', 'kom', 'Komi',                                                'коми кыв' from dual union all
select 'kg', 'kon', 'Kongo',                                               'Kikongo' from dual union all
select 'ko', 'kor', 'Korean',                                              '한국어, 조선어' from dual union all
select 'ku', 'kur', 'Kurdish',                                             'Kurdî, كوردی‎' from dual union all
select 'kj', 'kua', 'Kwanyama, Kuanyama',                                  'Kuanyama' from dual union all
select 'la', 'lat', 'Latin',                                               'latine, lingua latina' from dual union all
select 'lb', 'ltz', 'Luxembourgish, Letzeburgesch',                        'Lëtzebuergesch' from dual union all
select 'lg', 'lug', 'Ganda',                                               'Luganda' from dual union all
select 'li', 'lim', 'Limburgish, Limburgan, Limburger',                    'Limburgs' from dual union all
select 'ln', 'lin', 'Lingala',                                             'Lingála' from dual union all
select 'lo', 'lao', 'Lao',                                                 'ພາສາລາວ' from dual union all
select 'lt', 'lit', 'Lithuanian',                                          'lietuvių kalba' from dual union all
select 'lu', 'lub', 'Luba-Katanga',                                        'Tshiluba' from dual union all
select 'lv', 'lav', 'Latvian',                                             'latviešu valoda' from dual union all
select 'gv', 'glv', 'Manx',                                                'Gaelg, Gailck' from dual union all
select 'mk', 'mkd', 'Macedonian',                                          'македонски јазик' from dual union all
select 'mg', 'mlg', 'Malagasy',                                            'fiteny malagasy' from dual union all
select 'ms', 'msa', 'Malay',                                               'bahasa Melayu, بهاس ملايو‎' from dual union all
select 'ml', 'mal', 'Malayalam',                                           'മലയാളം' from dual union all
select 'mt', 'mlt', 'Maltese',                                             'Malti' from dual union all
select 'mi', 'mri', 'Māori',                                               'te reo Māori' from dual union all
select 'mr', 'mar', 'Marathi (Marāṭhī)',                                   'मराठी' from dual union all
select 'mh', 'mah', 'Marshallese',                                         'Kajin M̧ajeļ' from dual union all
select 'mn', 'mon', 'Mongolian',                                           'монгол' from dual union all
select 'na', 'nau', 'Nauru',                                               'Ekakairũ Naoero' from dual union all
select 'nv', 'nav', 'Navajo, Navaho',                                      'Diné bizaad, Dinékʼehǰí' from dual union all
select 'nd', 'nde', 'Northern Ndebele',                                    'isiNdebele' from dual union all
select 'ne', 'nep', 'Nepali',                                              'नेपाली' from dual union all
select 'ng', 'ndo', 'Ndonga',                                              'Owambo' from dual union all
select 'nb', 'nob', 'Norwegian Bokmål',                                    'Norsk bokmål' from dual union all
select 'nn', 'nno', 'Norwegian Nynorsk',                                   'Norsk nynorsk' from dual union all
select 'no', 'nor', 'Norwegian',                                           'Norsk' from dual union all
select 'ii', 'iii', 'Nuosu',                                               'ꆈꌠ꒿ Nuosuhxop' from dual union all
select 'nr', 'nbl', 'Southern Ndebele',                                    'isiNdebele' from dual union all
select 'oc', 'oci', 'Occitan',                                             'occitan, lenga d''òc' from dual union all
select 'oj', 'oji', 'Ojibwe, Ojibwa',                                      'ᐊᓂᔑᓈᐯᒧᐎᓐ' from dual union all
select 'cu', 'chu', 'Old Church Slavonic, Church Slavonic, Old Bulgarian', 'ѩзыкъ словѣньскъ' from dual union all
select 'om', 'orm', 'Oromo',                                               'Afaan Oromoo' from dual union all
select 'or', 'ori', 'Oriya',                                               'ଓଡ଼ିଆ' from dual union all
select 'os', 'oss', 'Ossetian, Ossetic',                                   'ирон æвзаг' from dual union all
select 'pa', 'pan', 'Panjabi, Punjabi',                                    'ਪੰਜਾਬੀ, پنجابی‎' from dual union all
select 'pi', 'pli', 'Pāli',                                                'पाऴि' from dual union all
select 'fa', 'fas', 'Persian (Farsi)',                                     'فارسی' from dual union all
select 'pl', 'pol', 'Polish',                                              'język polski, polszczyzna' from dual union all
select 'ps', 'pus', 'Pashto, Pushto',                                      'پښتو' from dual union all
select 'pt', 'por', 'Portuguese',                                          'português' from dual union all
select 'qu', 'que', 'Quechua',                                             'Runa Simi, Kichwa' from dual union all
select 'rm', 'roh', 'Romansh',                                             'rumantsch grischun' from dual union all
select 'rn', 'run', 'Kirundi',                                             'Ikirundi' from dual union all
select 'ro', 'ron', 'Romanian',                                            'limba română' from dual union all
select 'ru', 'rus', 'Russian',                                             'русский язык' from dual union all
select 'sa', 'san', 'Sanskrit (Saṁskṛta)',                                 'संस्कृतम्' from dual union all
select 'sc', 'srd', 'Sardinian',                                           'sardu' from dual union all
select 'sd', 'snd', 'Sindhi',                                              'सिन्धी, سنڌي، سندھی‎' from dual union all
select 'se', 'sme', 'Northern Sami',                                       'Davvisámegiella' from dual union all
select 'sm', 'smo', 'Samoan',                                              'gagana fa''a Samoa' from dual union all
select 'sg', 'sag', 'Sango',                                               'yângâ tî sängö' from dual union all
select 'sr', 'srp', 'Serbian',                                             'српски језик' from dual union all
select 'gd', 'gla', 'Scottish Gaelic, Gaelic',                             'Gàidhlig' from dual union all
select 'sn', 'sna', 'Shona',                                               'chiShona' from dual union all
select 'si', 'sin', 'Sinhala, Sinhalese',                                  'සිංහල' from dual union all
select 'sk', 'slk', 'Slovak',                                              'slovenčina, slovenský jazyk' from dual union all
select 'sl', 'slv', 'Slovene',                                             'slovenski jezik, slovenščina' from dual union all
select 'so', 'som', 'Somali',                                              'Soomaaliga, af Soomaali' from dual union all
select 'st', 'sot', 'Southern Sotho',                                      'Sesotho' from dual union all
select 'es', 'spa', 'Spanish, Castilian',                                  'español, castellano' from dual union all
select 'su', 'sun', 'Sundanese',                                           'Basa Sunda' from dual union all
select 'sw', 'swa', 'Swahili',                                             'Kiswahili' from dual union all
select 'ss', 'ssw', 'Swati',                                               'SiSwati' from dual union all
select 'sv', 'swe', 'Swedish',                                             'Svenska' from dual union all
select 'ta', 'tam', 'Tamil',                                               'தமிழ்' from dual union all
select 'te', 'tel', 'Telugu',                                              'తెలుగు' from dual union all
select 'tg', 'tgk', 'Tajik',                                               'тоҷикӣ, toğikī, تاجیکی‎' from dual union all
select 'th', 'tha', 'Thai',                                                'ไทย' from dual union all
select 'ti', 'tir', 'Tigrinya',                                            'ትግርኛ' from dual union all
select 'bo', 'bod', 'Tibetan Standard, Tibetan, Central',                  'བོད་ཡིག' from dual union all
select 'tk', 'tuk', 'Turkmen',                                             'Türkmen, Түркмен' from dual union all
select 'tl', 'tgl', 'Tagalog',                                             'Wikang Tagalog' from dual union all
select 'tn', 'tsn', 'Tswana',                                              'Setswana' from dual union all
select 'to', 'ton', 'Tonga (Tonga Islands)',                               'faka Tonga' from dual union all
select 'tr', 'tur', 'Turkish',                                             'Türkçe' from dual union all
select 'ts', 'tso', 'Tsonga',                                              'Xitsonga' from dual union all
select 'tt', 'tat', 'Tatar',                                               'татар теле, tatar tele' from dual union all
select 'tw', 'twi', 'Twi',                                                 'Twi' from dual union all
select 'ty', 'tah', 'Tahitian',                                            'Reo Tahiti' from dual union all
select 'ug', 'uig', 'Uyghur, Uighur',                                      'Uyƣurqə, ئۇيغۇرچە‎' from dual union all
select 'uk', 'ukr', 'Ukrainian',                                           'українська мова' from dual union all
select 'ur', 'urd', 'Urdu',                                                'اردو' from dual union all
select 'uz', 'uzb', 'Uzbek',                                               'O‘zbek, Ўзбек, أۇزبېك‎' from dual union all
select 've', 'ven', 'Venda',                                               'Tshivenḓa' from dual union all
select 'vi', 'vie', 'Vietnamese',                                          'Tiếng Việt' from dual union all
select 'vo', 'vol', 'Volapük',                                             'Volapük' from dual union all
select 'wa', 'wln', 'Walloon',                                             'walon' from dual union all
select 'cy', 'cym', 'Welsh',                                               'Cymraeg' from dual union all
select 'wo', 'wol', 'Wolof',                                               'Wollof' from dual union all
select 'fy', 'fry', 'Western Frisian',                                     'Frysk' from dual union all
select 'xh', 'xho', 'Xhosa',                                               'isiXhosa' from dual union all
select 'yi', 'yid', 'Yiddish',                                             'ייִדיש' from dual union all
select 'yo', 'yor', 'Yoruba',                                              'Yorùbá' from dual union all
select 'za', 'zha', 'Zhuang, Chuang',                                      'Saɯ cueŋƅ, Saw cuengh' from dual union all
select 'zu', 'zul', 'Zulu',                                                'isiZulu' from dual
/

INSERT INTO "country_currency" (country_id, currency_id)
select 'BDI', 'BIF' from dual union all
select 'KHM', 'KHR' from dual union all
select 'KHM', 'USD' from dual union all
select 'CMR', 'XAF' from dual union all
select 'CAN', 'CAD' from dual union all
select 'CPV', 'CVE' from dual union all
select 'CYM', 'KYD' from dual union all
select 'CAF', 'XAF' from dual union all
select 'TCD', 'XAF' from dual union all
select 'CHL', 'CLP' from dual union all
select 'CCK', 'AUD' from dual union all
select 'COL', 'COP' from dual union all
select 'COM', 'KMF' from dual union all
select 'COK', 'NZD' from dual union all
select 'CRI', 'CRC' from dual union all
select 'HRV', 'HRK' from dual union all
select 'CUB', 'CUC' from dual union all
select 'CUB', 'CUP' from dual union all
select 'CUW', 'ANG' from dual union all
select 'CYP', 'EUR' from dual union all
select 'CZE', 'CZK' from dual union all
select 'DNK', 'DKK' from dual union all
select 'DJI', 'DJF' from dual union all
select 'DMA', 'XCD' from dual union all
select 'DOM', 'DOP' from dual union all
select 'ECU', 'USD' from dual union all
select 'EGY', 'EGP' from dual union all
select 'SLV', 'USD' from dual union all
select 'GNQ', 'XAF' from dual union all
select 'ERI', 'ERN' from dual union all
select 'EST', 'EUR' from dual union all
select 'ETH', 'ETB' from dual union all
select 'FLK', 'FKP' from dual union all
select 'FRO', 'DKK' from dual union all
select 'FJI', 'FJD' from dual union all
select 'FIN', 'EUR' from dual union all
select 'FRA', 'EUR' from dual union all
select 'PYF', 'XPF' from dual union all
select 'GAB', 'XAF' from dual union all
select 'GEO', 'GEL' from dual union all
select 'DEU', 'EUR' from dual union all
select 'GHA', 'GHS' from dual union all
select 'GIB', 'GIP' from dual union all
select 'GRC', 'EUR' from dual union all
select 'GRD', 'XCD' from dual union all
select 'GTM', 'GTQ' from dual union all
select 'GGY', 'GBP' from dual union all
select 'GIN', 'GNF' from dual union all
select 'GNB', 'XOF' from dual union all
select 'GUY', 'GYD' from dual union all
select 'HTI', 'HTG' from dual union all
select 'HND', 'HNL' from dual union all
select 'HKG', 'HKD' from dual union all
select 'HUN', 'HUF' from dual union all
select 'ISL', 'ISK' from dual union all
select 'IND', 'INR' from dual union all
select 'IDN', 'IDR' from dual union all
select 'IRN', 'IRR' from dual union all
select 'IRQ', 'IQD' from dual union all
select 'IRL', 'EUR' from dual union all
select 'IMN', 'GBP' from dual union all
select 'IMN', 'IMP' from dual union all
select 'ISR', 'ILS' from dual union all
select 'ITA', 'EUR' from dual union all
select 'JAM', 'JMD' from dual union all
select 'JPN', 'JPY' from dual union all
select 'JEY', 'GBP' from dual union all
select 'JEY', 'JEP' from dual union all
select 'JOR', 'JOD' from dual union all
select 'KAZ', 'KZT' from dual union all
select 'KEN', 'KES' from dual union all
select 'KIR', 'AUD' from dual union all
select 'KWT', 'KWD' from dual union all
select 'KGZ', 'KGS' from dual union all
select 'LAO', 'LAK' from dual union all
select 'LVA', 'EUR' from dual union all
select 'LBN', 'LBP' from dual union all
select 'LSO', 'LSL' from dual union all
select 'LSO', 'ZAR' from dual union all
select 'LBR', 'LRD' from dual union all
select 'LBY', 'LYD' from dual union all
select 'LIE', 'CHF' from dual union all
select 'LTU', 'LTL' from dual union all
select 'LUX', 'EUR' from dual union all
select 'MAC', 'MOP' from dual union all
select 'MDG', 'MGA' from dual union all
select 'MWI', 'MWK' from dual union all
select 'MYS', 'MYR' from dual union all
select 'MDV', 'MVR' from dual union all
select 'MLI', 'XOF' from dual union all
select 'MLT', 'EUR' from dual union all
select 'CHN', 'CNY' from dual union all
select 'COD', 'CDF' from dual union all
select 'COG', 'XAF' from dual union all
select 'CIV', 'XOF' from dual union all
select 'TLS', 'USD' from dual union all
select 'GMB', 'GMD' from dual union all
select 'PRK', 'KPW' from dual union all
select 'KOR', 'KRW' from dual union all
select 'KOS', 'EUR' from dual union all
select 'MHL', 'USD' from dual union all
select 'MRT', 'MRO' from dual union all
select 'MUS', 'MUR' from dual union all
select 'MEX', 'MXN' from dual union all
select 'FSM', 'USD' from dual union all
select 'MDA', 'MDL' from dual union all
select 'MCO', 'EUR' from dual union all
select 'MNG', 'MNT' from dual union all
select 'MNE', 'EUR' from dual union all
select 'MSR', 'XCD' from dual union all
select 'MAR', 'MAD' from dual union all
select 'MOZ', 'MZN' from dual union all
select 'NAM', 'NAD' from dual union all
select 'NAM', 'ZAR' from dual union all
select 'NRU', 'AUD' from dual union all
select 'NPL', 'NPR' from dual union all
select 'NLD', 'EUR' from dual union all
select 'NCL', 'XPF' from dual union all
select 'NZL', 'NZD' from dual union all
select 'NIC', 'NIO' from dual union all
select 'NER', 'XOF' from dual union all
select 'NGA', 'NGN' from dual union all
select 'NIU', 'NZD' from dual union all
select 'PER', 'PEN' from dual union all
select 'PHL', 'PHP' from dual union all
select 'PCN', 'NZD' from dual union all
select 'POL', 'PLN' from dual union all
select 'PRT', 'EUR' from dual union all
select 'QAT', 'QAR' from dual union all
select 'ROU', 'RON' from dual union all
select 'RUS', 'RUB' from dual union all
select 'RWA', 'RWF' from dual union all
select 'SHN', 'SHP' from dual union all
select 'KNA', 'XCD' from dual union all
select 'LCA', 'XCD' from dual union all
select 'VCT', 'XCD' from dual union all
select 'WSM', 'WST' from dual union all
select 'SMR', 'EUR' from dual union all
select 'STP', 'STD' from dual union all
select 'SAU', 'SAR' from dual union all
select 'SEN', 'XOF' from dual union all
select 'SRB', 'RSD' from dual union all
select 'SYC', 'SCR' from dual union all
select 'SLE', 'SLL' from dual union all
select 'SGP', 'BND' from dual union all
select 'SGP', 'SGD' from dual union all
select 'SXM', 'ANG' from dual union all
select 'SVK', 'EUR' from dual union all
select 'SVN', 'EUR' from dual union all
select 'SLB', 'SBD' from dual union all
select 'SOM', 'SOS' from dual union all
select 'ZAF', 'ZAR' from dual union all
select 'ESP', 'EUR' from dual union all
select 'SSD', 'SSP' from dual union all
select 'LKA', 'LKR' from dual union all
select 'SDN', 'SDG' from dual union all
select 'SUR', 'SRD' from dual union all
select 'SWZ', 'SZL' from dual union all
select 'SWE', 'SEK' from dual union all
select 'CHE', 'CHF' from dual union all
select 'SYR', 'SYP' from dual union all
select 'TWN', 'TWD' from dual union all
select 'TJK', 'TJS' from dual union all
select 'TZA', 'TZS' from dual union all
select 'THA', 'THB' from dual union all
select 'TGO', 'XOF' from dual union all
select 'TON', 'TOP' from dual union all
select 'TTO', 'TTD' from dual union all
select 'TUN', 'TND' from dual union all
select 'TUR', 'TRY' from dual union all
select 'TKM', 'TMT' from dual union all
select 'TCA', 'USD' from dual union all
select 'TUV', 'AUD' from dual union all
select 'UGA', 'UGX' from dual union all
select 'UKR', 'UAH' from dual union all
select 'ARE', 'AED' from dual union all
select 'GBR', 'GBP' from dual union all
select 'USA', 'USD' from dual union all
select 'URY', 'UYU' from dual union all
select 'UZB', 'UZS' from dual union all
select 'VUT', 'VUV' from dual union all
select 'VAT', 'EUR' from dual union all
select 'VEN', 'VEF' from dual union all
select 'VNM', 'VND' from dual union all
select 'WLF', 'XPF' from dual union all
select 'YEM', 'YER' from dual union all
select 'ZMB', 'ZMW' from dual union all
select 'ZWE', 'BWP' from dual union all
select 'ZWE', 'GBP' from dual union all
select 'ZWE', 'EUR' from dual union all
select 'SGS', 'GBP' from dual union all
select 'AFG', 'AFN' from dual union all
select 'ALB', 'ALL' from dual union all
select 'DZA', 'DZD' from dual union all
select 'AND', 'EUR' from dual union all
select 'AGO', 'AOA' from dual union all
select 'AIA', 'XCD' from dual union all
select 'ATG', 'XCD' from dual union all
select 'ARG', 'ARS' from dual union all
select 'ARM', 'AMD' from dual union all
select 'ABW', 'AWG' from dual union all
select 'ASC', 'SHP' from dual union all
select 'AUS', 'AUD' from dual union all
select 'AUT', 'EUR' from dual union all
select 'AZE', 'AZN' from dual union all
select 'BHR', 'BHD' from dual union all
select 'BGD', 'BDT' from dual union all
select 'BRB', 'BBD' from dual union all
select 'BLR', 'BYR' from dual union all
select 'BEL', 'EUR' from dual union all
select 'BLZ', 'BZD' from dual union all
select 'BEN', 'XOF' from dual union all
select 'BMU', 'BMD' from dual union all
select 'BTN', 'BTN' from dual union all
select 'BOL', 'BOB' from dual union all
select 'BES', 'USD' from dual union all
select 'BIH', 'BAM' from dual union all
select 'BWA', 'BWP' from dual union all
select 'BRA', 'BRL' from dual union all
select 'IOT', 'USD' from dual union all
select 'VGB', 'USD' from dual union all
select 'BRN', 'BND' from dual union all
select 'BRN', 'SGD' from dual union all
select 'BGR', 'BGN' from dual union all
select 'BFA', 'XOF' from dual union all
select 'MMR', 'MMK' from dual union all
select 'MKD', 'MKD' from dual union all
select 'BHS', 'BSD' from dual union all
select 'NOR', 'NOK' from dual union all
select 'OMN', 'OMR' from dual union all
select 'PAK', 'PKR' from dual union all
select 'PLW', 'USD' from dual union all
select 'PSE', 'ILS' from dual union all
select 'PSE', 'JOD' from dual union all
select 'PAN', 'PAB' from dual union all
select 'PAN', 'USD' from dual union all
select 'PNG', 'PGK' from dual union all
select 'PRY', 'PYG' from dual union all
select 'ZWE', 'ZAR' from dual union all
select 'ZWE', 'USD' from dual union all
select 'BTN', 'INR' from dual
/

INSERT INTO "country_language" (country_id, language_id)
select 'AFG', 'ps' from dual union all
select 'AFG', 'uz' from dual union all
select 'AFG', 'tk' from dual union all
select 'ALA', 'sv' from dual union all
select 'ALB', 'sq' from dual union all
select 'DZA', 'ar' from dual union all
select 'ASM', 'en' from dual union all
select 'ASM', 'sm' from dual union all
select 'AND', 'ca' from dual union all
select 'AGO', 'pt' from dual union all
select 'AIA', 'en' from dual union all
select 'ATG', 'en' from dual union all
select 'ARG', 'es' from dual union all
select 'ARG', 'gn' from dual union all
select 'ARM', 'hy' from dual union all
select 'ARM', 'ru' from dual union all
select 'ABW', 'nl' from dual union all
select 'ABW', 'pa' from dual union all
select 'ASC', 'en' from dual union all
select 'AUS', 'en' from dual union all
select 'AUT', 'de' from dual union all
select 'AZE', 'az' from dual union all
select 'AZE', 'hy' from dual union all
select 'BHS', 'en' from dual union all
select 'BHR', 'ar' from dual union all
select 'BGD', 'bn' from dual union all
select 'BRB', 'en' from dual union all
select 'BLR', 'be' from dual union all
select 'BLR', 'ru' from dual union all
select 'BEL', 'nl' from dual union all
select 'BEL', 'fr' from dual union all
select 'BEL', 'de' from dual union all
select 'BLZ', 'en' from dual union all
select 'BLZ', 'es' from dual union all
select 'BEN', 'fr' from dual union all
select 'BMU', 'en' from dual union all
select 'BTN', 'dz' from dual union all
select 'BOL', 'es' from dual union all
select 'BOL', 'ay' from dual union all
select 'BOL', 'qu' from dual union all
select 'BES', 'nl' from dual union all
select 'BIH', 'bs' from dual union all
select 'BIH', 'hr' from dual union all
select 'BIH', 'sr' from dual union all
select 'BWA', 'en' from dual union all
select 'BWA', 'tn' from dual union all
select 'BRA', 'pt' from dual union all
select 'IOT', 'en' from dual union all
select 'VGB', 'en' from dual union all
select 'BRN', 'ms' from dual union all
select 'BGR', 'bg' from dual union all
select 'BFA', 'fr' from dual union all
select 'BFA', 'ff' from dual union all
select 'BDI', 'fr' from dual union all
select 'BDI', 'rn' from dual union all
select 'KHM', 'km' from dual union all
select 'CMR', 'en' from dual union all
select 'CMR', 'fr' from dual union all
select 'CAN', 'en' from dual union all
select 'CAN', 'fr' from dual union all
select 'CPV', 'pt' from dual union all
select 'CYM', 'en' from dual union all
select 'CAF', 'fr' from dual union all
select 'CAF', 'sg' from dual union all
select 'TCD', 'fr' from dual union all
select 'TCD', 'ar' from dual union all
select 'CHL', 'es' from dual union all
select 'CHN', 'zh' from dual union all
select 'CXR', 'en' from dual union all
select 'CCK', 'en' from dual union all
select 'COL', 'es' from dual union all
select 'COM', 'ar' from dual union all
select 'COM', 'fr' from dual union all
select 'COG', 'fr' from dual union all
select 'COG', 'ln' from dual union all
select 'COD', 'fr' from dual union all
select 'COD', 'ln' from dual union all
select 'COD', 'kg' from dual union all
select 'COD', 'sw' from dual union all
select 'COD', 'lu' from dual union all
select 'COK', 'en' from dual union all
select 'CRI', 'es' from dual union all
select 'HRV', 'hr' from dual union all
select 'CUB', 'es' from dual union all
select 'CUW', 'nl' from dual union all
select 'CUW', 'pa' from dual union all
select 'CUW', 'en' from dual union all
select 'CYP', 'el' from dual union all
select 'CYP', 'tr' from dual union all
select 'CYP', 'hy' from dual union all
select 'CZE', 'cs' from dual union all
select 'CZE', 'sk' from dual union all
select 'DNK', 'da' from dual union all
select 'DJI', 'fr' from dual union all
select 'DJI', 'ar' from dual union all
select 'DMA', 'en' from dual union all
select 'DOM', 'es' from dual union all
select 'ECU', 'es' from dual union all
select 'EGY', 'ar' from dual union all
select 'SLV', 'es' from dual union all
select 'GNQ', 'es' from dual union all
select 'GNQ', 'fr' from dual union all
select 'ERI', 'ti' from dual union all
select 'ERI', 'ar' from dual union all
select 'ERI', 'en' from dual union all
select 'EST', 'et' from dual union all
select 'ETH', 'am' from dual union all
select 'FLK', 'en' from dual union all
select 'FRO', 'fo' from dual union all
select 'FJI', 'en' from dual union all
select 'FJI', 'fj' from dual union all
select 'FJI', 'hi' from dual union all
select 'FJI', 'ur' from dual union all
select 'FIN', 'fi' from dual union all
select 'FIN', 'sv' from dual union all
select 'FRA', 'fr' from dual union all
select 'GUF', 'fr' from dual union all
select 'PYF', 'fr' from dual union all
select 'ATF', 'fr' from dual union all
select 'GAB', 'fr' from dual union all
select 'GMB', 'en' from dual union all
select 'GEO', 'ka' from dual union all
select 'DEU', 'de' from dual union all
select 'GHA', 'en' from dual union all
select 'GIB', 'en' from dual union all
select 'GRC', 'el' from dual union all
select 'GRL', 'kl' from dual union all
select 'GRD', 'en' from dual union all
select 'GLP', 'fr' from dual union all
select 'GUM', 'en' from dual union all
select 'GUM', 'ch' from dual union all
select 'GUM', 'es' from dual union all
select 'GTM', 'es' from dual union all
select 'GGY', 'en' from dual union all
select 'GGY', 'fr' from dual union all
select 'GIN', 'fr' from dual union all
select 'GIN', 'ff' from dual union all
select 'GNB', 'pt' from dual union all
select 'GUY', 'en' from dual union all
select 'HTI', 'fr' from dual union all
select 'HTI', 'ht' from dual union all
select 'HMD', 'en' from dual union all
select 'VAT', 'it' from dual union all
select 'VAT', 'la' from dual union all
select 'HND', 'es' from dual union all
select 'HKG', 'zh' from dual union all
select 'HKG', 'en' from dual union all
select 'HUN', 'hu' from dual union all
select 'ISL', 'is' from dual union all
select 'IND', 'hi' from dual union all
select 'IND', 'en' from dual union all
select 'IDN', 'id' from dual union all
select 'CIV', 'fr' from dual union all
select 'IRN', 'fa' from dual union all
select 'IRQ', 'ar' from dual union all
select 'IRQ', 'ku' from dual union all
select 'IRL', 'ga' from dual union all
select 'IRL', 'en' from dual union all
select 'IMN', 'en' from dual union all
select 'IMN', 'gv' from dual union all
select 'ISR', 'he' from dual union all
select 'ISR', 'ar' from dual union all
select 'ITA', 'it' from dual union all
select 'JAM', 'en' from dual union all
select 'JPN', 'ja' from dual union all
select 'JEY', 'en' from dual union all
select 'JEY', 'fr' from dual union all
select 'JOR', 'ar' from dual union all
select 'KAZ', 'kk' from dual union all
select 'KAZ', 'ru' from dual union all
select 'KEN', 'en' from dual union all
select 'KEN', 'sw' from dual union all
select 'KIR', 'en' from dual union all
select 'KWT', 'ar' from dual union all
select 'KGZ', 'ky' from dual union all
select 'KGZ', 'ru' from dual union all
select 'LAO', 'lo' from dual union all
select 'LVA', 'lv' from dual union all
select 'LBN', 'ar' from dual union all
select 'LBN', 'fr' from dual union all
select 'LSO', 'en' from dual union all
select 'LSO', 'st' from dual union all
select 'LBR', 'en' from dual union all
select 'LBY', 'ar' from dual union all
select 'LIE', 'de' from dual union all
select 'LTU', 'lt' from dual union all
select 'LUX', 'fr' from dual union all
select 'LUX', 'de' from dual union all
select 'LUX', 'lb' from dual union all
select 'MAC', 'zh' from dual union all
select 'MAC', 'pt' from dual union all
select 'MKD', 'mk' from dual union all
select 'MDG', 'fr' from dual union all
select 'MDG', 'mg' from dual union all
select 'MWI', 'en' from dual union all
select 'MWI', 'ny' from dual union all
select 'MDV', 'dv' from dual union all
select 'MLI', 'fr' from dual union all
select 'MLT', 'mt' from dual union all
select 'MLT', 'en' from dual union all
select 'MHL', 'en' from dual union all
select 'MHL', 'mh' from dual union all
select 'MTQ', 'fr' from dual union all
select 'MRT', 'ar' from dual union all
select 'MUS', 'en' from dual union all
select 'MYT', 'fr' from dual union all
select 'MEX', 'es' from dual union all
select 'FSM', 'en' from dual union all
select 'MDA', 'ro' from dual union all
select 'MCO', 'fr' from dual union all
select 'MNG', 'mn' from dual union all
select 'MNE', 'sr' from dual union all
select 'MNE', 'bs' from dual union all
select 'MNE', 'sq' from dual union all
select 'MNE', 'hr' from dual union all
select 'MSR', 'en' from dual union all
select 'MAR', 'ar' from dual union all
select 'MOZ', 'pt' from dual union all
select 'MMR', 'my' from dual union all
select 'NAM', 'en' from dual union all
select 'NAM', 'af' from dual union all
select 'NRU', 'en' from dual union all
select 'NRU', 'na' from dual union all
select 'NPL', 'ne' from dual union all
select 'NLD', 'nl' from dual union all
select 'NCL', 'fr' from dual union all
select 'NZL', 'en' from dual union all
select 'NZL', 'mi' from dual union all
select 'NIC', 'es' from dual union all
select 'NER', 'fr' from dual union all
select 'NGA', 'en' from dual union all
select 'NIU', 'en' from dual union all
select 'NFK', 'en' from dual union all
select 'PRK', 'ko' from dual union all
select 'ROU', 'ro' from dual union all
select 'MNP', 'en' from dual union all
select 'MNP', 'ch' from dual union all
select 'NOR', 'no' from dual union all
select 'NOR', 'nb' from dual union all
select 'NOR', 'nn' from dual union all
select 'OMN', 'ar' from dual union all
select 'PAK', 'en' from dual union all
select 'PAK', 'ur' from dual union all
select 'PLW', 'en' from dual union all
select 'PSE', 'ar' from dual union all
select 'PAN', 'es' from dual union all
select 'PNG', 'en' from dual union all
select 'PRY', 'es' from dual union all
select 'PRY', 'gn' from dual union all
select 'PER', 'es' from dual union all
select 'PHL', 'en' from dual union all
select 'PCN', 'en' from dual union all
select 'POL', 'pl' from dual union all
select 'PRT', 'pt' from dual union all
select 'PRI', 'es' from dual union all
select 'PRI', 'en' from dual union all
select 'QAT', 'ar' from dual union all
select 'KOS', 'sq' from dual union all
select 'KOS', 'sr' from dual union all
select 'REU', 'fr' from dual union all
select 'RUS', 'ru' from dual union all
select 'RWA', 'rw' from dual union all
select 'RWA', 'en' from dual union all
select 'RWA', 'fr' from dual union all
select 'BLM', 'fr' from dual union all
select 'SHN', 'en' from dual union all
select 'KNA', 'en' from dual union all
select 'LCA', 'en' from dual union all
select 'MAF', 'en' from dual union all
select 'MAF', 'fr' from dual union all
select 'MAF', 'nl' from dual union all
select 'SPM', 'fr' from dual union all
select 'VCT', 'en' from dual union all
select 'WSM', 'sm' from dual union all
select 'WSM', 'en' from dual union all
select 'SMR', 'it' from dual union all
select 'STP', 'pt' from dual union all
select 'SAU', 'ar' from dual union all
select 'SEN', 'fr' from dual union all
select 'SRB', 'sr' from dual union all
select 'SYC', 'fr' from dual union all
select 'SYC', 'en' from dual union all
select 'SLE', 'en' from dual union all
select 'SGP', 'en' from dual union all
select 'SGP', 'ms' from dual union all
select 'SGP', 'ta' from dual union all
select 'SGP', 'zh' from dual union all
select 'SXM', 'nl' from dual union all
select 'SXM', 'en' from dual union all
select 'SVK', 'sk' from dual union all
select 'SVN', 'sl' from dual union all
select 'SLB', 'en' from dual union all
select 'SOM', 'so' from dual union all
select 'SOM', 'ar' from dual union all
select 'ZAF', 'af' from dual union all
select 'ZAF', 'en' from dual union all
select 'ZAF', 'nr' from dual union all
select 'ZAF', 'st' from dual union all
select 'ZAF', 'ss' from dual union all
select 'ZAF', 'tn' from dual union all
select 'ZAF', 'ts' from dual union all
select 'ZAF', 've' from dual union all
select 'ZAF', 'xh' from dual union all
select 'ZAF', 'zu' from dual union all
select 'SGS', 'en' from dual union all
select 'KOR', 'ko' from dual union all
select 'SSD', 'en' from dual union all
select 'ESP', 'es' from dual union all
select 'ESP', 'eu' from dual union all
select 'ESP', 'ca' from dual union all
select 'ESP', 'gl' from dual union all
select 'ESP', 'oc' from dual union all
select 'LKA', 'si' from dual union all
select 'LKA', 'ta' from dual union all
select 'SDN', 'ar' from dual union all
select 'SDN', 'en' from dual union all
select 'SUR', 'nl' from dual union all
select 'SJM', 'no' from dual union all
select 'SWZ', 'en' from dual union all
select 'SWZ', 'ss' from dual union all
select 'SWE', 'sv' from dual union all
select 'CHE', 'de' from dual union all
select 'CHE', 'fr' from dual union all
select 'CHE', 'it' from dual union all
select 'SYR', 'ar' from dual union all
select 'TWN', 'zh' from dual union all
select 'TJK', 'tg' from dual union all
select 'TJK', 'ru' from dual union all
select 'TZA', 'sw' from dual union all
select 'TZA', 'en' from dual union all
select 'THA', 'th' from dual union all
select 'TLS', 'pt' from dual union all
select 'TGO', 'fr' from dual union all
select 'TKL', 'en' from dual union all
select 'TON', 'en' from dual union all
select 'TON', 'to' from dual union all
select 'TTO', 'en' from dual union all
select 'TUN', 'ar' from dual union all
select 'TUR', 'tr' from dual union all
select 'TKM', 'tk' from dual union all
select 'TKM', 'ru' from dual union all
select 'TCA', 'en' from dual union all
select 'TUV', 'en' from dual union all
select 'UGA', 'en' from dual union all
select 'UGA', 'sw' from dual union all
select 'UKR', 'uk' from dual union all
select 'ARE', 'ar' from dual union all
select 'GBR', 'en' from dual union all
select 'USA', 'en' from dual union all
select 'UMI', 'en' from dual union all
select 'VIR', 'en' from dual union all
select 'URY', 'es' from dual union all
select 'UZB', 'uz' from dual union all
select 'UZB', 'ru' from dual union all
select 'VUT', 'bi' from dual union all
select 'VUT', 'en' from dual union all
select 'VUT', 'fr' from dual union all
select 'VEN', 'es' from dual union all
select 'VNM', 'vi' from dual union all
select 'WLF', 'fr' from dual union all
select 'ESH', 'es' from dual union all
select 'YEM', 'ar' from dual union all
select 'ZMB', 'en' from dual union all
select 'ZWE', 'en' from dual union all
select 'ZWE', 'sn' from dual union all
select 'ZWE', 'nd' from dual
/

declare

  procedure monthintl
    ( langid in varchar2,
      months in strarray )
  is
  begin
    if months.count() != 12 then
      RAISE_APPLICATION_ERROR(-20001, 'Must have 12 months!');
    end if;

    insert into "i18n_translation" (namespace, identifier, language_id, text)
      select 'PUBLIC',
              case rownum
               when  1 then 'month.01'
               when  2 then 'month.02'
               when  3 then 'month.03'
               when  4 then 'month.04'
               when  5 then 'month.05'
               when  6 then 'month.06'
               when  7 then 'month.07'
               when  8 then 'month.08'
               when  9 then 'month.09'
               when 10 then 'month.10'
               when 11 then 'month.11'
               when 12 then 'month.12'
             end theKey,
             langid,
             column_value mon
        from table(months);

  end monthintl;

begin
  monthintl('en', strarray('January','February','March','April','May','June','July','August','September','October','November','December'));
  monthintl('ar', strarray('يناير','فبراير','مسيرة','أبريل','قد','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'));
  monthintl('af', strarray('Januarie','Februarie','Maart','April','Mei','Junie','Julie','Augustus','September','Oktober','November','Desember'));
  monthintl('sq', strarray('janar','shkurt','mars','prill','mund','qershor','korrik','gusht','shtator','tetor','nëntor','dhjetor'));
  monthintl('hy', strarray('հունվար','փետրվար','մարտ','ապրիլ','մայիս','հունիս','հուլիս','օգոստոս','սեպտեմբեր','հոկտեմբեր','նոյեմբեր','դեկտեմբեր'));
  monthintl('az', strarray('yanvar','fevral','mart','aprel','may','İyun','iyul','avqust','sentyabr','oktyabr','noyabr','dekabr'));
  monthintl('eu', strarray('urtarrila','Otsaila','Martxoa','Apirila','Maiatza','Ekaina','Uztaila','abuztua','iraila','urria','azaroa','abendua'));
  monthintl('be', strarray('студзеня','лютага','Сакавік','красавіка','Май','чэрвеня','ліпеня','Жнівень','верасня','Кастрычнік','лістапада','сьнежня'));
  monthintl('bn', strarray('জানুয়ারী','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','অগাস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'));
  monthintl('bs', strarray('siječanj','februar','mart','april','maj','jun','juli','avgust','septembar','oktobar','novembar','decembar'));
  monthintl('bg', strarray('януари','февруари','март','април','май','юни','юли','август','септември','октомври','ноември','декември'));
  monthintl('ca', strarray('gener','febrer','març','abril','maig','juny','juliol','agost','setembre','octubre','novembre','desembre'));
  monthintl('zh', strarray('一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'));
  monthintl('ja', strarray('一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'));
  monthintl('hr', strarray('siječanj','veljača','ožujak','travanj','svibanj','lipanj','srpanj','kolovoz','rujan','listopad','studeni','prosinac'));
  monthintl('cs', strarray('leden','únor','březen','duben','květen','červen','červenec','srpen','září','říjen','listopad','prosinec'));
  monthintl('da', strarray('januar','februar','marts','april','maj','juni','juli','august','september','oktober','november','december'));
  monthintl('nl', strarray('januari','februari','maart','april','mei','juni','juli','augustus','september','oktober','november','december'));
  monthintl('eo', strarray('januaro','februaro','marto','aprilo','majo','junio','julio','aŭgusto','septembro','oktobro','novembro','decembro'));
  monthintl('et', strarray('jaanuar','veebruar','märts','aprill','mai','juuni','juuli','august','september','oktoober','november','detsember'));
  monthintl('fi', strarray('tammikuu','helmikuu','maaliskuu','huhtikuu','saattaa','kesäkuu','heinäkuu','elokuu','syyskuu','lokakuu','marraskuu','joulukuu'));
  monthintl('fr', strarray('janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre'));
  monthintl('gl', strarray('Xaneiro','febreiro','marzo','abril','maio','xuño','xullo','agosto','setembro','outubro','novembro','decembro'));
  monthintl('ka', strarray('იანვარი','თებერვალი','მარტი','აპრილი','მაისი','ივნისი','ივლისი','აგვისტო','სექტემბერი','ოქტომბერი','ნოემბერი','დეკემბერი'));
  monthintl('de', strarray('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'));
  monthintl('el', strarray('Ιανουάριος','Φεβρουάριος','Μάρτιος','Απρίλιος','Μάιος','Ιούνιος','Ιούλιος','Αύγουστος','Σεπτέμβριος','Οκτώβριος','Νοέμβριος','Δεκέμβριος'));
  monthintl('gu', strarray('જાન્યુઆરી','ફેબ્રુઆરી','માર્ચ','એપ્રિલ','મે','જૂન','જુલાઈ','ઓગસ્ટ','સપ્ટેમ્બર','ઑક્ટોબર','નવેમ્બર','ડિસેમ્બર'));
  monthintl('ht', strarray('janvye','fevriye','mas','avril','Me','jen','Jiyè','Out','septanm','Oktòb','Novanm','Desanm'));
  monthintl('ha', strarray('Janairu','Fabrairu','Maris','Afrilu','Mayu','Yuni','Yuli','Agusta','Satumba','Oktoba','Nuwamba','Disamba'));
  monthintl('he', strarray('ינואר','פברואר','מרץ','אפריל','מאי','יוני','יולי','אוגוסט','ספטמבר','אוקטובר','נובמבר','דצמבר'));
  monthintl('hi', strarray('जनवरी','फरवरी','मार्च','अप्रैल','मई','जून','जुलाई','अगस्त','सितंबर','अक्टूबर','नवंबर','दिसंबर'));
  monthintl('hu', strarray('január','február','március','április','május','június','július','augusztus','szeptember','október','november','december'));
  monthintl('is', strarray('janúar','febrúar','mars','apríl','Maí','júní','júlí','ágúst','September','október','nóvember','desember'));
  monthintl('id', strarray('Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'));
  monthintl('ga', strarray('eanáir','Feabhra','Márta','aibreán','Bealtaine','Meitheamh','Iúil','Lúnasa','Meán Fómhair','Deireadh Fómhair','Samhain','nollaig'));
  monthintl('it', strarray('gennaio','febbraio','marzo','aprile','maggio','giugno','luglio','agosto','settembre','ottobre','novembre','dicembre'));
  monthintl('kn', strarray('ಜನವರಿ','ಫೆಬ್ರುವರಿ','ಸರಹದ್ದು','ಏಪ್ರಿಲ್','ಮೇ ತಿಂಗಳು','ಜೂನ್','ಜೂಲೈ','ಮಹಾವೈಭವದ','ಇಂಗ್ಲಿಷ್ ವರ್ಷದ 9 ನೇ ತಿಂಗಳು','ಅಕ್ಟೋಬರ್','ನವೆಂಬರ್','ಡಿಸೆಂಬರ್ ತಿಂಗಳು'));
  monthintl('km', strarray('ខែមករា','ខែកុម្ភៈ','ខែមីនា','ខែមេសា','ឧសភា','ខែមិថុនា','ខែកក្កដា','ខែសីហា','ខែកញ្ញា','ខែតុលា','ខែវិច្ឆិកា','ខែធ្នូ'));
  monthintl('fa', strarray('ژانویه','فوریه','مارس','آوریل','مه','ژوئن','جولای','اوت','سپتامبر','اکتبر','نوامبر','دسامبر'));
  monthintl('pl', strarray('styczeń','luty','marzec','kwiecień','maj','czerwiec','lipiec','sierpień','wrzesień','październik','listopad','grudzień'));
  monthintl('pt', strarray('janeiro','fevereiro','março','abril','maio','junho','julho','agosto','setembro','outubro','novembro','dezembro'));
  monthintl('ru', strarray('январь','февраль','март','апрель','май','июнь','июль','август','сентябрь','октябрь','ноябрь','декабрь'));
  monthintl('sr', strarray('јануар','фебруар','март','април','мај','јун','јул','август','септембар','октобар','новембар','децембар'));
  monthintl('es', strarray('enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'));
  monthintl('ta', strarray('ஆங்கில ஆண்டின் முதல் மாதம்','பிப்ரவரி','மார்ச்','ஏப்ரல்','கூடும்','ஜூன்','ஜூலை','ஆகஸ்ட்','செப்டம்பர்','அக்டோபர்','நவம்பர்','டிசம்பர்'));
  monthintl('te', strarray('జనవరి','ఫిబ్రవరి','మార్చి','నాలుగో నెల','యౌవన','జూన్','జూలై','ఆగష్టు','సెప్టెంబర్','ఇంగ్లీషు నెలలో ఒకటి','నవంబర్','డిసెంబర్'));
  monthintl('th', strarray('มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'));
  monthintl('tr', strarray('Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'));
  monthintl('uk', strarray('січень','лютий','Березень','Квітень','травень','Червень','Липень','Серпень','вересень','Жовтень','Листопад','грудень'));
  monthintl('ur', strarray('جنوری','فروری','مارچ','اپریل','مئی','جون','جولائی','اگست','ستمبر','اکتوبر','نومبر','دسمبر'));
  monthintl('yi', strarray('יאַנואַר','פעברואַר','מאַרץ','אַפּריל','מייַ','יוני','יולי','ויגוסט','סעפּטעמבער','אָקטאָבער','נאָוועמבער','דעצעמבער'));
  monthintl('yo', strarray('Oṣù','Kínní','Oṣù','Kẹrin','le','Oṣù','Keje','Oṣù','Kẹsán','Oṣù','Oṣù','Kejìlá'));
  commit;
end;
/

declare
  procedure dowintl
    ( langid   in varchar2,
      dows     in strarray )
  is
  begin
    if dows.count() != 7 then
      RAISE_APPLICATION_ERROR(-20001, 'Must have 7 days!');
    end if;

    insert into "i18n_translation" (namespace, identifier, language_id, text)
      select  'PUBLIC',
              -- these arrays start with Monday, which is really day 2
              case rownum
                when 1 then 'dow.2'
                when 2 then 'dow.3'
                when 3 then 'dow.4'
                when 4 then 'dow.5'
                when 5 then 'dow.6'
                when 6 then 'dow.7'
                when 7 then 'dow.1'
              end,
              langid,
              column_value
        from table(dows);

  end dowintl;

begin
  dowintl('en', strarray('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'));
  dowintl('ab', strarray('Ашәахь','Аҩаш','Ахаш','Аҧшьаш','Ахәаш','Асабш','Амҽыш'));
  dowintl('af', strarray('Maandag','Dinsdag','Woensdag','Donderdag','Vrydag','Saterdag','Sondag'));
  dowintl('sq', strarray('e hënë','e martë','e mërkurë','e enjte','e premte','e shtunë','e diel'));
  dowintl('am', strarray('ሰኞ','ማክሰኞ','ረቡዕ','ሐሙስ','ዓርብ','ቅዳሜ','እሑድ'));
  dowintl('ar', strarray('يوم الإثنين','يوم الثلاثاء','يوم الأربعاء','يوم الخميس','يوم الجمعة','يوم السبت','يوم الأحد'));
  dowintl('an', strarray('Luns','Martes','Miércols','Chuebes','Biernes','Sabado','Domingo'));
  dowintl('hy', strarray('Երկուշաբթի','Երեքշաբթի','Չորեքշաբթի','Հինգշաբթի','Ուրբաթ','Շաբաթ','Կիրակի'));
  dowintl('az', strarray('Bazar ertəsi','Çərşənbə axşamı','Çərşənbə','Cümə axşamı','Cümə','Şənbə','Bazar'));
  dowintl('eu', strarray('astelehena','asteartea','asteazkena','osteguna','ostirala','larunbata','igandea'));
  dowintl('be', strarray('панядзелак','аўторак','серада','чацьвер','пятніца','сыбота','нядзеля'));
  dowintl('bs', strarray('ponedeljak','utorak','srijeda','cxetvrtak','petak','subota','nedjelja'));
  dowintl('br', strarray('dilun','dimeurz','dimerher','diriaou','digwener','disadorn','disul'));
  dowintl('bg', strarray('понеделник','вторник','сряда','четвъртък','петък','събота','неделя'));
  dowintl('ca', strarray('dilluns','dimarts','dimecres','dijous','divendres','dissabte','diumenge'));
  dowintl('ce', strarray('Оршот','Шинара','Кхаара','Еара','П1ераска','Шот','К1иранде'));
  dowintl('zh', strarray('星期一','星期二','星期三','星期四','星期五','星期六','星期日'));
  dowintl('kw', strarray('dy'' Lun','dy'' Meurth','dy'' Mergher','dy'' Yow','dy'' Gwener','dy'' Sadorn','dy'' Sul'));
  dowintl('co', strarray('luni','marti','marcuri','ghjovi','venneri','sabbatu','dumenica'));
  dowintl('hr', strarray('ponedjeljak','utorak','srijeda','četvrtak','petak','subota','nedjelja'));
  dowintl('cs', strarray('pondĕlí','úterý','středa','čtvrtek','pátek','sobota','nedĕle'));
  dowintl('da', strarray('mandag','tirsdag','onsdag','torsdag','fredag','lørdag','søndag'));
  dowintl('nl', strarray('maandag','dinsdag','woensdag','donderdag','vrijdag','zaterdag','zondag'));
  dowintl('dz', strarray('གཟའ་མིག་དམར་','གཟའ་ལྷག་པ་','གཟའ་ཕུར་བུ་','གཟའ་པ་སངས་','གཟའ་སྤེན་པ་','གཟའ་ཉི་མ་','གཟའ་ཟླ་བ་'));
  dowintl('et', strarray('esmaspäev','teisipäev','kolmapäev','neljapäev','reede','laupäev','pühapäev'));
  dowintl('fo', strarray('mánadagur','týsdagur','mikudagur','hósdagur','fríggjadagur','leygardagur','sunnudagur'));
  dowintl('fj', strarray('Mōniti','Tūsiti','Vukelulu','Lotulevu','Vakaraubuka','Vakarauwai','Sigatabu'));
  dowintl('fi', strarray('maanantai','tiistai','keskiviikko','torstai','perjantai','lauantai','sunnuntai'));
  dowintl('fr', strarray('lundi','mardi','mercredi','jeudi','vendredi','samedi','dimanche'));
  dowintl('gl', strarray('luns','martes','mércores','xoves','venres','sábado','domingo'));
  dowintl('ka', strarray('ორშაბათი','სამშაბათი','ოთხშაბათი','ხუთშაბათი','პარასკევი','შაბათი','კვირა'));
  dowintl('de', strarray('Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag','Sonntag'));
  dowintl('el', strarray('Δευτέρα','Τρίτη','Τετάρτη','Πέμπτη','Παρασκευή','Σάββατο','Κυριακή'));
  dowintl('gu', strarray('સોમવાર','મંગળવાર','બુધવાર','ગુરુવાર','શુક્રવાર','શનિવાર','રવિવાર'));
  dowintl('ht', strarray('lendi','madi','mèkre','dijedi','vandredi','samdi','dimanch'));
  dowintl('he', strarray('יום שני','יום שלישי','יום רביעי','יום חמישי','יום שישי','יום שבת','יום ראשון'));
  dowintl('hi', strarray('सोमवार','मंगलवार','बुधवार','गुरुवार','शुक्रवार','शनिवार','रविवार'));
  dowintl('hu', strarray('hétfő','kedd','szerda','csütörtök','péntek','szombat','vasárnap'));
  dowintl('is', strarray('mánudagur','þriðjudagur','miðvikudagur','fimmtudagur','föstudagur','laugardagur','sunnudagur'));
  dowintl('id', strarray('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'));
  dowintl('ga', strarray('Dé Luan','Dé Mairt','Dé Céadaoin','Déardaoin','Dé h-Aoine','Dé Sathairn','Dé Domhnaigh'));
  dowintl('it', strarray('lunedì','martedì','mercoledì','giovedì','venerdì','sabato','domenica'));
  dowintl('ja', strarray('月曜日','火曜日','水曜日','木曜日','金曜日','土曜日','日曜日'));
  dowintl('kk', strarray('дүйсенбi','сейсенбi','сәрсенбі','бейсенбі','жұма','сенбі','жексенбi'));
  dowintl('ko', strarray('월요일','화요일','수요일','목요일','금요일','토요일','일요일'));
  dowintl('la', strarray('diēs lūnae','diēs martis','diēs mercurī','diēs iovis','diēs veneris','diēs saturnī','diēs solis'));
  dowintl('lv', strarray('pirmdiena','otrdiena','trešdiena','ceturtdiena','piektdiena','sestdiena','svētdiena'));
  dowintl('li', strarray('Maondig','Daensdig','Goonsdig','Dónderdig','Vriedig','Zaoterdig','Zóndig'));
  dowintl('lt', strarray('Pirmadienis','Antradienis','Trečiadienis','Ketvirtadienis','Penktadienis','Šeštadienis','Sekmadienis'));
  dowintl('lb', strarray('Méindeg','Dënschdeg','Mëttwoch','Donneschdeg','Freideg','Samschdeg','Sonndeg'));
  dowintl('mk', strarray('Понеделник','Вторник','Среда','Четврток','Петок','Сабота','Недела'));
  dowintl('ms', strarray('Isnin','Selasa','Rabu','Khamis','Jumaat','Sabtu','Ahad'));
  dowintl('mt', strarray('it-Tnejn','it-Tlieta','l-Erbgħa','il-Ħamis','il-Ġimgħa','is-Sibt','il-Ħadd'));
  dowintl('gv', strarray('Jelhune','Jemayrt','Jecrean','Jerdein','Jeheiney','Jesarn','Jedoonee'));
  dowintl('mi', strarray('rāhine','rātū','rāapa','rāpare','rāmere','rāhoroi','rātapu'));
  dowintl('mh', strarray('Jabōt','M̧ande','Juje','Wōnje','Taije','Bōraide','Jādede'));
  dowintl('mn', strarray('даваа','мягмар','лхагва','пүрэв','баасан','бямба','ням'));
  dowintl('ne', strarray('सोमबार','मंगलबार','बुधबार','बिहीबार','शुक्रबारbr','शनिबार','आइतबार'));
  dowintl('nb', strarray('mandag','tirsdag','onsdag','torsdag','fredag','lørdag','søndag'));
  dowintl('nn', strarray('måndag','tysdag','onsdag','torsdag','fredag','laurdag','sundag'));
  dowintl('no', strarray('måndag','tysdag','onsdag','torsdag','fredag','laurdag','sundag'));
  dowintl('oc', strarray('diluns','dimars','dimècres','dijóus','divendres','dissabte','dimenge'));
  dowintl('fa', strarray('دوشنبه','سهشنبه','چهارشنبه','پنجشنبه','جمعه','شنبه','یکشنبه'));
  dowintl('pl', strarray('poniedziałek','wtorek','środa','czwartek','piątek','sobota','niedziela'));
  dowintl('pt', strarray('segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','sábado','domingo'));
  dowintl('qu', strarray('Killachau','Atipachau','Qoyllurchau','Illapachau','Ch''askachau','K''uychichau','Intichu'));
  dowintl('rm', strarray('luni','marţi','miercuri','joi','vineri','sîmbătă','duminică'));
  dowintl('ru', strarray('понедельник','вторник','среда','четверг','пятница','суббота','воскресенье'));
  dowintl('sm', strarray('Aso Gafua','Aso Lua','Aso Lulu','Aso Tofi','Aso Faraile','Aso To''ona''i','Aso Sā'));
  dowintl('sa', strarray('इन्दुवासरम्','भौमवासरम्','सौम्यवासरम्','गुरूवासरम','भ्रगुवासरम्','स्थिरवासरम्','भानुवासरम्'));
  dowintl('sc', strarray('lunis','martis','mércuris','giòvia','chenábura','sáppadu','dumíniga'));
  dowintl('gd', strarray('Diluain','Dimàirt','Diciadain','Diardaoin','Dihaoine','Disatharna','Didòmhnaich'));
  dowintl('sr', strarray('Понедељак','Уторак','Среда','Четвртак','Петак','Субота','Недеља'));
  dowintl('st', strarray('Mantaha','Labobedi','Laboraro','Labone','Labohlano','Moqebelo','Sontaha'));
  dowintl('sk', strarray('pondelok','utorok','streda','štvrtok','piatok','sobota','nedel''a'));
  dowintl('sl', strarray('Ponedeljek','Torek','Sreda','Četrtek','Petek','Sobota','Nedelja'));
  dowintl('es', strarray('lunes','martes','miércoles','jueves','viernes','sábado','domingo'));
  dowintl('sw', strarray('jumatatu','jumanne','jumatano','alhamisi','ijumaa','jumamosi','jumapili'));
  dowintl('sv', strarray('måndag','tisdag','onsdag','torsdag','fredag','lördag','söndag'));
  dowintl('tl', strarray('Lunes','Martes','Miyerkules','Huwebes','Biyernes','Sabado','Linggo'));
  dowintl('ty', strarray('Monirē','Mahana Piti','Mahana Toru','Mahana Maha','Mahana Pae','Mahana Mā''a','Tāpati'));
  dowintl('ta', strarray('திங்கள்','செவ்வாய்','புதன்','வியாழன','வெள்ளி','சனி','ஞாயிறு'));
  dowintl('th', strarray('วันจันทร์','วันอังคาร','วันพุธ','วันพฦหัสบดี','วันศุกร์','วันเสาร์','วันอาทิตย์'));
  dowintl('bo', strarray('གཟའ་ཟླ་བ་','གཟའ་མིག་དམར་','གཟའ་ལྷག་པ་','གཟའ་ཕུར་བུ་','གཟའ་པ་སངས་','གཟའ་སྤེན་པ་','གཟའ་ཉི་མ་'));
  dowintl('ts', strarray('Musumbhunuku','Ravumbirhi','Ravunharhu','Ravumune','Ravuntlhanu','Mugqivela','Sonto'));
  dowintl('tr', strarray('Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'));
  dowintl('uk', strarray('понеділок','вівторок','середа','четвер','п''ятниця','субота','неділя'));
  dowintl('ur', strarray('پير','منگل','بدھ','جمعرات','جمعہ','ہفتہ','اتوار'));
  dowintl('uz', strarray('Dushanba','Seshanba','Chorshanba','Payshanba','Juma','Shanba','Yakshanba'));
  dowintl('ve', strarray('Musumbuluwo','Ḽavhuvhili','Ḽavhuraru','Ḽavhuṋa','Ḽavhutanu','Mugivhela','Swondaha'));
  dowintl('wa', strarray('londi','mårdi','mierkidi','djudi','vénrdi','semdi','dimenge'));
  dowintl('cy', strarray('dydd Llun','dydd Mawrth','dydd Mercher','dydd Iau','dydd Gwener','dydd Sadwrn','dydd Sul'));
  dowintl('vi', strarray('thứ hai','thứ ba','thứ tư','thứ năm','thứ sáu','thứ bảy','chủ nhật'));
  dowintl('yi', strarray('מאָנטיק','דינסטיק','מיטװאָך','דאָנערשטיק','פֿרײַטיק','שבת','זונטיק'));
  dowintl('zu', strarray('uMombuluko','uLwesibili','uLwesithathu','uLwesine','uLewishlanu','uMgqibelo','iSonto'));
  commit;
end;
/
