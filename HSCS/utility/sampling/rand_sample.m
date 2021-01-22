function s=rand_sample(xmean,xsd,nsample,nvar)
% Generate sample with norm distribution
s=zeros(nsample,nvar);
for j=1:nvar
    s(:,j) = normrnd(xmean(j), xsd(j), [nsample,1]);
end