function [data units] = read_uwyo_data(fn)
% function [data units] = read_uwyo_data(fn)
% Read text files from /gea/data/towers/sbbe/YYYY/UWYO_YYYY.MM.DD.txt
%
% Breno Imbiriba - 2020.07.23
%

%TEST ON FILES
%/gea/data/towers/sbbe/2019/UWYO_2019.01.01.txt
%/gea/data/towers/sbbe/2019/UWYO_2019.01.05.txt


  % Lines are:
  % First two lines (starting with **)
  % Data file dates
  % Headers 
  % If line starts with 'spaces then DD/HH' then it is units
  % Line with === signs indicate field sizes
  % Data starts with station name.

  fh = fopen(fn,'r');

  % Declare structure
  fields = {'STN','TIME','ALTM','TMP','DEW','RH','DIR','SPD','GUS','VIS','CLOUDS','CLOUDS2','CLOUDS3','Weather'};
  dtypes = {'str','double','double','double','double','double','double','double','double','double','str','str','str','str'};
  data = cell2struct(cell(1,numel(fields)), fields, 2);

  lin = fgetl(fh);

  if(numel(lin)<4 | lin(1:4)~='****')
    disp(['First line must start with ****']);
    disp([fn ' "' lin '"'])
    warning('Unexpected line');
    return
  end
  lin = fgetl(fh);
  if(lin(1:2)~='**')
    disp(['Second line must start with **']);
    disp([fn ' ' lin])
    warning('Unexpected line');
    return
  end
  % Date line
  lin = fgetl(fh);
  to=strfind(lin,'to');
  sdate = datenum(lin(1:to-1),'HHMMZ DD mmm YYYY');
  edate = datenum(lin(to+2:end),'HHMMZ DD mmm YYYY');
%  disp(['File start date: ', datestr(sdate)])
%  disp(['File end   date: ', datestr(edate)])
  % header line
  lin1 = fgetl(fh);
  % Uints
  lin2 = fgetl(fh);
  % Field size
  lin3 = fgetl(fh);

  %Find field separator places
  sp = strfind(lin3,'= =');
  sp=sp+1;
  % Add first field 'separator'
  sp = [0 sp];
  % Add last field 'terminator'
  sp = [sp numel(lin3)+1];
  % Number of data fields
  nfields = numel(sp)-1;

  % Scan for headers
  id=0;
  for ii=1:nfields
%    if(ii+1>numel(sp)) %sp(ii+1)-1>numel(lin1))
%      id = id+1;
%      headers{ii} = [headers{ii-id} num2str(id+1)];
%      continue
%    end
    ss=sp(ii)+1;
    se=min(numel(lin1),sp(ii+1)-1);
    headers{ii} = strtrim(lin1(ss:se));
    if(numel(headers{ii})==0)
      id = id+1;
      headers{ii} = [headers{ii-id} num2str(id+1)];
    else
      id=0;
    end 
  end
  
  % Units
  units = cell(1,nfields);
  for ii=1:nfields
    ss=sp(ii)+1;
    se=min(numel(lin2),sp(ii+1)-1);
    units{ii} = strtrim(lin2(ss:se));
  end

  % Compare datafile fields with expected fields
  if(numel(setdiff(headers,fields))>0)
    disp(setdiff(headers,fields))
    warning('Data contains a unknown field');
    return
  end

  ik=0;
  while(~feof(fh))
    lin = fgetl(fh);
    ik = ik+1;
    % Don't forget  spaces
    v1 = cell(1,nfields);
    for ii=1:nfields
      if(sp(ii)+1<=numel(lin))
	v1{ii} = lin(sp(ii)+1:min(end,sp(ii+1)-1));
      end
      switch headers{ii}
	case {'STN','CLOUDS','CLOUDS2','CLOUDS3','Weather'}
	  data.(headers{ii})(1,ik) = {strtrim(char(v1{ii}))};
	case 'TIME'
	  % Compute possible date
	  thisdate = edate - (ik-1)/24;
	  % Check if it is consistent
	  [yyyy, mm, dd, HH, MM, SS] = datevec(thisdate);
          txt = sprintf('%02d/%02d%02d',dd,HH,MM);
          if(~strcmp(txt,strtrim(char(v1{ii}))))
	    %disp(['Date is inconsistent:'])
	    %disp([v1{ii} ' ' txt]);
	    mtthisd = dd*24+HH+MM/60;
	    rdd = v1{ii};
	    mttxtd = str2num(rdd(1:2))*24+str2num(rdd(4:5))+str2num(rdd(6:7))/60;
	    if(abs(mtthisd-mttxtd)<6)
	     % disp('They seem to be appart for a few hours. Keeping what''s on the data');
              if(dd==str2num(rdd(1:2)))
		thisdate = datenum(yyyy,mm,dd,str2num(rdd(4:5)),str2num(rdd(6:7)),00);
	      elseif(str2num(rdd(1:2))<dd)
		% Day before
		thisdate = datenum(yyyy,mm,str2num(rdd(1:2)),str2num(rdd(4:5)),str2num(rdd(6:7)),00);
	      elseif(mm>1)
		% Reduce month!
		thisdate = datenum(yyyy,mm-1,str2num(rdd(1:2)),str2num(rdd(4:5)),str2num(rdd(6:7)),00);
	      else
		% Reduce year
		thisdate = datenum(yyyy-1,12,str2num(rdd(1:2)),str2num(rdd(4:5)),str2num(rdd(6:7)),00);
	      end
	    else
	      disp(['Date is inconsistent:'])
	      disp([v1{ii} ' ' txt]);
	      warning('Inconsistent dates');
	      return
	    end
	    %disp(['Using: ' datestr(thisdate)]);
	  end
	  data.(headers{ii})(1,ik) = thisdate;
        otherwise
	  xx = str2num(v1{ii});
	  if(numel(xx)==0)
	    xx=NaN;
	  end
	  data.(headers{ii})(1,ik) = xx;
      end
    end
  end

  % Final check
  % All fields must have the same number of column
  nn=0;
  for ii=1:numel(fields)
    nl = size(data.(fields{ii}),2);
    nn = max(nn, nl);
    if(nn>nl)
      if(nl==0)
	if(strcmp(dtypes{ii},'str'))
	  data.(fields{ii}) = cell(1,nn);
	else
	  data.(fields{ii}) = NaN(1,nn);
	end
      else
	warning('Inconsistent field sizes!!')
      end
    end
  end

  units = [headers; units];
  fclose(fh);


end
