function ev=eventselectMovingPoint(h)

point1 = get(gca,'CurrentPoint');    % button down detected
point1 = point1(1,1:2);             % extract x and y
% p1 = min(point1)             % calculate locations

pl=findobj(h,'color','b');

xdata=get(pl,'xdata');
ydata=get(pl,'ydata');

dist=sqrt((point1(1)-xdata).^2+(point1(2)-ydata).^2);
[distval ev]=min(dist);
