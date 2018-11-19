function [hisc,xout]=histcum(x,binum,norm),

if nargin==1,
    binum=30;
end;

[his xout]=hist(x,binum);
hisc=0;
for i=1:binum;
    hisc(i+1)=hisc(i)+his(i);
end;
hisc(1)=[];
if nargin>2,    
    hisc=hisc./max(hisc);
end;