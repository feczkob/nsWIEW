function varargout=ev2writer(h,varargin)

n=size(h.event,1);
if n==0, return; end;

ecs={}; list='';
for i=1:n,
    if ~any(strcmp(ecs,h.event{i,2})), 
        ecs(end+1)=h.event(i,2); 
        list=[list, ', ', ecs{end}];
    end;
end;
list=list(3:end);

if nargin>1,
    ec=varargin{1};
else
    answer=inputdlg(['Which symbol to save?' list],'Give the parameter',1,{'all'});
    if strcmp('all',answer{1}),
        ec=ecs;
    else
        ec=wordsc(answer{1});
    end;
end;

c6=[]; c2=[];
for i=1:n,
    if any(strcmp(h.event{i,2},ec)),
        c6(end+1)=fix(h.event{i,1});
        chc=sscanf(h.event{i,2},'%f');
        disp([num2str(i) ,': ', num2str(chc)])
        if ~isempty(chc),
            c2(end+1)=chc;
        elseif strcmp(h.event{i,2},'a'),
            c2(end+1)=100;
        else
            c2(end+1)=1;
        end;
    end;
end;
c1=1:size(c6,2);
c3=zeros(1,length(c1));
c4=zeros(1,length(c1));
c5=zeros(1,length(c1));
[fn pa]=uiputfile('*.ev2','Give the file name');
poi=findstr(fn,'.');
if ~isempty(poi), fn=fn(1:poi(1)-1); end;
fn=[fn '.ev2'];

f=fopen([pa fn],'w');
ok=fprintf(f,'%5d %4d %3d %4d %7.4f %8d\n',[c1; c2; c3; c4; c5; c6]);
fclose(f);
if nargout==1, varargout{1}=ok; end;