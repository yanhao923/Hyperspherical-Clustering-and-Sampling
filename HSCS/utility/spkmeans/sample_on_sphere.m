function samples = sample_on_sphere(nDim, r, N, varargin)

% Spherical sampling at radius = r
% With a similarity to "sample_center" larger than sample_similarity
if nargin <= 3; %����ɱ����������3
    % Spherical Sampling
%     samples = r * normr( randn(N, nDim) ); % gaussian type
     samples = r * normr( randn(N, nDim) ); 
else
    % Sampling at a circuit angle (pointing to one cone)
    % Draw a uniform distributed samples around centroid, and over +/- 1.5 
    % radius, then normalize them to the unit hypersphere
    sample_centroid = varargin{1};%���ôش��ķ����sample_centroid
    if(size(sample_centroid, 1) ~=1)
        error('ERROR: sample_center should consist only one row!');
    end
    sample_centroid = normr(sample_centroid);
    sample_similarity = varargin{2};%���ô�������cosine���루���Ĺ�ʽ������С�Ƕȣ�����sample_similarity
    if(abs(sample_similarity)>=1)
        error('ERROR: similarity must be in between -1 and 1');
    end
    sample_e_distance = varargin{3};%���ô�������ŷʽ���븳��sample_e_distance
    if(sample_e_distance<=0)
        error('ERROR: eucilidian distance must be larger than 1');
    end
    samples = zeros(N,nDim);
    cnt = 0;
%     disp(['       generating ', num2str(N), ' samples with similarity to centroid > ', num2str(sample_similarity)]);
    while cnt < N
        % temp_samples closed to origin???
        %temp_samples = (rand(N,nDim)-0.5*ones(N,nDim))*sample_e_distance;%���ݣ���rand(N,nDim)�ǲ���һ��N*nDim�������󣬾���Ԫ���ǣ�0,1����������
        temp_samples = (-1.5+3*rand(N,nDim))*sample_e_distance;
        % shift the temp samples to the centroid area
        temp_samples = repmat(sample_centroid, N, 1) + temp_samples;
        % normalization
        temp_samples = normr(temp_samples);
        % check similary to given sample centroid
        corr = temp_samples * sample_centroid';
        sel = corr >= sample_similarity;%sample_similarity�൱����ͬһ�����½Ƕȵ�����
        % scale temp_samples to R hypersphere and add to samples
        temp_samples = r*temp_samples(sel,:);%temp_samples(sel,:)��ʾȡ�þ���ĵ�sel��,�ٳ��԰뾶mid=(high+low)/2
        nd = min(nnz(sel), N-cnt);
        samples(cnt+1:cnt+nd,:) = temp_samples(1:nd,:);%�˴����Բ���nd�����
        cnt = cnt + nd;
    end

end
end

%% lottory method...
%     sample_centroid = varargin{1};
%     if(size(sample_centroid, 1) ~=1)
%         error('ERROR: sample_center should consist of only one row!');
%     end
%     sample_centroid = normr(sample_centroid);
%     sample_similarity = varargin{2};
%     if(abs(sample_similarity)>=1)
%         error('ERROR: similarity should be in between -1 and 1');
%     end
%     samples = zeros(N,nDim);
%     cnt = 0;
%     disp(['       generating ', num2str(N), ' samples with similarity to centroid > ', num2str(sample_similarity)]);
%     while cnt < N
%         temp_samples = normr( randn(N, nDim) );
%         % check similary to given sample centroid
%         corr = temp_samples * sample_centroid';
%         sel = corr >= sample_similarity;
%         % scale temp_samples to R hypersphere and add to samples
%         temp_samples = r*temp_samples(sel,:);
%         nd = min(nnz(sel), N-cnt);
%         samples(cnt+1:cnt+nd,:) = temp_samples(1:nd,:);
%         cnt = cnt + nd;
%     end
% end
% 
% end
