function varargout=sdcalc_Callback2(h, eventdata)
% hObject    handle to sdcalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%     XXX: empty, rms, rect
% sum XXX mean_matr: local means of fragments
% sum XXX sd_matr: local SD of fragments
% sum XXX mean: global mean
% sum XXX sd: global SD
% szurt adatbol szamol

if  isfield(h, 'sd')==1
    fr=h.sd.info.fr;
    rmsms=h.sd.info.rmsms;
    filefrag=h.sd.info.filefrag;  
elseif isempty(eventdata)==1,
    prompt={'Filter frequency','RMS window size (ms)','File fragment size (sec)'};
    name='SD Calc';                         
    numlines=1;
    defaultanswer={'80 500','3','50'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    fr=str2num(answer{1});
    rmsms=str2num(answer{2});
    filefrag=str2num(answer{3});
else
    fr=eventdata.fr;
    rmsms=eventdata.rmsms;
    filefrag=eventdata.filefrag;
end

if ~isempty(fr)
    [cc aa]=butter(2,[fr(1)/h.srate*2 fr(2)/h.srate*2], 'bandpass');
else
    cc=[];
    aa=[];
end

[bb,bl,fb,fe]=fragment2(h,0,h.maxsec,h.srate,0,filefrag);

chnum=h.chnum;
%%   MEAN
disp('MEAN & SD')    
summean=zeros(length(bb),chnum);
sumdata=zeros(length(bb),chnum);
rmsmean=zeros(length(bb),chnum);
sumrms=zeros(length(bb),chnum);
rectmean=zeros(length(bb),chnum);
sumrect=zeros(length(bb),chnum);
sd2=zeros(length(bb),chnum);
rmssd2=zeros(length(bb),chnum);
rectsd2=zeros(length(bb),chnum);
vard=zeros(length(bb),chnum);
rectvar=zeros(length(bb),chnum);
rmsvar=zeros(length(bb),chnum);
% N=length(bb);
% DATA=[]; RMSDATA=[]; RECTDATA=[]; FDATA=[];
n=zeros(length(bb), 1);
for a=1:length(bb)
    if a==1
        time1=cputime;
    end
    disp([num2str(a) '/' num2str(length(bb))]);
    hand=inport(bb(a),bl(a),h);
    data=hand.data;
%     DATA=[DATA; data];
%     k(a)=size(data,1);
%     N=N+k(a);
    if fix(size(data,1))~=fix(bl(a)*h.srate),
        fprintf('Data: %d, Bl: %d \n',fix(size(data,1)),fix(bl(a)*h.srate))
    end
    n(a)=size(data,1);
    if ~isempty(fr);
        fdata=filtfilt(cc,aa,data);
    end
%     FDATA=[FDATA; fdata];
    summean(a,:)=mean(fdata);
    sumdata(a,:)=sum(fdata);
    sd2(a,:)=std(fdata);
    vard(a,:)=variance(fdata);
    
    rmsdata=rms(fdata,fix(rmsms*h.srate/1000));
%     RMSDATA=[RMSDATA; rmsdata];
    rmsmean(a,:)=mean(rmsdata);
    sumrms(a,:)=sum(rmsdata);
    rmssd2(a,:)=std(rmsdata);
    rmsvar(a,:)=variance(rmsdata);
    
    rectdata=abs(fdata);
%     RECTDATA=[RECTDATA; rectdata];
    rectmean(a,:)=mean(rectdata);
    sumrect(a,:)=sum(rectdata);
    rectsd2(a,:)=std(rectdata);
    rectvar(a,:)=variance(rectdata);
    if a==1
        time2=cputime;
        disp([ 'the sd calculation will take approx.' num2str(length(bb)*(time2-time1)) 's']);
    end
end
N=sum(n);
ni=repmat(n,1, h.chnum);
meand=sum(summean.*ni)/N;
meanrect=sum(rectmean.*ni)/N;
meanrms=sum(rmsmean.*ni)/N;
meandm=repmat(meand,length(bb),1);
meanrectm=repmat(meanrect,length(bb),1);
meanrmsm=repmat(meanrms,length(bb),1);

meandif=sum((summean-meandm).^2.*ni);
meanrectdif=sum((rectmean-meanrectm).^2.*ni);
meanrmsdif=sum((rmsmean-meanrmsm).^2.*ni);

stddata=sqrt((sum(vard)+meandif)/(N-1));
stdrect=sqrt((sum(rectvar)+meanrectdif)/(N-1));
stdrms=sqrt((sum(rmsvar)+meanrmsdif)/(N-1));

h.sd.summean=meand;
h.sd.sumrectmean=meanrect;
h.sd.sumrmsmean=meanrms;
h.sd.sumsd=stddata;
h.sd.sumrmssd=stdrms;
h.sd.sumrectsd=stdrect;
h.sd.info.fr=fr;
h.sd.info.rmsms=rmsms;
h.sd.info.filefrag=filefrag;

% figure(1)
% ch=24;
% dp=2000;
% th=5;
% plot(FDATA(1:dp,ch), 'b'), hold on
% plot(RECTDATA(1:dp,ch), 'k')
% plot(RMSDATA(1:dp,ch), 'g')
% plot(1:dp, stdrect(ch)*th, 'k-')
% plot(1:dp, stdrms(ch)*th, 'r-')
if nargout>0,
    varargout{1}=h;
else
    guidata(h.figure1,h);
end
% varargout{1}=DATA;
disp('Ready summean, RMS SD, RECT SD')