function vari=variance(x)
% Variancia számítása, a normalizálás nélkül
% N=length(x);
if sum(size(x)>1)==1 % vector
    meanxv=ones(size(x))*mean(x);
    vari=sum((x-meanxv).^2);
else                % matrix
    vari=zeros(1,size(x,2));
    for e=1:size(x,2)
        meanxv=ones(size(x(:,e)))*mean(x(:,e));
        vari(e)=sum((x(:,e)-meanxv).^2);
    end
end

