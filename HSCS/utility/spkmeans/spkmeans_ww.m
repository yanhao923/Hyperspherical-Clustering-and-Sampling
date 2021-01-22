function [label_rt, C_rt, target_rt, k_rt] = spkmeans_ww(X, varargin)
% Perform spherical k-means clustering.
% Input Parameters:
%   X: n x nDim data matrix (each row is a vector)
%   k: # of clusters (optional)
%   visualize: plot the first 2 dimension of the input
% Output Parameters:
%   label_rt: label for each sample
%   C_rt: k * nDim matrix for normalized center of each cluster
%   target_rt: optimization target (cosine similarity)
%   k_rt: # of clusters (actual generated clusters might be less than the input)
% Author: Wei Wu
% Create Date: 03/09/2015
% Affliation: UCLA, Design Automation Lab. 

%% Input data check
visualize = 0;
scan_k = 1;
if ~size(X)
    error('ERROR: Empty input data matrix!');
end 
[n,nDim] = size(X);%将矩阵X的行数和列数分别赋给n和nDim，n相当于总的失效的样本个数
if nargin>=2
    k_in = varargin{1};%k_in取 varargin输入的第一个变量k
    scan_k = 0;
end
if(k_in>n || k_in<1)
    error('ERROR: Invalid input variable: ''k''!');
end
if nargin >= 3
    sample_weights = varargin{2};%sample_weights取 varargin输入的第二个变量failed_samples_weights
else
    sample_weights = ones(n,1);
end
if nargin >= 4
    visualize = varargin{3};
end
if visualize
    figure(2);
    hold off;
    color_code = {'g', 'r', 'b', 'y', 'k'};
    plot(X(:,1), X(:,2), '*b');
    radius = norm(X(1,:));
    axis([-8, 8, -8, 8])
    title(['Clustering on ', num2str(radius), ' Sigma hypersphere']);
end 


%% Normalize X to unit hypersphere
n_init = 50;
X_norm = normr(X);%将失效样本点“范数”归一化
X_weighted = X.*repmat(sample_weights,1,nDim);%将归一化的失效样本范数乘以相应的失效样本权重得到新的带权重的失效样本“范数”
%Each failed sample is normalized to unit length and associated with a weight calculated based on its probability density.
%% Initialize return variables
target_rt = 0;
%% Spherical K-means with n_init set of random initial cluster centers（错） 
for i_try =1:n_init %这应该指的迭代的次数？
    %% Random initialization
    k = k_in;%Number of initial clusters: ?
    C = normr(randn(k, nDim));%Randomly initialize the unit length cluster centroids，簇中心范数个数与k一致，并归一化
    %% iteratively finding the (local) opitmal
    label_d = ones(n,1);%将n(失效样本总数)*1的全1矩阵赋给label_d
    cnt = 0;
    while (1)
        % data assignment, and remove empty clusters
        [val, label] = max(X_weighted*C',[],2);%X_weighted*C' the algorithm checks the cosine distance between a sample and all cluster centroids.相当于找cosine距离最小的
        %找出X_weighted*C'矩阵每行的最大值和列的标志分别赋给val和label？？（因为列数与簇的个数相等。X_weighted*C'是failed sample number*cluster number）
        target = sum(val,1);%计算val每列的值的和并赋给target
        [temp,~,label] = unique(label);%temp取label中不同元素构成的向量；~体现temp在原label中的位置（相同元素按升序的位置）；新label体现原label在temp里的位置
        k = length(temp);%返回temp向量的最大维度（the largest dimension）的元素个数；起到cleans up empty cluster的作用
        % centroid update
        sel = sparse(1:n,label,1,n,k,n); % n-by-k selection matrix稀疏矩阵（大多数元素为0的）？？
        C = sel'*X_weighted; %更新簇中心范数（k个），使之带权重成分
        C = normr(C);%将新的簇心归一化
%         disp(['       Iteration ', num2str(cnt), ': maximization target is ', num2str(target)]);
        if(any(label ~= label_d)) %如果label不等于label_d
            label_d = label;%用新的簇标签去替代
            cnt = cnt + 1;
            continue;
        else
%             disp(['       Converged at a total number of ', num2str(k), ' clusters!']);
            break;
        end
    end
%     disp(['       Trial ', num2str(i_try), ' end up with ', num2str(k), ' clusters, target = ', num2str(target), '...']);
    if(target>target_rt) 
        target_rt = target;
        label_rt = label;%此处label是指样本所在的簇的编号
        k_rt = k;
        C_rt = C;
%         disp(['          Clusters in trial ', num2str(i_try), ' is selected!']);
        if(visualize && k <= 5)
            % plot all the data
            hold off;
            plot(X(:,1), X(:,2), '*b'); %画X矩阵的第1列和第2列？？
            hold on;
            axis([-8, 8, -8, 8])
            title(['Clustering on ', num2str(norm(X(1,:))), ' Sigma hypersphere']);%在当前轴上添加标题?
            % plot clusters if k<=5 (at most 5 colors)
            for i=1:min(k,5)
                plot(X(label_d==i,1),X(label_d==i,2), ['o',color_code{i}]);
                plot(radius*C(i,1), radius*C(i,2), ['.',color_code{i}], 'markersize',50);
            end
        end
    end
end

%% add logic to choose the optimal k (if only X is input, then let the code to choose optimal k)


