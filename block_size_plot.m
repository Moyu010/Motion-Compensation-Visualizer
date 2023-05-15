%% Block Size investigation
clear; clc; close all;
% Load video
video = VideoReader('source.avi');
time = video.CurrentTime;
% Basic parameters (IV) (Constants)
reference_frame_update_cycle = 2;
all_block_sizes = 2.^(1:6);
search_range = 7;
num_of_frames = 2*100;
search_strategy_names = ["No MC", "Exhaustive Search", "Three Step Search", "New Three Step Search"];
search_strategies = {@dummyMotionEstimation, @motionEstimationByES, @motionEstimationByTSS, @motionEstimationByNTSS};
% (i, j, k) = (strat, block_size, PSNR/num_compare)
block_size_data = zeros(length(search_strategies), length(all_block_sizes), 2);

for i = 1:length(all_block_sizes)
    % Load the video sequence (rewind, so we are operating on the same start)
    video.CurrentTime = time;
    block_size = all_block_sizes(i);
    % report progress
    fprintf("Currently on block size %d. \n", block_size);
    % Acting loop
    frame = 1;
    % number of frames that are not reference
    total_estimate = num_of_frames-floor(num_of_frames/reference_frame_update_cycle);
    % peak signal to noise ratio, a measure of error (peak~peak^2(which is 1 as the frame is converted to double)/MSE(RMSE^2)) in db
    PSNR_func = @(mat_1, mat_2) 10*log10(1/rmse(mat_1, mat_2, 'all')^2);
    
    % the main difference between the MAD should be from the zero padding
    % calculation, but I'm not super certain. 
    % for if you decide to do multiple frames
    avg_MAD_over_frames = zeros(length(search_strategies), total_estimate); 
    mean_difference_MAD_over_frames = zeros(length(search_strategies), total_estimate);
    num_compare_over_frames = zeros(length(search_strategies), total_estimate);
    PSNR_over_frames = zeros(length(search_strategies), total_estimate);
    num_estimate = 0;
    while frame <= num_of_frames % adjust how many frames this will be done on
        % get reference frame every few frames (which is typically transmitted as a whole)
        if mod(frame, reference_frame_update_cycle) == 1
            reference_frame = im2double(readFrame(video));
            reference_frame_gray = im2gray(reference_frame);
            frame = frame + 1;
        end
        % read the frame
        current_frame = im2double(readFrame(video));
        current_frame_gray = im2gray(current_frame);
        % compute the motion vectors, testing the method used here
        frame = frame + 1;
        num_estimate = num_estimate + 1;
        index = 1;
        % for all search strategies
        for j = 1:length(search_strategies)
            strategy = search_strategies{j};
            [motion_vec, avg_MAD, num_compare] = strategy(reference_frame_gray, current_frame_gray, block_size, search_range);
            num_compare_over_frames(index, num_estimate) = num_compare_over_frames(index, num_estimate) + num_compare;
            avg_MAD_over_frames(index, num_estimate) = avg_MAD_over_frames(index, num_estimate) + avg_MAD;
            % compensate and find prediction error
            [predicted_frame, ~, mean_difference_MAD] = motionCompensation(reference_frame, current_frame, motion_vec, block_size);
            mean_difference_MAD_over_frames(index, num_estimate) = mean_difference_MAD_over_frames(index, num_estimate) + mean_difference_MAD;
            PSNR_over_frames(index, num_estimate) = PSNR_over_frames(index, num_estimate) + PSNR_func(current_frame, predicted_frame);
            index = index + 1;
        end
    end
    line_data = cat(3, ...
                    PSNR_over_frames,...
                    num_compare_over_frames*block_size^2);
    bar_data = squeeze(sum(line_data, 2))/total_estimate;
    block_size_data(:, i, :) = bar_data;
end

axes_labels = [
               "Prediction PSNR";
               "Approximate FLOPs in matching";
              ];

figure(1);
% for each category
for data_row = 1:length(axes_labels)
    subplot(1, 2, data_row);
    hold on;
    % for each strategy
    for i = 1:length(search_strategies)
        plot(all_block_sizes, block_size_data(i, :, data_row));
    end
    ylim([0.8*min(block_size_data(:, :, data_row), [], 'all'), 1.2*max(block_size_data(:, :, data_row), [], 'all')])
    xticks(all_block_sizes);
    xlabel("Block Size");
    ylabel(axes_labels(data_row));
    legend(cellstr(search_strategy_names), Location="northeast")
    hXLabel = get(gca, 'XLabel');
    set(hXLabel, 'FontSize', 16);
    hYLabel = get(gca, 'YLabel');
    set(hYLabel, 'FontSize', 16);
end
% set the figure to full screen
set(figure(1), 'Position', get(0, 'Screensize'));
% save the figure in full screen
print(pwd+"\plots\Line_Graph_Block_Size", '-dpng', '-r600');





