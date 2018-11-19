function pos=patternfind(data,pat,param)

% param.  pc1, pc2, smooth

ppat1=smooth2(pat*(1-param.pc1),param.smooth(1),param.smooth(2));
ppat2=smooth2(pat*(1+param.pc1),param.smooth(1),param.smooth(2));
data=smooth2(data,param.smooth(1),param.smooth(2));

r=[]; pl=size(pat,1)-1;
for a=1:size(data,1)-pl;
    cpat=data(a:a+pl);
    cpat=(cpat-min(cpat))/(max(cpat)-min(cpat));
    r(end+1)=sum(cpat>ppat1 & cpat<ppat2);
end

pos=amplfind(r,[0 pl*param.pc2]);