function avg=avg_hist(evpos,h,ch,bs,bn,varargin);

% avg=psth(events,h,channel,binsize,[bin # before, after],[filter bellow,above])
% if ch==0 , all the channels will be involved

if ishandle(h),
    h=guidata(h);
end;

bef=bs*bn(1);
af=bs*bn(2);

if nargin>5,
    frb=varargin{2};
    fra=varargin{3};
    [b a]=butter(2,[frb/h.srate*2 fra/h.srate*2]);
    if nargin>7,
        ham=varargin{4};
    else
        ham=1;
    end;
end;

nch=length(ch);
if ch==0,
    nch=h.chnum;
end;

avg=zeros(sum(bn),nch);
n=length(evpos);
for i=1:n,
    epoch=readvalue(h,[fix(evpos(i))-bef fix(evpos(i))+af],ch);
    if exist('a'),
        epoch=filtfilt(b,a,epoch);
        epoch=epoch*ham;
    end;
    av=reshape(epoch,bs,sum(bn),nch);
    avg=avg+shiftdim(mean(av,1))./n;
end;