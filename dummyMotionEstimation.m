function [motion_vector, avg_MAD, num_compare] = dummyMotionEstimation(reference, curr, block_size, search_range)
% Computes motion vectors giving zero motion vectors (using original blocks)
%
% Input
%   reference: grayscale matrix as the reference frame
%   curr: grayscale matrix as the current frame
%   block_size: side length for square block size
%   search_range: the range of pixels that this function will search
%
% Ouput
%   motion_vector: matrix containing motion vectors (row, col, 2) (from top left of blocks)
%   avg_MAD: average Mean Absolute Difference cost achieved per block
%   num_compare: the number of block_size^2 compares done (number of MAD computation)
num_compare = 0;
avg_MAD = MAD(reference, curr);
[row, col] = size(curr);
motion_vector = zeros(ceil(row/block_size), ceil(col/block_size), 2);
end

