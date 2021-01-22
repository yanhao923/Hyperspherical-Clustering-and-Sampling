function s=sobol_qmc(xmean,xsd,nsample,nvar)

% Quasi Monte-Carlo with sobol sequence
ran = sobolset(nvar, 'skip', nsample);
sobol = net(ran,nsample);
s=zeros(nsample,nvar);
for a=1:nvar
    s(:,a)=norminv(sobol(:,a),xmean(a),xsd(a));
end

