function idata=rint(data);

if size(data,1)==1,
    data=shiftdim(data);
end

idata=[];
for a=1:length(data),
    disp(a)
    idata(a,:)=sum(data(1:a,:),1);
end