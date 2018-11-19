function ev=eventselect_sub(h,xdata,ydata,p1,offset);

mx=find(xdata>p1(1) & xdata<p1(1)+offset(1));
ev=find(ydata(mx)>p1(2) & ydata(mx)<p1(2)+offset(2));
ev=shiftdim(mx(ev));