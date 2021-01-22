%% clear
clear;
clc;
%% Analysis configurations
analysis.circuitName = 'sram6Tcell'% the same name as "xxx.sp" file in "./circuit" file folder;
analysis.path = pwd;
analysis.hspicepath = '/usr/eda/synopsys/hspice_K201506-3/hspice/bin/hspice'; % the install path of HSPICE software.
analysis.circuitPath = ['./circuits/', analysis.circuitName];% circuit net list file with ".sp" as suffix
addpath(analysis.circuitPath);
addpath([pwd, '/HspiceToolbox']);
addpath([pwd, '/utility']);
addpath([pwd, '/utility/spkmeans']);
[analysis.model.mean, analysis.model.sigma] = getMeanSigma(analysis);%analysis.model.mean,analysis.model.sigma�ѱ���ֵ

analysis.nominal_run = 0;
analysis.step0_dim_reduction_run =1;
analysis.step1_spherical_sample_run = 1;
analysis.step2_spkmeans = 1;
analysis.step3_min_norm_points = 1;
analysis.step4_mixis = 1;
analysis.unit = 100;
total_circuit=40;
Threshold = 3.8e-8;
simulationNum_save = [];
%% main procedure
sample_num_total=zeros(total_circuit,1);
for nnn=1:total_circuit
w = []; pfail = [];
global simulationNum;
simulationNum = 0;

if nnn <= 40
    sigma = 1;
elseif nnn <= 10
    sigma = 1.05;
elseif nnn <= 15
    sigma = 0.95;
elseif nnn <= 20
    sigma = 1.1;
elseif nnn <= 25
    sigma = 0.9;
elseif nnn <= 30
    sigma = 1.15;
elseif nnn <= 35
    sigma = 0.85;
end

%%  ================== Step 1: Spherical Samples ===================
sample_total=0;
nunit = 1000;
prob = 0.05; 
nfail_total=0;
nDim = size(analysis.model.mean,2); 
failed_samples_norm = [];
failed_samples_rad = [];
if analysis.step1_spherical_sample_run ~= 0
    disp(['Step1: expand the sampling sphere until ', num2str(1000*prob), '% of samples fail']);
    for rad = 5:15      
        samples_partial_dim = sample_on_sphere(nDim, rad, nunit);
        samples_norm = zeros(nunit, nDim);
        samples_norm =  samples_norm +samples_partial_dim;
        samples = repmat(analysis.model.mean,nunit,1) ...
                + samples_norm.*repmat(analysis.model.sigma,nunit,1); 
        outputs = runSimulation(samples, nunit, analysis);
        results = outputs < Threshold;
        nfail = nnz(results);
        nfail_total=nfail+nfail_total;
        sample_total=sample_total+1000;
        if(nfail) 
            failed_samples_norm = [failed_samples_norm; samples_norm(results,:)];   
            failed_samples_rad  = [failed_samples_rad; repmat(rad, nfail,1)];   
        end
        disp(['       On ', num2str(rad), ' Sigma sphere, ', num2str(nfail), ' out of ', num2str(nunit), ' samples are failed']);
        if(nfail>=prob*nunit)
            break;
        end
    end
    max_rad = rad;
    save('./data/spkmeans_step1_results', 'failed_samples_norm', 'failed_samples_rad', 'max_rad');
else
    disp(['Step1: (skipped) expand the sampling sphere until ', num2str(100*prob), '% of samples fail']);
    load('./data/spkmeans_step1_results', 'failed_samples_norm', 'failed_samples_rad', 'max_rad');
    nfail = length(failed_samples_rad);
    nfail_total = nfail;
    disp(['       On ', num2str(max_rad), ' Sigma sphere, ', num2str(nfail), ' out of ', num2str(nunit), ' samples are failed']);
end
failed_samples_weights = exp(-failed_samples_rad)./exp(-max_rad);

%%  ================== Step 2: Clustering ==========================
% choose the initial # of clusters k =2*sqrt(nfail);
% after spherical kmeans, k might be smaller than the original k
if analysis.step2_spkmeans ~= 0
    k = ceil(sqrt(nfail_total));
    disp(['Step2: Spherical k-means with ', num2str(k), ' clusters']);
    [label, C, target, k] = spkmeans_ww(failed_samples_norm, k, failed_samples_weights);%label��ÿ��ʧЧ��Ĵر�ţ�C�ǹ�һ���Ĵ��ġ���ꡱ��
    C = normr(C);
    save('./data/spkmeans_step2_kmeans_results', 'label', 'C', 'target', 'k');
else 
    load('./data/spkmeans_step2_kmeans_results', 'label', 'C', 'target', 'k');
    disp(['Step2: (skipped) Spherical k-means with ', num2str(k), ' clusters']);
end
disp(['       Failed samples are grouped in ', num2str(k) ,' clusters.']);

%%  ================== Step 3: Min-norm points =====================         
% find the smallest correlation (largest cosine distance) from the cluster centers
% also calculate eucilidian distance for angle specific sample generation
disp(['Step3: Backtrace to find the min-norm point for each cluster.']);

