
function [output] = run_spice(sample, num, hspicepath)
num = size(sample,1);
%% write sweep file 
fp1 = fopen('./sweep_data_mc','w');
fprintf(fp1,'.DATA data\n');
fprintf(fp1,'voff_pd1 vth0_pd1 ub_pd1 voff_pd2 vth0_pd2 ub_pd2 voff_wl1 vth0_wl1 ub_wl1 voff_wl2 vth0_wl2 ub_wl2 voff_pu1 vth0_pu1 ub_pu1 voff_pu2 vth0_pu2 ub_pu2\n');
for i=1:num
    fprintf(fp1, '%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\n', sample(i,1), sample(i,2), sample(i,3), sample(i,4), sample(i,5), sample(i,6), sample(i,7), sample(i,8), sample(i,9), sample(i,10), sample(i,11), sample(i,12), sample(i,13), sample(i,14), sample(i,15), sample(i,16), sample(i,17), sample(i,18));
end
fprintf(fp1,'.ENDDATA\n');
fclose(fp1);
%% simulate
dos([hspicepath, ' -i  ./sram.sp'])
%% load data from .mt0 file
output = zeros(num,1);
fid = fopen('sram.mt0', 'r');
%% skip the lines before alter#
while feof(fid) == 0
    line = fgetl(fid);
    if ~isempty(strfind(line,'alter#'))
        break;
    end
end

%% Get Ratio: ratio is the second string in the second row
cnt = 0;
while ~feof(fid) && cnt<num 
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    line = fgetl(fid);
    remainder = line;
    [chopped, remainder] = strtok(remainder);
    if (strcmp(chopped,'failed'))
        chopped='1e-6';
    end
    cnt = cnt + 1;
    output(cnt,1) = str2num(chopped);
    line = fgetl(fid);
end
fclose(fid);
end
