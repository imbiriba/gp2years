function varargout=dateloop(varargin)
%
% Usage:
%
% lp=dateloop(); % Get an available loop entry
% dateloop('start',lp); % reset loop `lp'
% while(dateloop(start,step,end,lp)) % iterate loop `lp'. Dates are vector dates
%   date=dateloop('date',lp); % return the current date (as a vector)
%   sdate=dateloop('sdate',lp); % return a date string
% end

persistent loopdate

if(nargin==0) % Setup
  if(nargout~=1)
    error('Setup command must have an output argument');
  else
    loopdate(end+1)=0;
    varargout{1}=numel(loopdate);
    return
  end
elseif(nargin==2)
  if(strcmp(varargin{1},'start'))
    loopdate(varargin{2})=0;
    return
  end
  if(strcmp(varargin{1},'date'))
    varargout{1}=datevec(loopdate(varargin{2}));
    return
  end
  if(strcmp(varargin{1},'sdate'))
    dvec = datevec(loopdate(varargin{2}));
    for ii=1:nargout()
      dfmt='%02d';
      if(ii==1) 
	dfmt='%04d';
      end
      varargout{ii}=num2str(dvec(ii),dfmt);
    end
    return
  end
  error('Command must be start or date');
elseif(nargin==4)
  % the main loop
  [start,step,stop,lp]=deal(varargin{:});
  if(loopdate(lp)==0)
    loopdate(lp)=datenum(start);
    varargout{1}=true;
  elseif(loopdate(lp)>datenum(stop))
    varargout{1}=false;
  else
    dv1=datevec(loopdate(lp));
    dv2=dv1;
    dv2(1:numel(step))=dv2(1:numel(step))+step;
    loopdate(lp)=datenum(dv2);
    varargout{1}=true;
    if(loopdate(lp)>datenum(stop))
      varargout{1}=false;
    end  
  end
else
  error('Wrong number of arguments');
end

