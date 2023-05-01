clear; clc; close all;
% Load the video sequence
video = VideoReader('source.mp4');
reference_frame = readFrame(video);
reference_frame_gray = im2gray(reference_frame);
block_size = 7;
search_range = 7;
for i = 1:1
    current_frame = readFrame(video);
    current_frame_gray = im2gray(current_frame);
    [motion_vec, avg_MAD, num_compare] = motionEstimationByES(reference_frame_gray, current_frame_gray, block_size, search_range);
    figure(1)
    plot_motion(motion_vec, block_size);
    % image plot
    figure(2);
    subplot(1, 2, 1);
    imshow(reference_frame_gray);
    subplot(1, 2, 2);
    imshow(current_frame_gray);
    pause(0.5);
    figure(3);
    [prediction_difference, mean_difference] = motionCompensation(reference_frame, current_frame, motion_vec, block_size);
    imshow(prediction_difference);
end
