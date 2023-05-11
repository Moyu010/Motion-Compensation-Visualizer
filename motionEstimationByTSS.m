function [motion_vector, avg_MAD, num_compare] = motionEstimationByTSS(reference, curr, block_size, search_range)
% Computes motion vectors using Three Step Search
%
% Input
%   reference: grayscale matrix as the reference frame
%   curr: grayscale matrix as the current frame
%   block_size: side length for square block size
%   search_range: the range which the algorithm will search in, calculated
%                 [4, 2, 1] in 7 range, or [8, 4, 2, 1] in 15 range (only 2^n-1 allowed)
%   estimation only. Step size for search is fixed at 4
%
% Ouput
%   motion_vector: matrix containing motion vectors (row, col, 2) (from top left of blocks)
%   avg_MAD: average Mean Absolute Difference cost achieved per block
%   num_compare: the number of block_size^2 compares done (number of MAD computation)

reference = pad_matrix(reference, block_size);

[row, col] = size(curr);
MAD_sum = 0;
num_compare = 0;
% top left coordinates of blockified frame
motion_vector = zeros(ceil(row/block_size), ceil(col/block_size), 2);
% looking at the top left coordinate, up till the bottom right block
for r = 1:block_size:row-block_size+1
    for c = 1:block_size:col-block_size+1
        min_cost = inf;
        % define the ranges for a block in the current frame we are
        % interested
        % e.g. (r, c) = (1, 1), range = (1~16, 1~16)
        current_row_end = r+block_size-1;
        current_col_end = c+block_size-1;
        % defined for computing which central row is the next step on
        centre_row = r;
        centre_col = c;
        for step_size = 2.^[ceil(log2(search_range+1)-1:-1:0)]
            for hor = [0, -step_size, step_size]
                for vert = [0, -step_size, step_size]
                    search_row = centre_row+hor;
                    search_col = centre_col+vert;
                    str_rep = string(search_row)+","+string(search_col);
                    if isKey(position_dict, str_rep)
                        % have checked already
                        continue;
                    else
                        % only search in image
                        if row-search_row+1 < block_size || search_row <= 0 || ...
                            search_col <= 0 || col-search_col+1 < block_size
                            continue;
                        end
                        % defind ranges for search in reference
                        search_row_end = search_row+block_size-1;
                        search_col_end = search_col+block_size-1;
                        % find the diff between search and current block
                        % remember that current block is fixed, we search for a
                        % close match in the reference
                        cost = MAD(curr(r:current_row_end, c:current_col_end), ...
                                   reference(search_row:search_row_end, search_col:search_col_end));
                        % increment compare number --> for plotting cost
                        num_compare = num_compare + 1;
                        position_dict(str_rep) = cost;
                        % update accordingly
                        if cost < min_cost
                            min_cost = cost;
                            motion_vector(ceil(r/block_size), ceil(c/block_size), 1) = search_row-r;
                            motion_vector(ceil(r/block_size), ceil(c/block_size), 2) = search_col-c;
                        end
                    end
                end
            end
            % update the centre to the new minimum
            centre_row = r+motion_vector(ceil(r/block_size), ceil(c/block_size), 1);
            centre_col = c+motion_vector(ceil(r/block_size), ceil(c/block_size), 2);
        end
        MAD_sum = MAD_sum + min_cost;
    end
end

avg_MAD = MAD_sum/ceil(row/block_size)/ceil(col/block_size);

end