%% Single frame investigation
% You can wrap this section in loops to plot effects of different
% strategies, block size etc.
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
    if sum(frame, 'all') > 1e6
        writeVideo(writer, frame);
    end
end
close(writer)