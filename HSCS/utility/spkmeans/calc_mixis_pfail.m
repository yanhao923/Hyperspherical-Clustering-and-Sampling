function pfail = calc_mixis_pfail(X, n0, mean0, sigma0, k, nc, cmeans, csigmas)
% Calculate failure probability for mixture IS
%% Input Parameters:
%   X: failed_samples (n*nDim), each row is a sample
%   n0: samples drew according to the original distribution
%   nc: samples drew according to each shifted distribution
%   mean0: original mean
%   sigma0: original sigma
%   k: number of clusters (failure regions)
%   nc: number of sample in each cluster (k-by-1 vector)
%   cmeans: min-norm point (centroids) of each failure region
%   csigma: sigma of each failure region
%   (n_total: total number of samples, n0+nc*k)
%% Output Parameters:
%   pfail: calculated failure probability
%% Author: Wei Wu
% Create Date: 03/16/2015
% Affliation: UCLA, Design Automation Lab. 
%% Calculation:
% pfail = 1/n*sum( I(x)*p(x)/g(x) );
% where g(x) = n0/n*p(x) + nc(1)/n*g_1(x) + nc(2)/n*g_2(x) + ... + nc(k)/n*g_k(x)
%
%% code starts from here
pfail = 0;
[nfail,nDim] = size(X);
if(k~=length(nc))
    error('wrong length of nc, or wrong k');
end
n = n0 + sum(nc);
cluster_weights = [n0;nc]./n;

%% calculate g(x) for all the failed samples
gx_mat = zeros(nfail,k);
for i=1:k
    %% calculate g_i(x) for all the failed samples
    dX = X - repmat(cmeans(i,:), nfail, 1);
    dX = dX ./ repmat(csigmas(i,:), nfail, 1);
    distance = sum(dX.^2, 2);
    gx_mat(:,i) = exp(-distance/2);
end
gx_sum = sum(gx_mat,2);

%% calculate p(x) for all the failed samples
dX = X - repmat(mean0, nfail, 1);
dX = dX ./ repmat(sigma0, nfail, 1);
distance = sum(dX.^2, 2);
px = exp(-distance/2);

gx_mat = [px, gx_mat];
gx = gx_mat*cluster_weights;

pfail_coef = px./gx;
pfail = sum(pfail_coef)/n;
end