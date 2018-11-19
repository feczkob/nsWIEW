function [peaks varargout]=peakfind(data),

% [peaks troughs]=peakfind(data),
% data must be a vactor;
% looks for positive peaks, based on differenciation of the data

data=shiftdim(data);
if size(data,2)>1,
    disp('I don''t work on matrices');
    return;
end
datap=[data; data(end)-(data(end)-data(end-1))];
dd=diff(datap);
ddk0=find(dd<0);
ddn0=find(dd>0);
ddn0p1=ddn0+1;
ddk0m1=ddk0-1;
peaks=[];
troughs=[];

peaks=ddk0(1);
troughs=ddn0(1);

for a=2:length(ddk0)
    if ddk0(a)-ddk0(a-1)>1,
        peaks(end+1)=ddk0(a);
    end
end


for a=2:length(ddn0)
    if ddn0(a)-ddn0(a-1)>1,
        troughs(end+1)=ddn0(a);
    end
end

if nargout>1,
    varargout{1}=troughs;
end
