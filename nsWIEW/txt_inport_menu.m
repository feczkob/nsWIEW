function [handles, lengt]=txt_inport_menu(handles,f)


prompt  = {'Databyte','Sampling rate (Hz)','Number of channels','Begin of data in byte'};
titl   = 'Give the parameters';
lines= 1;
%          ch  frb fra   NF   
def     = {'2','5000','16','0'};
a  = inputdlg(prompt,titl,lines,def);


handles.databyte=str2num(a{1});    
handles.srate=str2num(a{2});
handles.chnum=str2num(a{3});
handles.page={[1:handles.chnum]};
if handles.srate>10000,
    set(handles.apl,'string',num2str(0.01));
    lengt=1;
    handles.amp=0.1;
else
    lengt=10;
    if ~isfield(handles,'amp'),
        handles.amp=0.001;
    end;
end;

fseek(f,0,1);
handles.maxbyte=ftell(f);

handles.minbyte=str2num(a{4});
fseek(f,0,-1);
handles.header=fread(f,handles.minbyte,'int8');
    
handles.inx1=0;
handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.chnum*handles.databyte*handles.srate);
    
objs=findobj(handles.figure1,'type','uimenu');
set(objs,'enable','on');