function [clusters_2_nswiew] = wave_clus_2_nswiew(times_polytrode_n, filename_log_deblock, path)
% get timing of the spikes
% reconstruct the real time_scale in dp
% as 2 additional columns add the start and end time of the spike
%% Load the data:
load([path '/' 'times_polytrode' num2str(times_polytrode_n) '.mat'],'cluster_class', 'par');
load(filename_log_deblock);
%% Initialize:
log_deblock = segments; % in datapoints (sr = 20000 Hz)
srate = par.sr;
times_dp = round(cluster_class(:,2)/1000*srate);

%% Reconstruct the real timepoint of the spike-times using log_deblock
times_real = times_dp;
for i = 1:size(log_deblock,1)
        % get start and endpoint for deblocking
        block_start = log_deblock(i,1);
        block_end = log_deblock(i,2);
        length_block = block_end-block_start;
        times_real = [times_real(times_real <= block_start); times_real(times_real > block_start) + length_block];
end

%% Add the start and end time of the spike as 2 additional columns
times_start = times_real - par.w_pre + 1;
times_end = times_real + par.w_post;

clusters_2_nswiew = [cluster_class(:,1), times_start, times_real, times_end];

%% Save the data: not needed
save(['ns_times_polytrode' times_polytrode_n], 'clusters_2_nswiew');
end

