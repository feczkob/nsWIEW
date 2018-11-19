function [fid varargout]=cnt_header_ns_on_page(hObject, eventdata, handles, pagenum)

% filename: name of .cnt file to write to
% data: data to write in the structure of [channels,points]
% srate: sampling rate

[fn pa]=uiputfile('*.cnt','Give the file name');
poi=findstr(fn,'.');
if ~isempty(poi), fn=fn(1:poi(1)-1); end;
fn=[fn '.cnt'];

fid = fopen(fn,'w'); 
fwrite(fid,handles.blank,'int8');
fclose(fid);

fid = fopen(fn,'r+'); 

%%%%%%% HEADER %%%%%%%%%%%%%
if isfield(handles, 'fileDate')==1
    fseek(fid,255,'bof');
    fwrite(fid, [num2str(handles.fileDate(1)-2000)  num2str('/') sprintf('%02d', handles.fileDate(2) )  num2str('/') sprintf('%02d', handles.fileDate(3) ) ],'uint8'); % file date
end
if isfield(handles, 'fileTime')==1
    fseek(fid,235, 'bof');
    fwrite(fid, [num2str(handles.fileTime(1))  num2str(':') sprintf('%02d', handles.fileTime(2) )  num2str(':') sprintf('%02d', handles.fileTime(3) ) ],'uint8'); % file date
end
fseek(fid,370,'bof');
fwrite(fid,length(handles.page{pagenum}),'ushort');  % number of channels !!!!! 2015.03.04 fwrite(fid,handles.chnum,'ushort');
fseek(fid,376,'bof');
fwrite(fid,handles.srate,'ushort');         % sampling rate
%fseek(fid,804,'bof');
%fwrite(fid,5,'char');                % ? fratio vagy minor_rev (VAGY FLOAT)
fseek(fid,864,'bof');
nsamples=(handles.maxbyte-handles.minbyte)/(length(handles.page{pagenum})*handles.srate);
fwrite(fid,nsamples,'long');                % number of samples  size(data,2)

     % data length info

begin=0;
begin_point=0;
lengt=handles.maxsec;
lengt_point=lengt*handles.srate;

for a=1:size(handles.event,1)
    if strcmp(upper(handles.event{a,2}),'START'),
        begin_point=handles.event{a,1};
        begin=begin_point/handles.srate;
    end
    if strcmp(upper(handles.event{a,2}),'END'),
        lengt_point=handles.event{a,1}-begin_point;
        lengt=lengt_point/handles.srate;
    end
end

fseek(fid,886,'bof');           % eventtable position
minbyte=900+75*length(handles.page{pagenum});
evtpos=(lengt_point*2*length(handles.page{pagenum}))+minbyte;
fwrite(fid,evtpos,'long');    

    % channel info
fseek(fid,900,'bof');

for n = 1: length(handles.page{pagenum}),
    % TRC 
    if isfield(handles,'c2'),
        if strcmpi(handles.c2{handles.page{pagenum}(n)},'C2') || strcmpi(handles.c2{handles.page{pagenum}(n)},'AVG') || strcmpi(handles.c2{handles.page{pagenum}(n)},'REF'),
            str=handles.c1{handles.page{pagenum}(n)};
        else
            str=[handles.c1{handles.page{pagenum}(n)},'-',handles.c2{handles.page{pagenum}(n)}];
        end
        if length(str)>10,
            str=str(1:10);
        end
        sp=' ';
        strh=length(str);    
        str=[str sp(ones(1,10-strh))];
    elseif isempty(handles.chnames)==0
        str=handles.chnames{handles.page{pagenum}(n)}; 
        strh=length(str); 
        sp=' ';
        str=[str sp(ones(1,10-strh))];
    else
        str=num2str(handles.page{pagenum}(n)); 
        strh=length(str); 
        sp=' ';
        str=[str sp(ones(1,10-strh))];
    end
    fwrite(fid,str,'char');
   %% CNT
%     if ~isfield(handles,'chnames'),
%         fwrite(fid,num2ascii(handles.page{pagenum}(n)),'char');
%     elseif isempty(handles.chnames),
%         fwrite(fid,num2ascii(handles.page{pagenum}(n)),'char');
% %     elseif handles.alapmontage==1,
% %         fwrite(fid,handles.c1{n},'char');
%     else
%         fwrite(fid, handles.chnames{handles.page{pagenum}(n)},'char'); % fwrite(fid,handles.chnames{n},'char');
%     end
    %%
    fwrite(fid,255,'char');    %255
    fwrite(fid,0,'char');
    fwrite(fid,0,'char');
    fwrite(fid,1,'char');
    fwrite(fid,0,'char');
    fwrite(fid,1,'ushort');
    fwrite(fid,0,'char');
    fwrite(fid,0,'char');
    if rem(n,10)~=0
        fwrite(fid,rem(n,10)*50,'float');
    else
        fwrite(fid,500,'float');
    end
    if rem(n,10)~=0
        fwrite(fid,(floor(n/10)+1)*15,'float');
    else
        fwrite(fid,(floor(n/10))*15,'float');
    end
    fwrite(fid,0,'float');
    fwrite(fid,0,'float');
    fwrite(fid,0,'float');
    fwrite(fid,0,'float');
    fwrite(fid,0,'float');
    fwrite(fid,0,'short');
    fwrite(fid,0,'char');
    fwrite(fid,0,'char');
    fwrite(fid,0,'float');
    fwrite(fid,0,'float');
    fwrite(fid,1,'float');
    fwrite(fid,0,'char');
    fwrite(fid,3,'char');
    fwrite(fid,7,'char');
    fwrite(fid,0,'uchar');
    fwrite(fid,0,'uchar');
    fwrite(fid,0,'uchar');
    fwrite(fid,n-1,'uchar');
    fwrite(fid,0,'char');
    fwrite(fid,1,'float');
end

disp('header ok')

if nargout>1
    varargout{1}=pa;
    varargout{2}=fn;
end