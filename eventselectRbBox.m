function ev=eventselectRbBox(h),

point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
if offset==0, ev=[]; return; end;
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

pl=findobj(h,'color','b');
xdata=get(pl,'xdata');
ydata=get(pl,'ydata');
mx=find(xdata>p1(1) & xdata<p1(1)+offset(1));
ev=find(ydata(mx)>p1(2) & ydata(mx)<p1(2)+offset(2));
ev=shiftdim(mx(ev));
keep=findobj(h,'string','KEEP');
exc=findobj(h,'string','EXCLUDE');
if get(keep,'value'),
    he=guidata(h);
    ev=[ev;he];
    ev=sort(ev);
    evf=ev(1);
    for a=2:length(ev),
        if ev(a)~=ev(a-1);
            evf(end+1,1)=ev(a);
        end
    end
    ev=evf;
elseif get(exc,'value'),
    he=guidata(h);
    evf=[];
    for a=1:length(he),
        if ~any(he(a)==ev);
            evf(end+1,1)=he(a);
        end
    end
    ev=evf;
end
    
os=findobj(0,'name','discplot');
for a=1:length(os),
    guidata(os(a),ev);
end
    

for a=1:length(os),
    set(0,'currentfigure',os(a));
    pl=findobj(os(a),'color','b');
    xdata=get(pl,'xdata');
    ydata=get(pl,'ydata');
    xlab=get(get(gca,'xlabel'),'string');
    ylab=get(get(gca,'ylabel'),'string');
    mg=findobj(gcf,'userdata','margin');
    if ~isempty(mg),
        xm1=get(mg(1),'Xdata'); xm2=get(mg(2),'Xdata');
        ym1=get(mg(1),'Ydata'); ym2=get(mg(2),'Ydata');
    else
        xm1=[];
    end
    hold off;
    plot(xdata,ydata,'.');
    xlabel(xlab); ylabel(ylab);
    hold on
    if ~isempty(xm1),
        plot(xm1,ym1,'.m','userdata','margin');
        plot(xm2,ym2,'.m','userdata','margin');
    end;
    plot(xdata(ev),ydata(ev),'.r');
    if os(a)==h,
        plot(x,y,'r');
    end
    ui=findobj(os(a),'string','CLUSTER');
    if length(ev)<2000,
        set(ui,'enable','on');
    else
        set(ui,'enable','off');
    end;
end;