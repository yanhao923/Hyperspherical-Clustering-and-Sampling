%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Provide the MEAN and SIGMA as initial input data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

voff_pd1_mean = -0.177; vth0_pd1_mean = 0.35074; ub_pd1_mean = 1.9384*10^(-18);
voff_pd2_mean = -0.177; vth0_pd2_mean = 0.35074; ub_pd2_mean = 1.9384*10^(-18);
voff_wl1_mean = -0.1821; vth0_wl1_mean = 0.32353; ub_wl1_mean = 1.0759*10^(-18);
voff_wl2_mean = -0.1821; vth0_wl2_mean = 0.32353; ub_wl2_mean = 1.0759*10^(-18);
voff_pu1_mean = -0.14202; vth0_pu1_mean = -0.29825; ub_pu1_mean = 1.1397*10^(-19);
voff_pu2_mean = -0.14202; vth0_pu2_mean = -0.29825; ub_pu2_mean = 1.1397*10^(-19);
voff_pd1_sigma = 0.0525; vth0_pd1_sigma = 0.01945; ub_pd1_sigma = 5.9003*10^(-20);
voff_pd2_sigma = 0.0525; vth0_pd2_sigma = 0.01945; ub_pd2_sigma = 5.9003*10^(-20);
voff_wl1_sigma = 0.03942; vth0_wl1_sigma = 0.02855; ub_wl1_sigma = 1.34760*10^(-19);
voff_wl2_sigma = 0.03942; vth0_wl2_sigma = 0.02855; ub_wl2_sigma = 1.34760*10^(-19);
voff_pu1_sigma = 1.85736*10^(-4); vth0_pu1_sigma = 0.0365; ub_pu1_sigma = 7.24372*10^(-19);
voff_pu2_sigma = 1.85736*10^(-4); vth0_pu2_sigma = 0.0365; ub_pu2_sigma = 7.24372*10^(-19);
mean_vals = [voff_pd1_mean, vth0_pd1_mean, ub_pd1_mean, voff_pd2_mean, vth0_pd2_mean, ub_pd2_mean, voff_wl1_mean, vth0_wl1_mean, ub_wl1_mean, voff_wl2_mean, vth0_wl2_mean, ub_wl2_mean, voff_pu1_mean, vth0_pu1_mean, ub_pu1_mean, voff_pu2_mean, vth0_pu2_mean, ub_pu2_mean];
sigma_vals = [voff_pd1_sigma, vth0_pd1_sigma, ub_pd1_sigma, voff_pd2_sigma, vth0_pd2_sigma, ub_pd2_sigma, voff_wl1_sigma, vth0_wl1_sigma, ub_wl1_sigma, voff_wl2_sigma, vth0_wl2_sigma, ub_wl2_sigma, voff_pu1_sigma, vth0_pu1_sigma, ub_pu1_sigma, voff_pu2_sigma, vth0_pu2_sigma, ub_pu2_sigma];

% % initialize the mean and sigma for random variables
% nmos_mean = [0.55 1.85e-9 0.0044 2.44e18 3.75e-9 5e-9 5 1.1e-10 1.1e-10];
% pmos_mean = [-0.55 1.75e-9 0.04398 3.24e18 3.75e-9 5e-9 5 1.1e-10 1.1e-10];
% nmos_sigma_initial = [0.55*0.1 1.85e-9*0.05 0.0044*0.1 2.44e18*0.1 3.75e-9*0.05 5e-9*0.05 5*0.1 1.1e-10*0.1 1.1e-10*0.1];
% pmos_sigma_initial = [0.55*0.1 1.75e-9*0.05 0.04398*0.1 3.24e18*0.1 3.75e-9*0.05 5e-9*0.05 5*0.1 1.1e-10*0.1 1.1e-10*0.1];
% % full vector length 36x1
% mean_initial = [pmos_mean pmos_mean nmos_mean nmos_mean nmos_mean nmos_mean]';
% sigma_initial = [pmos_sigma_initial pmos_sigma_initial nmos_sigma_initial nmos_sigma_initial nmos_sigma_initial nmos_sigma_initial]';
% % convert them into 36x1 vector
% mean_initial_values = zeros(54,1);
% sigma_initial_values = zeros(54,1);
% % 6 transistor x9 variables format
% for i=1:9
%     for j=1:6
%         idx = (j-1)*9+i;
%         % mean value
%         mean_value = mean_initial(idx);
%         mean_initial_values((i-1)*6+j) = mean_value;
%         % sigma value
%         sigma_value = sigma_initial(idx);
%         sigma_initial_values((i-1)*6+j) = sigma_value;
%     end
% end
