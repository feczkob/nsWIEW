function [evs,evcell,fname]=ev2read(h,m, varargin)
if isempty(varargin)==1
    [fname, path]=uigetfile({'*.ev2', 'EV2 file; *.ev2'}, 'Select the event file');
else
    fname=varargin{1,1}{2};
    path=varargin{1,1}{1};
end

try 
    cd(path);
catch
    disp('Probléma az ev2read-ban a path beolvasásában')
    evs=[];
    evcell={};
    return;
end

if nargin<2,
    m=1;
end;
disp(fname)
events=load([path fname]);
evs=fix(events(:,6).*m); 
evcell={[],''};

for i=1:size(events,1);
    evcell(end+1,1)={evs(i)};
    evcell(end,2)={num2str(events(i,2))};
    if strcmp(evcell{end,2},'100'),
        evcell{end,2}='a';
    end
end;
evcell(1,:)=[];

if nargin>0,
    if ishandle(h),
        h=guidata(h);
    end;
    h.evfilename=fname;
    if isfield(h,'event'),
        evori=h.event; 
        h.event=[evori;evcell];
    else
        h.event=evcell;
    end
   
    ha=nswiew('draw',h.data,h);
    guidata(h.figure1,ha);
end;

