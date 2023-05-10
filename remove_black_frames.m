%% Single frame investigation
clear; clc; close all;
% Load the video sequence
video = VideoReader('source.mp4');
writer = VideoWriter('out');
max_frame = 500;
open(writer)
f = 1;
while hasFrame(video) && f< max_frame
    f = f+1;
    frame = readFrame(video);
    % black frames cause infinite PSNR, affecting plots and averaging
    if sum(frame, 'all') > 1e6
        writeVideo(writer, frame);
    end
end
close(writer)