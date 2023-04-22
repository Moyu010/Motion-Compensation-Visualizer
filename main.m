clear; clc; close all;

% Load the video sequence
video = VideoReader('source.mp4');

% The first frame is always read as the reference frame for prediction
current_frame = readFrame(video);

% Initialize the motion compensation parameters
block_size = 8; % decide what to do if cannot fully divide dimensions(zero padding)
search_range = 16;

% Loop through the frames of the video sequence
% while hasFrame(video)
for frame_number = 1:2 % just the first 2 frames
    % Read the current frame
    current_frame = readFrame(video);
    
    % Convert the current frame to grayscale
    current_frame_gray = rgb2gray(current_frame);
    
    % If this is the first frame, initialize the reference frame
    if ~exist('reference_frame', 'var')
        reference_frame = current_frame_gray;
        % Write the reference frame to the encoded video
        writeVideo(encoded_video, reference_frame);
        continue;
    end
    
    % Compute the motion vectors using block matching
    motion_vectors = motionEstimation(reference_frame, current_frame_gray, block_size, search_range);
    
    % Apply motion compensation to the current frame
    compensated_frame = motionCompensation(reference_frame, motion_vectors, block_size);
    
    % Compute the difference between the compensated frame and the current frame
    difference_frame = current_frame_gray - compensated_frame;
    
    % Write the difference frame to the encoded video
    writeVideo(encoded_video, difference_frame);
    
    % Set the compensated frame as the new reference frame
    reference_frame = compensated_frame;
end

% Close the encoded video writer
close(encoded_video);