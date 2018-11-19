function varargout=amplfind(x,varargin),

% Finds extreme paeks, and intervals in a time series based on amplitude criteria.
% Syntax:
%       [maxs mins maxints minints]=amplfind(x,lim),
% Where: 
%   x is the time series 
%   lim=[limit min, limit maximum] (default is 3/4 of the range)
%   mins are the minimum
%   maxs are the maximum extreme peaks.
%   maxints  are the begining and ending of upper events
%   minints  are the begining and ending of lower events
%
%   Dániel Fabó 2006 Budapest

if nargin<1, errordlg('You must give a time series!'); end;

x=shiftdim(x);
if nargin>1, 
    minlim=varargin{1}(1); 
    maxlim=varargin{1}(2);     
end;
if nargin<2, 
    range=max(x)-min(x);
    minlim=1/4*range+min(x);
    maxlim=3/4*range+min(x);
end;

maxs=find(x>=maxlim);
mins=find(x<=minlim); 

fmins=[]; minint=[];
fmaxs=[]; maxint=[];

if ~isempty(mins),
    dif=diff(mins); 
    difn1=find(dif>1);
    difn1=[0; difn1; length(mins)];
    fmins=zeros(length(difn1)-1,1);
    for j=1:length(difn1)-1, 
        [maxe,maxh]=min(x(mins(difn1(j)+1:difn1(j+1))));
        fmins(j)=mins(difn1(j)+maxh);
    end;
    minint=zeros(length(fmins),2);
    minint(:,1)=mins(difn1(1:end-1)+1);
    minint(:,2)=mins(difn1(2:end));
end

if ~isempty(maxs),
    dif=diff(maxs);
    difn1=find(dif>1);
    difn1=[0; difn1; length(maxs)];
    fmaxs=zeros(length(difn1)-1,1);
    for j=1:length(difn1)-1,
        [maxe,maxh]=max(x(maxs(difn1(j)+1:difn1(j+1))));
        fmaxs(j)=maxs(difn1(j)+maxh);
    end;
    maxint=zeros(length(fmaxs),2);
    maxint(:,1)=maxs(difn1(1:end-1)+1);
    maxint(:,2)=maxs(difn1(2:end));    
end

if nargout>0, varargout{1}=fmaxs; end;
if nargout>1, varargout{2}=fmins; end;
if nargout>2, varargout{3}=maxint; end;
if nargout>3, varargout{4}=minint; end;