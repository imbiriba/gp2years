function [okta alt] = tak_metar2okta(metar)
%  function [okta alt] = tak_metar2okta(metar)
%  metar - cell array of a cloud metar string, e.g. 'BKN030 FEW035'.
%  okta  - array of cloud oktas taken from the table:
%  alt   - array of cloud heights taken from the METAR codes. (in feet)
%
%  Translate METAR three-letter codes into 'okta' equivalent. 
%  If no string is present, register as CLEAR SKY.
%  If an invalid string is present, flag as INVALID with -1.
%
%  https://www.eoas.ubc.ca/courses/atsc113/flying/met_concepts/01-met_concepts/01c-cloud_coverage/index.html
%  From Stull, 2017: Practical Meteorology: An Algebra-based Survey of Atmospheric Science.
%
%  0	SKC  (CLR)
%  1	FEW
%  2	FEW	<<< this
%  3	SCT
%  4	SCT 	<<< this
%  5	BKN
%  6	BKN	<<< this
%  7	BKN
%  8	OVC
%
%  When no string is present, will assum it's OVC. 
%
%  See also: 	https://en.wikipedia.org/wiki/Okta
%		https://en.wikipedia.org/wiki/METAR
%		https://aviationweather.gov/static/help/taf-decode.php#Sky
% B.I. 2019.06.04

if(~iscell(metar))
  metar = {metar};
end

npt = numel(metar);

okta = -1*ones(1,npt);
alt = -1*ones(1,npt);

for ic=1:npt
  avi = metar{ic};
  if(numel(strfind(avi,'OVC'))>0)
    okta(ic) = 8;
    alt(ic) = str2num(avi(4:6))*100;
  elseif(numel(strfind(avi,'BKN'))>0)
    okta(ic) = 6;
    alt(ic) = str2num(avi(4:6))*100;
  elseif(numel(strfind(avi,'SCT'))>0)
    okta(ic) = 4;
    alt(ic) = str2num(avi(4:6))*100;
  elseif(numel(strfind(avi,'FEW'))>0)
    okta(ic) = 2;
    alt(ic) = str2num(avi(4:6))*100;
  elseif(numel(strfind(avi,'SKC'))>0 | numel(strfind(avi,'CLR'))>0)
    okta(ic) = 0;
    alt(ic) = str2num(avi(4:6))*100;
  elseif(numel(avi)==0)
    okta(ic) = 0; % When there is no okta present, assume it's clear.
    alt(ic) = -1;
    disp(['No cloud cover present']);
  else
    okta(ic) = -1; % If an invalid string is present, flag as invalid.
    alt(ic) = -1; 
    disp(['Invalid cloud cover info: ' avi '.']);
    keyboard;
  end
end


