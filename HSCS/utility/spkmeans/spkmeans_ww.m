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
[n,nDim] = size(X);%������X�������������ֱ𸳸�n��nDim��n�൱���ܵ�ʧЧ����������
if nargin>=2
    k_in = varargin{1};%k_inȡ varargin����ĵ�һ������k
    scan_k = 0;
end
if(k_in>n || k_in<1)
    error('ERROR: Invalid input variable: ''k''!');
end
if nargin >= 3
    sample_weights = varargin{2};%sample_weightsȡ varargin����ĵڶ�������failed_samples_weights
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
X_norm = normr(X);%��ʧЧ�����㡰��������һ��
X_weighted = X.*repmat(sample_weights,1,nDim);%����һ����ʧЧ��������������Ӧ��ʧЧ����Ȩ�صõ��µĴ�Ȩ�ص�ʧЧ������������
%Each failed sample is normalized to unit length and associated with a weight calculated based on its probability density.
%% Initialize return variables
target_rt = 0;
%% Spherical K-means with n_init set of random initial cluster centers���� 
for i_try =1:n_init %��Ӧ��ָ�ĵ����Ĵ�����
    %% Random initialization
    k = k_in;%Number of initial clusters: ?
    C = normr(randn(k, nDim));%Randomly initialize the unit length cluster centroids�������ķ���������kһ�£�����һ��
    %% iteratively finding the (local) opitmal
    label_d = ones(n,1);%��n(ʧЧ��������)*1��ȫ1���󸳸�label_d
    cnt = 0;
    while (1)
        % data assignment, and remove empty clusters
        [val, label] = max(X_weighted*C',[],2);%X_weighted*C' the algorithm checks the cosine distance between a sample and all cluster centroids.�൱����cosine������С��
        %�ҳ�X_weighted*C'����ÿ�е����ֵ���еı�־�ֱ𸳸�val��label��������Ϊ������صĸ�����ȡ�X_weighted*C'��failed sample number*cluster number��
        target = sum(val,1);%����valÿ�е�ֵ�ĺͲ�����target
        [temp,~,label] = unique(label);%tempȡlabel�в�ͬԪ�ع��ɵ�������~����temp��ԭlabel�е�λ�ã���ͬԪ�ذ������λ�ã�����label����ԭlabel��temp���λ��
        k = length(temp);%����temp���������ά�ȣ�the largest dimension����Ԫ�ظ�������cleans up empty cluster������
        % centroid update
        sel = sparse(1:n,label,1,n,k,n); % n-by-k selection matrixϡ����󣨴����Ԫ��Ϊ0�ģ�����
        C = sel'*X_weighted; %���´����ķ�����k������ʹ֮��Ȩ�سɷ�
        C = normr(C);%���µĴ��Ĺ�һ��
%         disp(['       Iteration ', num2str(cnt), ': maximization target is ', num2str(target)]);
        if(any(label ~= label_d)) %���label������label_d
            label_d = label;%���µĴر�ǩȥ���
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
        label_rt = label;%�˴�label��ָ�������ڵĴصı��
        k_rt = k;
        C_rt = C;
%         disp(['          Clusters in trial ', num2str(i_try), ' is selected!']);
        if(visualize && k <= 5)
            % plot all the data
            hold off;
            plot(X(:,1), X(:,2), '*b'); %��X����ĵ�1�к͵�2�У���
            hold on;
            axis([-8, 8, -8, 8])
            title(['Clustering on ', num2str(norm(X(1,:))), ' Sigma hypersphere']);%�ڵ�ǰ������ӱ���?
            % plot clusters if k<=5 (at most 5 colors)
            for i=1:min(k,5)
                plot(X(label_d==i,1),X(label_d==i,2), ['o',color_code{i}]);
                plot(radius*C(i,1), radius*C(i,2), ['.',color_code{i}], 'markersize',50);
            end
        end
    end
end

%% add logic to choose the optimal k (if only X is input, then let the code to choose optimal k)


