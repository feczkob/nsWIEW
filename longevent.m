function out=longevent(events,leng,varargin);

[m,n]=size(events);
if n==2,
    evs=[];
    for i=1:m,
        evs=[evs;[events(i,1):events(i,2)]'];
    end;
   events=evs;
elseif n>2,
    error('Wrong event format');
    return;
end;

events=sort(events);
if events(end)>leng, 
    leng=events(end); 
end;

out=zeros(leng,1);
out(events)=1;

if nargin>2,
    if strcmp(varargin{1},'asc'),
        [fn pa]=uiputfile('*.asc','Give the file name');
        poi=findstr(fn,'.');
        if ~ isempty(poi), fn=fn(1:poi(1)-1); end;
        fn=[fn '.asc'];
        f=fopen([pa fn],'w');
        fprintf(f,'%1.0f \n',out); 
        fclose(f);
    end;
end;

