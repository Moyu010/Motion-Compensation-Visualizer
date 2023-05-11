%% Multiple frame investigation
clear; clc; close all;
% Load the video sequence
video = VideoReader('source.avi');
% Basic parameters (IV)
reference_frame_update_cycle = 2;
block_size = 16;
search_range = 7;
num_of_frames = 2*100;
search_strategy_names = ["No MC", "Exhaustive Search", "Three Step Search", "New Three Step Search"];
search_strategies = {@dummyMotionEstimation, @motionEstimationByES, @motionEstimationByTSS, @motionEstimationByNTSS};
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
    % Progress bar printing
    fprintf("On frame %d. \n", frame);

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
    for i = 1:length(search_strategies)
        strategy = search_strategies{i};
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

axes_labels = [
               "Prediction PSNR";
               "Approximate FLOPs in matching";
              ];
% first plot line graph over frames
figure(1);
line_data = cat(3, ...
        PSNR_over_frames,...
        num_compare_over_frames*block_size^2);
% for each category
for data_row = 1:length(axes_labels)
    subplot(1, 2, data_row);
    hold on;
    % for each strategy
    for i = 1:length(search_strategies)
        plot(1:total_estimate, line_data(i, :, data_row));
    end
    ylim([0.8*min(line_data(:, :, data_row), [], 'all'), 1.2*max(line_data(:, :, data_row), [], 'all')])
    % show only integer x axis gradations (as frame number)
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    xlabel("frame number");
    ylabel(axes_labels(data_row));
    legend(cellstr(search_strategy_names), Location="best")
end
% set the figure to full screen
set(figure(1), 'Position', get(0, 'Screensize'));
% save the figure in full screen
print('Line_Graph', '-dpng', '-r600');


figure(2);
bar_data = squeeze(sum(line_data, 2))/total_estimate;
for data_row = 1:length(axes_labels)
    subplot(1, 2, data_row);
    bar(diag(bar_data(:, data_row)), 'stacked');
    ylabel(axes_labels(data_row));
    set(gca,'xticklabel',search_strategy_names);
    text(1:length(bar_data(:, data_row)),bar_data(:, data_row),num2str(bar_data(:, data_row)),'vert','bottom','horiz','center'); 
    hold on;
end
% set the figure to full screen
set(figure(2), 'Position', get(0, 'Screensize'));
% save the figure in full screen
print('Bar_Graph', '-dpng', '-r600');





