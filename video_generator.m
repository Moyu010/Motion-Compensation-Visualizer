%% Single frame investigation
% You can wrap this section in loops to plot effects of different
% strategies, block size etc.
clear; clc; close all;
% Load the video sequence
video = VideoReader('source.avi');
prediction_writer = VideoWriter(pwd+"\video\prediction_out.avi");
original_writer = VideoWriter(pwd+"\video\original_out.avi");
% Basic parameters
block_size = 16;
search_range = 7;
duration_of_vid = 10;
num_of_frames = video.FrameRate*duration_of_vid;

open(prediction_writer);
open(original_writer);
% Acting loop
frame = 1;

% read first frame
reference_frame = im2double(readFrame(video));
reference_frame_gray = im2gray(reference_frame);
frame = frame + 1; % operate on the current frame 2
while frame < num_of_frames % adjust how many frames this will be done on
    % read the frame
    current_frame = im2double(readFrame(video));
    current_frame_gray = im2gray(current_frame);
    % compute the motion vectors, change the method used here
    [motion_vec, ~, ~] = motionEstimationByNTSS(reference_frame_gray, current_frame_gray, block_size, search_range);
    % compensate and find prediction error
    [predicted_frame, ~, ~] = motionCompensation(reference_frame, current_frame, motion_vec, block_size);
    writeVideo(original_writer, current_frame);
    writeVideo(prediction_writer, predicted_frame);
    reference_frame = current_frame;
    reference_frame_gray = current_frame_gray;
    frame = frame + 1;
end
close(prediction_writer);
close(original_writer);