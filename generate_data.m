function [inmet sbbe vale] = generate_data();
% function [inmet sbbe vale] = generate_data();
%
% Load 2 years of data from all three stations

%startup_breno
%addpath /home/imbiriba/matlab/Scr/Date
%addpath /home/imbiriba/matlab/Scr/Prof

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in INMET data from new format yearly files
f2018 = '/gea/data/towers/inmet-belem/raw2018.txt';
f2019 = '/gea/data/towers/inmet-belem/raw2019.txt';


% Data fields:
dfds = {'T','Tmax','Tmin','H','Hmax','Hmin','D','Dmax','Dmin','P','Pmax','Pmin','Wspd','Wdir','Wmax','Rad','Prec'};
unit = {'°C','°C','°C','%','%','%','°C','°C','°C','mbar','mbar','mbar','m/s','m/s','m/s','KJ/m²','mm'};

% Load 2018
tmp = importdata(f2018,'\t',10);
nskip = size(tmp.textdata,1)-size(tmp.data,1)+1;
mdate = datenum(char(tmp.textdata{nskip:end,1}),'dd/mm/yyyy');
mhour = tmp.data(:,1)./2400;
mdate = mdate+mhour;
% convert to local:
mdate = mdate - 3.0./24;

data2018=[];
data2018.mdate = mdate;
for ii=1:17
  data2018.(dfds{ii}) = tmp.data(:,ii+1);
end


% Load 2019
tmp = importdata(f2019,'\t',10);
nskip = size(tmp.textdata,1)-size(tmp.data,1)+1;
mdate = datenum(char(tmp.textdata{nskip:end,1}),'dd/mm/yyyy');
mhour = tmp.data(:,1)./2400;
mdate = mdate+mhour;
% convert to local:
mdate = mdate - 3.0./24;

data2019=[];
data2019.mdate = mdate;
for ii=1:17
  data2019.(dfds{ii}) = tmp.data(:,ii+1);
end


% Join both

fnms = fields(data2018);
for ii=1:numel(fnms)
  inmet.(fnms{ii}) = cat(1,data2018.(fnms{ii}),data2019.(fnms{ii}));
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SBBE - UWYO



date0 = [2018,1,1,0,0,0];
date1 = [2019,12,31,0,0,0];

% Inmet:
sbbedir='/gea/data/towers/sbbe';

clear sbbe1d
lp=dateloop();
dateloop('start',lp)
step = [0 0 1 0 0 0];
iday=0; fn={};
while(dateloop(date0,step,date1,lp))
  vdate = dateloop('date',lp);
  fntmp = sprintf('%4d/UWYO_%4d.%02d.%02d.txt',vdate(1),vdate(1),vdate(2),vdate(3));
  if(exist([sbbedir '/' fntmp],'file'))
    iday = iday+1;
    fn = [sbbedir '/' fntmp];
    %disp(['Reading File ' fn '.']);

    % Read UWYO data
    sbbe1d(iday) = read_uwyo_data(fn);

    % Generate daily data structure array
    %
  else
    disp(['File ' fntmp ' does not exist.']);
  end
end

% Join structures
sbbe1 = Prof_join_arr(sbbe1d);

% Convert METAR codes
[okta calt] = taf_metar2okta(sbbe1.CLOUDS);
sbbe1.okta = okta;
sbbe1.calt = calt;


% Sort and remove possible duplicated dates
[~, ia, ic] = uniquetol(sbbe1.TIME);

sbbe = struct();
fnames = fieldnames(sbbe1);
for ii=1:numel(fnames)
  sbbe.(fnames{ii}) = sbbe1.(fnames{ii})(:,ia);
end
 
% Correct time to LOCAL
sbbe.TIME = sbbe.TIME-3.0/24;

% Unit conversion
%
inHg2mbar = 33.863886;
knot2mps  = 0.5144444;
mile2m    = 1609.344;
ft2m      = 0.3048;
sbbe.ALTM = sbbe.ALTM*inHg2mbar;
sbbe.TMP  = (sbbe.TMP-32)*5/9;
sbbe.SPD  = sbbe.SPD*knot2mps;
sbbe.VIS  = sbbe.VIS*mile2m;
sbbe.calt = sbbe.calt*ft2m;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load VALE data
%

date0 = [2017,12,1,0,0,0];
date1 = [2019,12,31,0,0,0];

% Vale:
sbbedir='/gea/data/towers/vale-ufpa';

lp=dateloop();
dateloop('start',lp)
step = [0 1 0 0 0 0];
imon=0; fn={};
vale1m = struct();
while(dateloop(date0,step,date1,lp))
  vdate = dateloop('date',lp);
  fntmp = sprintf('belem_itv_%4d_%02d.csv',vdate(1),vdate(2));
  if(exist([sbbedir '/' fntmp],'file'))
    imon = imon+1;
    fn = [sbbedir '/' fntmp];
    %disp(['Reading File ' fn '.']);

    data = importdata(fn,',');
    if(numel(data)==0)
      disp(['No data from file ' fn '.']);
      continue
    end

    % rad    -  radiation (W/m²) !!!

    vfds = {'mtime','temp','tmax','tmin','wspeed','wmax','wdir','wdirsd','relh','prec','rad','press'};

    vale1m(imon).mtime = datenum(data(:,1:6));
    for ii=2:numel(vfds)
      vale1m(imon).(vfds{ii}) = data(:,ii+5);
    end
  else
    disp(['File ' fntmp ' does not exist.']);
  end

end

vale = struct();
fnames = fields(vale1m);
for ii=1:numel(fnames)
  vale.(fnames{ii}) = cat(1,vale1m(:).(fnames{ii}));
end

end

