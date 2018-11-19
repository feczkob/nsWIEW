function data=spline_resample(h,ch,s1,s2,fp),

% Syntax:
% sdata=spline_resample(h,ch,s1,s2,fp),
% where
%   h: guidata from nswiew, 
%   ch: the interrested channels, if '0' then does every channels
%   s1: the first sample point, 
%   s2: the second sample point,
%   fp: the final point number.

%%%%%%%%%%%%%% SETTING UP THE FILE

type=['.nhd'];
[fn,path] = uiputfile(['*' type],'Give the file name');
poi=findstr(fn,'.');
if ~isempty(poi), fn=fn(1:poi(1)-1); end;
fn=[fn type];

%%%%%%%%%%%%%% Process

if ishandle(h),
    h=guidata(h);
end

if s2<s1, s=s1; s1=s2; s2=s; end;
if ch==0, ch=1:h.chnum; end;

data=[];
for a=1:length(ch),
    indi(num2str(ch));
    d=readchannel(h,[s1,s2],ch(a));
    t=[s1:s2-1]-s1;
    tt=[0:fp-1]/(fp-1)*(s2-s1-1);
    dd=spline(t,d,tt)';
    data=[data,dd];
end
indi('del')

%%%%%%%%%%%%%% Save

fw=fopen([path fn],'w');
fwrite(fw,data','int16');
fclose(fw);