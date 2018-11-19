function evo=exclude_dist(event,mindist,data,mima),

% event_out=exclude_dist(event_in,minimum distance,mima),
%
% mima is 'min' if the peaks are minimums in the data
% mima is 'max' if the peaks are maximums in the data

if iscell(event),
    for i=1:size(event,1),
        evs(i,1)=event{i,1};
    end
    event=evs;
end
event=shiftdim(event);

evo=event(1,1);
for i=2:size(event,1),
    if event(i,1)-event(i-1,1)<mindist,
        e=event(i-1:i,1);
        [ert eh]=feval(mima,data(e));
        evo(end,1)=e(eh);
    else 
        evo(end+1,1)=event(i,1);
    end;
end;