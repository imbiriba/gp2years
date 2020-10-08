function uni = stationdata_uniformfields(rawuni)
% function uni = stationdata_uniformfields(rawuni)
% 
% Conver field names of standard fields to a common name. 
% Other fields are kept as original.
%
%
% mtime - mdate,TIME
% T	- temp, TMP
% Tmax	- tmax	
% Tmin	- tmin
% H	- relh, RH
% D	- DEW
% P	- press
% Wspd	- wspeed, SPD
% Wmax	- wmax
% Wdir	- wdir, DIR
% Rad	- rad
% Prec	- prec
% 
% Other fields remain as they are
% B.I. 2020.05.10



fnames = fieldnames(rawuni);

for ifn=1:numel(fnames)
  switch fnames{ifn}
    case {'mdate','TIME'}
      uni.mtime = rawuni.(fnames{ifn});
    case {'temp','TMP'}
      uni.T = rawuni.(fnames{ifn});
    case 'tmax'
      uni.Tmax = rawuni.(fnames{ifn});
    case 'tmin'
      uni.Tmin = rawuni.(fnames{ifn});
    case {'relh','RH'}
      uni.H = rawuni.(fnames{ifn});
    case 'DEW'
      uni.D = rawuni.(fnames{ifn});
    case 'press'
      uni.P = rawuni.(fnames{ifn});
    case {'wspeed','SPD'}
      uni.Wspd = rawuni.(fnames{ifn});
    case 'wmax'
      uni.Wmax = rawuni.(fnames{ifn});
    case {'wdir','DIR'}
      uni.Wdir = rawuni.(fnames{ifn});
    case 'rad'
      uni.Rad = rawuni.(fnames{ifn});
    case 'prec'
      uni.Prec = rawuni.(fnames{ifn});
    otherwise
      uni.(fnames{ifn}) = rawuni.(fnames{ifn});
  end


end
