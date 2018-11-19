function [fy,f,Y]=fourier_bas_hann(y,p,sr)

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
y=y.*hann(length(y));

n=size(y,1);
if isempty(p) | n>p,
    p=n;
end;

Y = fft(y,p);

Pyy = Y.* conj(Y) / p;
pp2=fix(p/2);
f=sr*[0:pp2]'/p;
fy=Pyy(1:pp2+1,:);