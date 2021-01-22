function [] = eyesig(x,period,start_off,data_str)

%clf;
eye_diag(period,start_off,x(1).data,evalsig(x,data_str),data_str);
