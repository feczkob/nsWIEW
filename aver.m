function [avg, used]=aver(evpos,h,ch,varargin);

% avg=aver(events,h,channel,lag,'filter',[filter bellow, above],linear derive window)
% or 
% avg=aver(events,h,channel,lag,artefacts)
% Inportant: none of artefact event must match any of the events !!!!!
% lag=lag+ and lag
% if ch==0 , all the channels will be involved

if ishandle(h),
    h=guidata(h);
end;

x=100;
if nargin>3 & ~isempty(varargin{1}), 
    x=varargin{1}; 
end;

if nargin>4,
    if strcmp(varargin{2},'filter'),
        frb=varargin{3}(1);
        fra=varargin{3}(2);
        [b a]=butter(2,[frb/h.srate*2 fra/h.srate*2]);
        if nargin>6,
            ham=varargin{4};
        else
            ham=1;
        end;
    else
        evart=varargin{2};             % none of artefact event must match any of the events
        evart=reshape(evart,2,length(evart)/2);
    end;
end;

nch=length(ch);
if ch==0,
    nch=h.chnum;
end;

avg=zeros(2*x,nch);
n=length(evpos); 
if exist('evart'),
    ok=[];
    for i=1:n,
        oke=0; okb=0;
        e1=fix(evpos(i))-x; 
        e2=fix(evpos(i))+x;
        m1=[   (e1-evart(1,:))>0; ...
               (e1-evart(2,:))>0    ]*2-1;
        m2=[   (e2-evart(1,:))>0; ...
               (e2-evart(2,:))>0    ]*2-1;
        if find(sum(m1)==0), okb=0; 
        else
            okb=1;
            m=max(find(sum(m1)>0));
            if isempty(m), m=0; end;
            if m==size(evart,2), oke=1;
            elseif e2<evart(1,m+1), oke=1; 
            end
        end
    
        if oke & okb
            ok(end+1)=i;
        end;
    end
else
    ok=1:n;
end;

m=length(ok);
figure;
hold on;
for i=1:m;
    e1=fix(evpos(ok(i)))-x; 
    e2=fix(evpos(ok(i)))+x;
    disp(e1)
    epoch=readvalue(h,[e1 e2],ch);
    if exist('a'),
        epoch=filtfilt(b,a,epoch);
        epoch=epoch*ham;
    end;
    plot(epoch)
    avg=avg+epoch./m;
end
disp([num2str(m) '/' num2str(n)]) 
used=[m,n];

