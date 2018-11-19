function varargout=distfind(x,varargin),

% Finds extreme paeks in a time series based on the probability distribution.
% Syntax:
%       [maxs mins]=distfind(x,P,binnum),
% Where: 
%   x is the time series 
%   P is the probability limit (default is 0.05)
%   binnum is the bin number used in histogram (default is 30)
%   mins are the minimum and 
%   max are the maximum extreme peaks.
%
%   Dániel Fabó 2003 Budapest

if nargin>1, P=varargin{1}; end;
if nargin>2  binum=varargin{2}; end;
if nargin<3, binum=30; end;
if nargin<2, P=0.05; end;
if nargin<1, error('You must give a time series!'); end;

if P<0 | P>1, error('P must be between 0 and 1'); end;
if P<0.5,
    upP=1-P;
    lowP=P;
else 
    upP=P;
    lowP=1-P;
end;

[his xout]=hist(x,binum);
hisc=0;
for i=1:binum;
    hisc(i+1)=hisc(i)+his(i);
end;
hisc(1)=[];
hisc=hisc./max(hisc);

mins=max(find(hisc<=lowP));
maxs=max(find(hisc<upP))+1;

minlim=xout(mins);
maxlim=xout(maxs);

maxs=find(x>=maxlim);
mins=find(x<=minlim);

dif=diff(mins);
difn1=find(dif>1);
difn1=[0; difn1];
d=zeros(length(difn1)-1,1);
for j=1:length(difn1)-1
    [maxe,maxh]=min(x(mins(difn1(j)+1:difn1(j+1))));
    d(j)=mins(difn1(j)+maxh);
end;
mins=d;

dif=diff(maxs);
difn1=find(dif>1);
difn1=[0; difn1];
d=zeros(length(difn1)-1,1);
for j=1:length(difn1)-1,
    [maxe,maxh]=max(x(maxs(difn1(j)+1:difn1(j+1))));
    d(j)=maxs(difn1(j)+maxh);
end;
maxs=d;

if nargout>0, varargout{1}=maxs; end;
if nargout>1, varargout{2}=mins; end;






