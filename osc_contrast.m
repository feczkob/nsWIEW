function ratio_matr=osc_contrast(data,swin,lwin,srate),

% ratio_matr=osc_contrast(data,swin,lwin,srate),
%         data: RECTIFIED FILTERED data matrix              
%         swin: short window in msec
%         lwin: long window in msec
%         srate: sampling rate in Hz
% D. Fabó 2010 Boston

data=shiftdim(data);
n=size(data,1);
ch=size(data,2);
swpoint=fix(swin*srate/1000);
lwpoint=fix(lwin*srate/1000);
lwinxloc=1:lwpoint;
swinxloc=fix(lwpoint/2-swpoint/2):fix(lwpoint/2+swpoint/2);
owinxloc=lwinxloc;
owinxloc(swinxloc)=[];
winratio=swpoint*100/(lwpoint-swpoint);
      
if n<lwpoint,
    ratio_matr=[];
    return; 
end;

for a=1:ch;
    fprintf('%d',a);
    x=data(:,a);
    
    xs=zeros(length(x)-lwpoint,1);
    for i=1:lwpoint,
        n=fix((length(x)-i+1)/lwpoint);
        m=reshape(x(i:n*lwpoint+i-1),lwpoint,n);
        mshort=m(swinxloc,1:n);
        mout=m(owinxloc,1:n);
      
        ratio2=sum(mshort)./sum(mout);
        ratio2=ratio2*100-winratio;
        xs(i:lwpoint:n*lwpoint)=ratio2;
    end
    
    ratio_matr(:,a)=xs;
end;
fprintf('\n');