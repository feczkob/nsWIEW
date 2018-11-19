function ev=hilb_phase(data,varargin);

% events=hilb_phase(data,phase);
% phase<2*pi

if nargin>1,
    phase=varargin{1};
else phase=0;
end;

y=data;

hy=hilbert(y);
ph=unwrap(angle(hy));
% a=1;
% ev=[];
% while a,
%     a1=find(ph>(phase+a*pi));
%     if isempty(a1),
%         break;
%     end;
%     ev(end+1,1)=min(a1);
%     a=a+2;
% end;

ph=ph+(pi-phase);
phc=fix(ph./(2*pi));
ev=find(diff(phc)>0)+1;