if analysis.step3_min_norm_points ~= 0
    C_sample_rad = zeros(k,1);
    C_minnorm = C;
    for i=1:k
        C_sample_rad(i) = min(failed_samples_rad(label==i));
    end
    C_rad  = zeros(k,1);
    C_corr = zeros(k,1);
    C_dist = zeros(k,1);
    for i=1:k
        C_corr(i) = min(normr(failed_samples_norm(label==i,:)) * normr(C(i,:))'); 
        num_sample_in_cluster = nnz(label==i); 
        diff_mat = normr(failed_samples_norm(label==i,:)) - repmat(normr(C(i,:)), num_sample_in_cluster, 1); 
        C_dist(i) = max(sqrt(sum(diff_mat.^2, 2))); 
    end
    C_dist(C_corr>0.5) = max(C_dist(C_corr>0.5), 1);
    C_corr(C_corr>0.5) = 0.5;
    nunit = 20;
    for i=1:k 
        high = max_rad;
        low = 0;
        for itr = 1:5 
            mid = (high+low)/2;
            samples_norm = sample_on_sphere(nDim, mid, nunit, C(i,:), C_corr(i), C_dist(i));
            samples = repmat(analysis.model.mean,nunit,1) ...
                    + samples_norm.*repmat(analysis.model.sigma,nunit,1);
            outputs = runSimulation(samples, nunit, analysis);
            results = outputs < Threshold;
            if(nnz(results))
                high = mid;
                C_minnorm(i,:) = normr(sum(samples_norm(results,:),1));
            else
                low = mid;
            end
            disp(['Cluster ', num2str(i), ': ', num2str(nnz(results)), ' failures in radius = ', num2str(mid)]);
        end
        disp(' ');
        C_rad(i) = low;
    end
    sample_total=sample_total+k*5*nunit;
    C_rad = min([C_rad, C_sample_rad], [], 2);
    C = C_minnorm;
    save('./data/spkmeans_step3_min_norm_points', 'C_rad');
else
    load('./data/spkmeans_step3_min_norm_points', 'C_rad');
end
C_rad = C_rad;
for i=1:k
    disp(['       Min-Norm point ', num2str(i), ': radius = ', num2str(C_rad(i)), ', centered at: ', num2str(C_rad(i)*C(i,:))]);
end

%%  ================== Step 4: Mixture IS ==========================
% Shift the sample mean to the centroid of multiple clusters
disp(['Step4: Mixture importance sampling for multiple failure regions.']);
% Mean and Sigma for Mean shift IS
% Mean will be the centroids for the failure clusters
% Sigma does not matter
% (obsolete will be length of the cone, which can be calculated as follows)
if analysis.step4_mixis ~= 0
    Cluster_means  = C .* repmat(C_rad,1,nDim);
    Cluster_sigmas = sigma * ones(k,nDim);
    mean0  = zeros(1, nDim);
    sigma0 = ones(1, nDim);
    % MixIS, 2% samples with orignal distribution, 90% samples per clusters
    nunit = 2000;
    origin_weight_ratio = 0.02;
    n0 = ceil(nunit*origin_weight_ratio);
    % calculate the weights of each cluster to determine the # of samples
    cluster_weights = zeros(k,1);
    for i=1:k
        cluster_weights(i) = sum(failed_samples_weights(label==i));
    end
    cluster_weights = cluster_weights./sum(cluster_weights)*(1-origin_weight_ratio);
    nc = ceil(cluster_weights.*nunit);
    nunit = n0 + sum(nc);
    disp(['       Mixture importance sampling in ', num2str(k), ' clusters.']);
    disp(['       # of samples in these clusters are ', num2str(nc')]);
    IS_samples_norm = [];
    IS_samples = [];
    itr = 20;
    n0=n0* itr;
    nunit=nunit* itr;
    IS_samples_itr_norm = zeros(nunit, nDim);
    if(n0>0)
        samples = normrnd(repmat(mean0,n0,1), repmat(sigma0,n0,1));
        IS_samples_itr_norm(1:n0,:) = samples;
    end
    % samples centered at each failure region
    nd = n0;
    for i=1:k
        nc(i)=nc(i)*itr;
        if (nc(i)>0)
            st = nd+1; nd = nd+nc(i);
            samples = normrnd(repmat(Cluster_means(i,:),nc(i),1), ...
                repmat(Cluster_sigmas(i,:),nc(i),1));
            IS_samples_itr_norm(st:nd,:) = samples;
        end
    end
    % scale samples with circuit parameters
    IS_samples_itr = repmat(analysis.model.mean,nunit,1) ...
            + IS_samples_itr_norm.*repmat(analysis.model.sigma,nunit,1);
    IS_samples_norm = [IS_samples_norm; IS_samples_itr_norm];
    IS_samples      = [IS_samples;      IS_samples_itr];
    outputs = runSimulation(IS_samples_itr, nunit, analysis);
    I = outputs < Threshold;
    i=0;
    p_1=0;
    p_2=0;
    pfail1 = [];
    pfail2 = [];
    while i<nunit
        i=i+1;
        x=IS_samples_norm(i,:);   
        f(i,:)=(2*pi)^(-nDim/2)*exp(-1/2*x*x');
        g(i,:)=origin_weight_ratio*(2*pi)^(-nDim/2)*exp(-1/2*x*x');
        for c=1:k
            g(i,:)=g(i,:)+cluster_weights(c)*(2*pi)^(-nDim/2)*exp(-1/2*(x-Cluster_means(c,:))*(x-Cluster_means(c,:))');
        end
        w(i,:)=f(i,:)./g(i,:);
        p=w(i,:)*I(i,1)+p;
        
        pfail(i) = p/i;
    end  
    sample_total=sample_total+nunit;
end

weights{nnn} = w;
p_fail_total{nnn} = pfail;
sample_num_total(nnn)=sample_total;
simulationNum_save = [simulationNum_save; simulationNum]
save('./data/p_fail_total1','p_fail_total1');
save('./data/p_fail_total2','p_fail_total2');
save('./data/simulationNum', 'simulationNum_save');
save('./data/weights', 'weights');
end

