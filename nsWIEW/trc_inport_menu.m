function [handles, lengt]=trc_inport_menu(handles,f)

fseek(f,175,-1);            % headertype
d=fread(f,1,'int8'); handles.trcty=d;
switch d,
    case 1,
        fseek(f,182,-1);
        handles.minbyte=fread(f,1,'int16');
        handles.orig.chnum=fread(f,1,'int16');
        handles.page={[1:handles.orig.chnum]};
        fseek(f,8,-1);
        handles.srate=fread(f,1,'int16');
        handles.databyte=1;
        fseek(f,0,1);
        handles.maxbyte=ftell(f);
        handles.inx1=0;
        handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.orig.chnum*handles.databyte*handles.srate);
        fseek(f,0,-1);
        handles.header=fread(f,handles.minbyte,'int8');
        fseek(f,12,-1);
        handles.mcs_factor=fread(f,1,'int16');
        fseek(f,5056,-1);
        for a=1:handles.orig.chnum,
            p=fread(f,5,'uint8'); 
            zs=find(p==0); p(zs)=32;
            cp=char(p');
            handles.orig.chnames{a,1}=cp;
            handles.orig.chnames{a,2}='G2';
            fread(f,1,'int8');
            d=fread(f,1,'int16');
            handles.orig.unit(a)=fix(d/2^14);
            handles.orig.mcs(a)=mod(d,2^14);
        end
    case {4}
        fseek(f, 128, -1);
        filedate=fread(f,3,'uint8');
        handles.fileDate=[filedate(3)+1900 filedate(2) filedate(1)]; % datum megadasa: ev, honap, nap by Toth Emilia 2015.02.04
        filetime=fread(f,3, 'uint8');
        handles.fileTime=[filetime(1) filetime(2) filetime(3)];  % pontos ido megadasa: ora perc masodperc by Toth Emilia 2015.02.04
        fseek(f,138,-1);
        handles.minbyte=fread(f,1,'int32');
        handles.orig.chnum=fread(f,1,'int16');
        handles.page={[1:handles.orig.chnum]};
        handles.multiplexer=fread(f,1,'int16'); 
        handles.srate=fread(f,1,'int16');
        handles.databyte=fread(f,1,'int16');
        if handles.databyte*handles.orig.chnum~=handles.multiplexer,
            msgbox('Multiplexer error');
        end
        fseek(f,0,1);
        handles.maxbyte=ftell(f);
        handles.inx1=0;
        handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.orig.chnum*handles.databyte*handles.srate);
        fseek(f,0,-1);
        handles.header=fread(f,handles.minbyte,'int8');
        fseek(f,184,-1);
        ordpoi=fread(f,1,'int32');
        fseek(f,200,-1);
        elpoi=fread(f,1,'int32');
        fseek(f,ordpoi,-1);
        order=fread(f,handles.orig.chnum,'int16');
        for a=1:handles.orig.chnum,
            fseek(f,elpoi+2+order(a)*128,-1);
            p=fread(f,6,'int8'); 
            zs=find(p==0); p(zs)=32;
            cp=char(p');
            handles.orig.chnames{a,1}=cp;
            p=fread(f,6,'int8'); 
            zs=find(p==0); p(zs)=32;
            cp=char(p');
            handles.orig.chnames{a,2}=cp;
            handles.orig.logic_min(a)=fread(f,1,'uint32');
            handles.orig.logic_max(a)=fread(f,1,'uint32');
            handles.orig.logic_gnd(a)=fread(f,1,'uint32');
            handles.orig.physic_min(a)=fread(f,1,'int32');
            handles.orig.physic_max(a)=fread(f,1,'int32');
            handles.orig.unit(a)=fread(f,1,'uint16');
            handles.orig.pref_hp(a)=fread(f,1,'uint16');
            handles.orig.pref_hpty(a)=fread(f,1,'uint16');
            handles.orig.pref_lp(a)=fread(f,1,'uint16');
            handles.orig.pref_lpty(a)=fread(f,1,'uint16');
            handles.orig.freq_coef(a)=fread(f,1,'uint16');
        end
    case {2,3}
        fseek(f, 128, -1);
        filedate=fread(f,3,'uint8');
        handles.fileDate=[filedate(3)+1900 filedate(2) filedate(1)]; % datum megadasa: ev, honap, nap by Toth Emilia 2015.02.04
        filetime=fread(f,3, 'uint8');
        handles.fileTime=[filetime(1) filetime(2) filetime(3)];  % pontos ido megadasa: ora perc masodperc by Toth Emilia 2015.02.04
        fseek(f,138,-1);
        handles.minbyte=fread(f,1,'int32');
        handles.orig.chnum=fread(f,1,'int16');
        handles.page={[1:handles.orig.chnum]};
        handles.multiplexer=fread(f,1,'int16'); 
        handles.srate=fread(f,1,'int16');
        handles.databyte=fread(f,1,'int16');
        if handles.databyte*handles.orig.chnum~=handles.multiplexer,
            msgbox('Multiplexer error');
        end
        fseek(f,0,1);
        handles.maxbyte=ftell(f);
        handles.inx1=0;
        handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.orig.chnum*handles.databyte*handles.srate);
        fseek(f,0,-1);
        handles.header=fread(f,handles.minbyte,'int8');
        fseek(f,184,-1);
        ordpoi=fread(f,1,'int32');
        fseek(f,200,-1);
        elpoi=fread(f,1,'int32');
        fseek(f,ordpoi,-1);
        order=fread(f,handles.orig.chnum,'int8');
        for a=1:handles.orig.chnum,
            fseek(f,elpoi+2+order(a)*128,-1);
            p=fread(f,6,'int8'); 
            zs=find(p==0); p(zs)=32;
            cp=char(p');
            handles.orig.chnames{a,1}=cp;
            p=fread(f,6,'int8'); 
            zs=find(p==0); p(zs)=32;
            cp=char(p');
            handles.orig.chnames{a,2}=cp;
            handles.orig.logic_min(a)=fread(f,1,'uint16');
            handles.orig.logic_max(a)=fread(f,1,'uint16');
            handles.orig.logic_gnd(a)=fread(f,1,'uint16');
            handles.orig.physic_min(a)=fread(f,1,'int32');
            handles.orig.physic_max(a)=fread(f,1,'int32');
            handles.orig.unit(a)=fread(f,1,'uint16');
            handles.orig.pref_hp(a)=fread(f,1,'uint16');
            handles.orig.pref_hpty(a)=fread(f,1,'uint16');
            handles.orig.pref_lp(a)=fread(f,1,'uint16');
            handles.orig.pref_lpty(a)=fread(f,1,'uint16');
            handles.orig.freq_coef(a)=fread(f,1,'uint16');
        end
    case 0,
        disp('Type 0 header not implemented yet'); return;
    end;
    
point=1; a=0;
if handles.trcty==4
    while point && a<235,
        fseek(f,83072+a*44,-1); %33708 trc type 3 % 83072 trc type 4
        point=fread(f,1,'int32');
        if point,
            desc=fread(f,40,'char');
            desc=char(desc');
            x=fix(point);
            ec=desc;
            if isempty(handles.event),
                handles.event={x,ec};
            else
                handles.event(end+1,1:2)={x,ec};
            end;       
        end
        a=a+1;
    end
else
    while point && a<235,
    fseek(f,33708+a*44,-1); %33708 trc type 3 % 83072 trc type 4
    point=fread(f,1,'int32');
    if point,
        desc=fread(f,40,'char');
        desc=char(desc');
        x=fix(point);
        ec=desc;
        if isempty(handles.event),
            handles.event={x,ec};
        else
            handles.event(end+1,1:2)={x,ec};
        end;       
    end
    a=a+1;
    end
end

guidata(handles.figure1,handles);

handles.inx1=0;
    
if handles.srate>10000,
    set(handles.apl,'string',num2str(0.01));
    lengt=1;
    handles.amp=0.1;
else
    lengt=10;
    if ~isfield(handles,'amp'),
    handles.amp=0.01;
    end;
end; 

handles.montage=[]; 
param.info='';

% TASK MENU TURN OFF without reaload
h=handles.change_montage;
eventdata='task_montage';
try
    set(h,'checked','off');
catch
end
t={}; ti={}; tp={};
for i=1:size(handles.task,1),
    if ~strcmp(handles.task{i,2},eventdata),
        t{end+1,1}=handles.task{i,1};
        t{end,2}=handles.task{i,2};
        ti{end+1}=handles.taskinfo{i};
        tp{end+1}=handles.taskparam{i};
    end;
end;
handles.task=t; handles.taskinfo=ti; handles.taskparam=tp;
guidata(h,handles);

handles=nswiew('task_add',handles.change_montage,{'inport','task_montage'},handles,param);




    


