function [t_dp_thr, thr_step, ch_id, par] = noise_level_2_nswiew(polytrode_n, log_deblock, path)
% Create a variable, that contains the noise levels for each
% channel and also the corresponding time vector.
% Both should take a stepfunction form.

%% ADJUST THE AMPLITUDES!
% For the moment, we need to adjust the amplitudes of the signal in the
% .mat file and the one in the .cnt file. This means a multiplication by 4.
% However, this should be resolved later on by loading the converting the
% .mat files from .cnt via nswiew (and not NeuroScan 4.5)!!!

factor = 4;

%% Load data, initialize
load([path '/' 'polytrode' num2str(polytrode_n) '_spikes.mat'], 'thr', 'par')
load(log_deblock);
fileID = fopen(['polytrode' num2str(polytrode_n) '.txt'],'r');
tline = fgetl(fileID);
tlines = cell(0,1);
while ischar(tline)
    tlines{end+1,1} = tline;
    tline = fgetl(fileID);
end
fclose(fileID);

no_channels = size(tlines,1);
ch_id = [1:no_channels] + polytrode_n - 1; 
no_all_channels = 24;
% get the length of the data. This should be the same size for all
% channels, thus loading the first one is sufficient.

var_datafile = matfile(tlines{1,1});
details = whos(var_datafile, 'data');
if size(details,1) == 0
    disp('Error: datafile not found!');
    return
else
    length_data_dp = details.size(1);
end
%% construct a step_function from thr
thr = factor * thr;

thr_step = NaN( 2*size(thr,1) , no_all_channels);
for i = 1:no_channels
    thr_rshp_ch = reshape(repmat(thr(:,i),1,2)',1,2*length(thr));
    thr_step_ch = thr_rshp_ch';
    thr_step(:,ch_id(i)) = thr_step_ch;
end

%% Reconstruct the real timepoint of the spike-times using log_deblock
% WE NEED THIS IN DATAPOINTS!!!
segments_length = par.segments_length; % in min
segments_length_s = segments_length * 60; % in sec

length_data_s = length_data_dp / par.sr; % in sec
no_segments_noise = ceil(length_data_s / segments_length_s);

segment_length_real_dp = floor(length_data_dp/no_segments_noise); % in dp
t_segments = (0:no_segments_noise) * segment_length_real_dp;

t_rshp = reshape(repmat(t_segments',1,2)',1,2*length(t_segments));
t_step = t_rshp(2:end-1)';


%%   We have to shift the elements of t_step using log_deblock
t_dp_thr = t_step;
log_deblock = segments;
for i = 1:size(log_deblock,1)
        % get start and endpoint for deblocking
        block_start = log_deblock(i,1);
        block_end = log_deblock(i,2);
        length_block = block_end-block_start;
        t_dp_thr = [t_dp_thr(t_dp_thr <= block_start); t_dp_thr(t_dp_thr > block_start) + length_block];
end

%% Plot the staff, to check, if works or not!
%fig_noise = figure('Name', ['Detection noise-level of polytrode ', num2str(polytrode_n)],'units','normalized','outerposition',[0 0 1 1]);
%hold on
%plot(t_dp_thr./par.sr,thr_step);

%yl = ylim;
% plot vertical lines between each epoch
%{
for i = 1:15
    plot([i,i]*100, yl,'--', 'Color', [0.4 0.4 0.4]);
end
%}

% plot areas of segments to indicate where spike sorting hasn't been performed 
for i = 1:size(log_deblock,1)
    block_start = log_deblock(i,1)/par.sr;
    block_end = log_deblock(i,2)/par.sr;
    length_block = block_end-block_start;
    %rectangle('Position',[block_start,yl(1),length_block,(yl(2)-yl(1))],...
    %    'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);
end
%% save the data: not needed
%save(['ns_thr_polytrode' num2str(polytrode_n) '.mat'], 't_dp_thr', 'thr_step', 'ch_id', 'par');
end

