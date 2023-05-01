%% Single frame investigation
% You can wrap this section in loops to plot effects of different
% strategies, block size etc.
clear; clc; close all;
% Load the video sequence
video = VideoReader('source.mp4');
% Basic parameters (IV)
reference_frame_update_cycle = 6;
block_size = 16;
search_range = 7;
num_of_frames = 640;
% Viewing parameters
show_frame = false;
show_vectors = false;
show_difference = false;
show_predicted = true;
pause_time = 0.2; % how long the figures stay unwritten to, if you do multiple frames
% Acting loop
frame = 1;
% DVs you may be interested in
avg_MAD = 0; % average mean difference during motion estimation, measure of effectiveness/accuracy
num_compare = 0; % number of blocks that are compared, a measure for cost of estimation, will be the same across frames (* block_size^2 = about number FLOPs)
mean_difference_MAD = 0; % mean difference between prediction frame and original frame, measure of accuracy
% the main difference between the MAD should be from the zero padding
% calculation, but I'm not super certain. 
% for if you decide to do multiple frames
avg_MAD_over_frames = 0; 
mean_difference_MAD_over_frames = 0;
num_estimate = 0;
while frame < num_of_frames % adjust how many frames this will be done on
    % get reference frame every few frames (which is typically transmitted as a whole)
    if mod(frame, reference_frame_update_cycle) == 1
        reference_frame = im2double(readFrame(video));
        reference_frame_gray = im2gray(reference_frame);
        reference_frame_number = frame;
        frame = frame + 1;
    end
    % read the frame
    current_frame = im2double(readFrame(video));
    current_frame_gray = im2gray(current_frame);
    % compute the motion vectors, change the method used here
    [motion_vec, avg_MAD, num_compare] = motionEstimationByES(reference_frame_gray, current_frame_gray, block_size, search_range);
    avg_MAD_over_frames = avg_MAD_over_frames + avg_MAD;
    if show_vectors
        figure(1)
        plot_motion(motion_vec, block_size);
    end
    
    if show_frame
        figure(2);
        subplot(1, 2, 1);
        imshow(reference_frame);
        title(sprintf("Reference (Frame %d)", reference_frame_number));
        subplot(1, 2, 2);
        imshow(current_frame);
        title(sprintf("Current (Frame %d)", frame))
    end
    
    [predicted_frame, prediction_difference, mean_difference_MAD] = motionCompensation(reference_frame, current_frame, motion_vec, block_size);
    mean_difference_MAD_over_frames = mean_difference_MAD_over_frames + mean_difference_MAD;
    if show_difference
        figure(3);
        imshow(prediction_difference);
    end
    if show_predicted
        figure(4);
        subplot(1, 2, 1);
        imshow(predicted_frame);
        title("Predicted Frame")
        subplot(1, 2, 2);
        imshow(current_frame);
        title("Current Frame")
    end
    % pause between frames so you can see
    if show_difference || show_frame || show_vectors || show_predicted
        pause(pause_time);
    end
    frame = frame + 1;
    num_estimate = num_estimate + 1;
end

% reporting
fprintf("The average MAD when comparing blocks is %0.5f. \n" + ...
    "The average difference from prediction is %0.5f. \n" + ...
    "The number of operations done per motion estimation is approximately %d. \n", ...
    avg_MAD_over_frames/num_estimate, mean_difference_MAD_over_frames/num_estimate, num_compare);



