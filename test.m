clear; clc; close all;
% Load the video sequence
convert2gray = @(im) im2double(im2gray(im));
video = VideoReader('source.mp4');
framea = readFrame(video);
frameb = readFrame(video);
framea = convert2gray(framea);
frameb = convert2gray(frameb);
block_size = 16;
search_range = 7;
[motion_vec, avg_MAD, num_compare] = motionEstimationByES(framea, frameb, block_size, search_range);
[x, y] = meshgrid(1:size(motion_vec, 1), 1:size(motion_vec, 2));
x = x';
y = y';
u = motion_vec(:, :, 1);
v = motion_vec(:, :, 2);
quiver(x, y, u, v, 10);

