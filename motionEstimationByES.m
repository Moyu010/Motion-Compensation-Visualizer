function [motion_vectors, min_MAD] = motionEstimationByES(reference, curr, block_size, search_range)
%MOTIONESTIMATIONBYES Summary of this function goes here
%   Detailed explanation goes here
curr = im2double(im2gray(curr));
block_size = [block_size, block_size];


end