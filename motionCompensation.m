function [difference, mean_difference] = motionCompensation(reference, curr, motion_vector, block_size)
% Computes the prediction and errors with motion vectors
%
% Input
%   reference: rgb matrix as the reference frame
%   curr: rgb matrix as the current frame
%   motion_vector: motion vector that comes from motion estimation
%   block_size: side length for square block size
%
% Ouput
%
%   TO BE DONE HERE
%   

% pad the reference for ease of matching
reference = pad_matrix(reference, block_size);
predicted_frame = zeros(size(curr));
[img_row, img_col, ~] = size(curr);
for row = 1:block_size:img_row
    for col = 1:block_size:img_col
        displaced_x = row+motion_vector(ceil(row/block_size), ceil(col/block_size), 1);
        displaced_y = col+motion_vector(ceil(row/block_size), ceil(col/block_size), 2);
        predicted_frame(row:row+block_size-1, col:col+block_size-1, :) = ...
            reference(displaced_x:displaced_x+block_size-1, ...
                      displaced_y:displaced_y+block_size-1, :);
    end
end
% assignment in matlab automatically turns matrix into double, so turn back
% to uint8 here
difference = curr - uint8(predicted_frame(1:img_row, 1:img_col, :));
mean_difference = mean2(difference);
end

