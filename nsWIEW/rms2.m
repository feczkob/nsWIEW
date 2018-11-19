function data=rms2(x, winsize, srate) 

rmswinsizesp=winsize*srate/1000;

rms=zeros(1,length(x));
kozep=floor(rmswinsizesp/2);
for i=1:length(x)-rmswinsizesp
  vektor=x(i:i+rmswinsizesp);
  rms(i+kozep)=mean(vektor.^2);
end
rms=sqrt(rms);
figure
plot(rms)
clear x;