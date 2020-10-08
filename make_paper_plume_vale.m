%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Complete sequence of eventos do produce methane plumes
% for the Marituba landfill paper.
%
% B.I. 2020.02.22

% Generate the base data file for plume calculation
% Based on 'processa_dados.m' located at '/home/imbiriba/work/research/tropico-em-movimento/lixo/pluma/plumagaussiana/pluma/'
%
% Wind comes from any tower.
% Cloud cover only from SBBE
% Precipitation from INMET and VALE
%
%startup_breno 

%addpath /home/imbiriba/work/research/tropico-em-movimento/lixo/pluma/plumagaussiana/pluma

part1=true;
part2=true;

if(part1)

  [inmet sbbe vale] = generate_data();
  inmet = stationdata_uniformfields(inmet);
  sbbe = stationdata_uniformfields(sbbe);
  vale = stationdata_uniformfields(vale);

%  if(plots)
%    make_wind_stats(inmet, sbbe, vale, 'Pretrim');
%  end

  %%%% Remove known bad data
  % Remove bad data in inmet
  tbad = [datenum(2019,07,31,18,0,0) datenum(2019,09,05,09,0,0)];
  ibad = find(inmet.mtime>=tbad(1) & inmet.mtime<=tbad(2));
  fns = fieldnames(inmet);
  for ii=1:numel(fns)
    inmet.(fns{ii})(ibad) = [];
  end

  
end
  
htype = 'sixes'; 
%htype = 'type1';

if(part2)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Separa dados em estações do ano - e períodos do dia

  % Separa as datas em ano, mes, etc....
  [year month day hour minute second] = datevec(vale.mtime);

  inverno = [12 1 2 3  4  5];
  verao   = [ 6 7 8 9 10 11];

  if(strcmp(htype,'type1'))
    iDAT{1,1} = find(hour>=21|hour< 8 & ismember(month,inverno));
    iDAT{1,2} = find(hour>= 8&hour<14 & ismember(month,inverno));
    iDAT{1,3} = find(hour>=14&hour<18 & ismember(month,inverno));
    iDAT{1,4} = find(hour>=18&hour<20 & ismember(month,inverno));

    iDAT{2,1} = find(hour>=21|hour< 8 & ismember(month,verao));
    iDAT{2,2} = find(hour>= 8&hour<14 & ismember(month,verao));
    iDAT{2,3} = find(hour>=14&hour<18 & ismember(month,verao));
    iDAT{2,4} = find(hour>=18&hour<20 & ismember(month,verao));
  elseif(strcmp(htype,'sixes'))
    iDAT{1,1} = find(hour>=0 &hour< 6 & ismember(month,inverno));
    iDAT{1,2} = find(hour>=6 &hour<12 & ismember(month,inverno));
    iDAT{1,3} = find(hour>=12&hour<18 & ismember(month,inverno));
    iDAT{1,4} = find(hour>=18&hour<24 & ismember(month,inverno));

    iDAT{2,1} = find(hour>=0 &hour< 6 & ismember(month,verao));
    iDAT{2,2} = find(hour>=6 &hour<12 & ismember(month,verao));
    iDAT{2,3} = find(hour>=12&hour<18 & ismember(month,verao));
    iDAT{2,4} = find(hour>=18&hour<24 & ismember(month,verao));
  else
    error('Wrong htype')
  end

  sest={'verao','inver'};
  sdia={'1','2','3','4'};

  for ist=1:2
    for idi=1:4
      isel = iDAT{ist,idi};

      fn=['vale_data_' htype '_' sest{ist} '_' sdia{idi} '.txt'];
      cover = 2;
      switch cover
	case 1
	  % Estimar cobertura (nebulosidade) a partir da precipitação:
	  % Se houver precipitação: 1 (100%)
	  % Se não houver precipit: 0 (0%)
	
	  cloudy = 1.0*(vale.Prec(isel)>0);
	case 2
	  % Initially fill data with the above method:
	  cloudy = 1.0*(vale.Prec(isel)>0);
	  % Then replace data with okta estimation from sbbe when present
	  [~,ii,jj] = intersect(vale.mtime(isel), sbbe.mtime);
	  cloudy(ii) = sbbe.okta(jj)/8;
      end


      % Verificar horário: se dados forem as 7am ou 5pm marcar como horário de sol baixo (sunset):
      % ERRADO:
      %      *RISE            SET*
      % |----|----|-- ... --|----|----|
      % 5    6    7        17   18   19
      sunset = hour(isel)==6 | hour(isel)==17;

      % Replace invalid radiation data with 0
      rad = vale.Rad(isel)/3.6;
      rad(isnan(rad)) = 0;







      % Datapoint Date - usefull for debuging.
      [yyyy, mm, dd, hh, ~, ~] = datevec(vale.mtime(isel));
      %
      % Checar se está certo:
      %       Direcao      Velocidade  Radiacao    Precipitacao Cobertura Sol.
      %sdata = [dc(isel,18) dc(isel,17) dc(isel,20)/3.6 dc(isel,21) cloudy sunset];
      %       Direcao           Velocidade         Radiacao  Precipitacao     Cobertura Sol.
      sdata = [vale.Wdir(isel) vale.Wspd(isel)   rad       vale.Prec(isel) cloudy    sunset vale.wdirsd(isel) yyyy mm dd hh];
      save(fn,'sdata','-ascii');
    end
  end
end


if(part3)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Run Plume model
   


end
