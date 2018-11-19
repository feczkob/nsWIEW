function val=readvalue(h,points,ch)

% h:  .file; .minbyte; .databyte; .chnum
if ishandle(h),
    h=guidata(h);
end

evpos=points(1); lengt=h.chnum; ae=1;
if length(points)==2,
    lengt=(points(2)-evpos)*h.chnum;
elseif length(points)>2,
    ae=length(points);
    evpos=points;
end;

file=fopen(h.file);
minb=h.minbyte;
db=h.databyte;
dataf=[];
for a=1:ae,
    fseek(file,minb+evpos(a)*db*h.chnum,'bof');
    data=fread(file,lengt,'int16');
    n=size(data,1);
    nchn=fix(n/h.chnum);
    data(nchn*h.chnum+1:end)=[];
    data=reshape(data,h.chnum,nchn)';
    dataf=[dataf;data];
end;

if ch==0,
    val=dataf;
else
    val=dataf(:,ch);
end;
fclose(file);