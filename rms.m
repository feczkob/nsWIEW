function data=rms(x,point);

data=shiftdim(x);

n=size(data,1);
ch=size(data,2);

if n<point+2, return; end;

for a=1:ch;
    x=data(:,a);
    half=fix(point/2);
    
    
        xs=zeros(length(x)-2*half,1);
        for i=1:point,
            n=fix((length(x)-i+1)/point);
            m=reshape(x(i:n*point+i-1),point,n);
            m=m.^2;
            xs(i:point:n*point)=sqrt(mean(m));
        end
    
        el=sqrt(mean(x(1:half).^2));
        veg=sqrt(mean(x(end-half:end).^2)); 
        if mod(point,2)==0,
            xs=[el(ones(half-1,1)); xs; veg(ones(half,1))];
        else
            xs=[el(ones(half,1)); xs; veg(ones(half,1))];
        end;   
    
    data(:,a)=xs;
end;
% figure
% hold on;
% plot(data)

