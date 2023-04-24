function [motion_vector, avg_MAD, num_compare] = motionEstimationByES(reference, curr, block_size, search_range)
% Computes motion vectors using Exhaustive Search
%
% Input
%   reference: double grayscale matrix as the previous frame
%   curr: double grayscale matrix as the current frame
%   block_size: side length for square block size
%   search_range: the range of pixels that this function will search
%
% Ouput
%   motion_vector: matrix containing motion vectors (row, col, 2) (from top left of blocks)
%   avg_MAD: average Mean Absolute Difference cost achieved
%   num_compare: the number of block_size^2 compares done (number of MAD computation)

ref = pad_matrix(reference, block_size);
mat = pad_matrix(curr, block_size);
assert(all(size(ref)==size(mat)), "Size does not match");

[row, col] = size(ref);
MAD_sum = 0;
num_compare = 0;
motion_vector = zeros(row, col, 2);
% looking at the top left coordinate
for r = 1:block_size:row-block_size+1
    for c = 1:block_size:col-block_size+1
        for hor = -search_range:search_range
            for vert = -search_range:search_range
                min_cost = inf;
                search_row = r+hor;
                search_col = c+vert;
                if row-search_row+1 < block_size || search_row <= 0 || ...
                    search_col <= 0 || col-search_col+1 < block_size
                    continue;
                end
                search_row_end = search_row+block_size-1;
                search_col_end = search_col+block_size-1;
                cost = MAD(ref(search_row:search_row_end, search_col:search_col_end), ...
                           mat(search_row:search_row_end, search_col:search_col_end));
                num_compare = num_compare + 1;
                if cost < min_cost
                    min_cost = cost;
                    motion_vector(r, c, 1) = search_row;
                    motion_vector(r, c, 2) = search_col;
                end
            end
        end
        MAD_sum = MAD_sum + min_cost;
    end
end

avg_MAD = MAD_sum/(row/block_size)/(col/block_size);

end