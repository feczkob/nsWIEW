function [pow,faxis,Y]=fourier_bas_power_hann(y,p,sr)

% Calculates FFT for matrix y
%  [fy,f,Y]=fourier_bas(y,p,sr)
%
%  fy= the FFT sequence
%  f=  the frequency vector
%  Y=  the DFT of Y (complex)
%
%  p=  the minimum point of FFT (if size(y,1)>p, p=size(y,1))
%  sr= the sampling rate
% 
% Fabó 2004


y=shiftdim(y);
y=y.*(hann(length(y))*ones(1,size(y,2)));

n=size(y,1);
if isempty(p) | n>p,
    p=n;
end;

Y = fft(y,p);

pow=(abs(Y).^2)/n;
mp=ones(size(pow,1),1)*max(pow);
pow = 10*log10(pow./mp);
pp2=fix(p/2);
pow = pow(1:pp2+1,:);
faxis=sr*[0:pp2]'/p;