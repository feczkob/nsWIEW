function [h, lengt]=vhdr_inport_menu(h,f)

headerfile=h.fname;
path=h.path;


[string]=textread([path headerfile],'%s',1,'headerlines',5);
h.fname=string{1}(10:end);
h.headerfile=headerfile;
h.file=[path h.fname];
[string]=textread([path headerfile],'%s',1,'headerlines',15);
h.databyte=str2num(string{1}(18:end))/8;
[string]=textread([path headerfile],'%s',1,'headerlines',12);
h.srate=str2num(string{1}(18:end));
h.srate=1000000/h.srate;
[string]=textread([path headerfile],'%s',1,'headerlines',10);
h.orig.chnum=str2num(string{1}(18:end));
% handles.page={[1:h.orig.chnum]};

f=fopen([path h.fname]);
fseek(f,0,1);
h.maxbyte=ftell(f);
h.minbyte=0;
h.maxsec=(h.maxbyte)/(h.orig.chnum*h.databyte*h.srate);
fclose(f);
h.inx1=0;

[N,chnames,N2,RES,UNIT,lowcutoff,highcutoff,notch]=textread([path headerfile],'%d%s%d%n%s%d%d%s',h.orig.chnum,'headerlines',34+h.orig.chnum);

for a=1:h.orig.chnum,
	h.orig.chnames{a,1}=chnames{a};
	h.orig.chnames{a,2}='REF';
    h.orig.logic_min(a)=0;
	h.orig.logic_max(a)=0;
	h.orig.logic_gnd(a)=0;
	h.orig.physic_min(a)=0;
	h.orig.physic_max(a)=RES(a);
end

if h.srate>10000,
    set(h.apl,'string',num2str(0.01));
    lengt=1;
    h.amp=0.1;
else
    lengt=10;
    if ~isfield(h,'amp'),
        h.amp=0.001;
    end;
end;

[string]=textread([path headerfile],'%s',1,'headerlines',6);
markerfile=string{1}(12:end);
[S1,EC,X,x,y]=textread([path markerfile],'%s%s%d%d%d','headerlines',12,'delimiter',',');

for a=1:length(EC),
    h.event{a,1}=X(a);
    h.event(a,2)=EC(a);
end

h.montage=[]; 
param.info='';
% TASK MENU TURN OFF without reaload
hcm=h.change_montage;
eventdata='task_montage';
try
    set(hcm,'checked','off');
catch
end
t={}; ti={}; tp={};
for i=1:size(h.task,1),
    if ~strcmp(h.task{i,2},eventdata),
        t{end+1,1}=h.task{i,1};
        t{end,2}=h.task{i,2};
        ti{end+1}=h.taskinfo{i};
        tp{end+1}=h.taskparam{i};
    end;
end;
h.task=t; h.taskinfo=ti; h.taskparam=tp;
guidata(hcm,h);

h=nswiew('task_add',h.change_montage,{'inport','task_montage'},h,param);
