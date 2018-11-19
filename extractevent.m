function ev=extractevent(h,varargin)

if ishandle(h),
    h=guidata(h);
end

if nargin>1,
    ch=varargin{1};
else
    ch='all';
end;

ev=[];
if isnumeric(ch),
    for a=1:size(h.event,1),
        c=sscanf(h.event{a,2},'%f');
        if any(c==ch),
            ev(end+1,1)=h.event{a,1};
        end
    end
elseif strcmp(ch,'all')
    for a=1:size(h.event,1),
        ev(end+1,1)=h.event{a,1};
    end
else
    for a=1:size(h.event,1),
        if strcmp(h.event{a,2},ch),
            ev(end+1,1)=h.event{a,1};
        end
    end
end