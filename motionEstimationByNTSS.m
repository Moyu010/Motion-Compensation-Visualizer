function [motion_vector, avg_MAD, num_compare] = motionEstimationByNTSS(reference, curr, block_size, search_range)
% Computes motion vectors using New Three Step Search
% Essentially, it introduces more checks for local, small movements
%
% Input
%   reference: grayscale matrix as the reference frame
%   curr: grayscale matrix as the current frame
%   block_size: side length for square block size
%   search_range: redundant parameter, for integration with other
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
        % compared to TSS, NTSS introduces checking immediate neighbours
        % and early stopping. (So 17 points checked in first step compared to 8)
        for step_size = [1, 4]
            for hor = [0, -step_size, step_size]
                for vert = [0, -step_size, step_size]
                    search_row = centre_row+hor;
                    search_col = centre_col+vert;
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
                    % update accordingly
                    if cost < min_cost
                        min_cost = cost;
                        motion_vector(ceil(r/block_size), ceil(c/block_size), 1) = search_row-r;
                        motion_vector(ceil(r/block_size), ceil(c/block_size), 2) = search_col-c;
                    end
                end
            end
        end
        MAD_sum = MAD_sum + min_cost;
        % Update centre to minimum
        centre_row = r+motion_vector(ceil(r/block_size), ceil(c/block_size), 1);
        centre_col = c+motion_vector(ceil(r/block_size), ceil(c/block_size), 2);
        % Early stopping if the centre (r, c) happen to be the minimum
        if centre_row == r && centre_col == c
            continue;
        end
        % If the minimum is found in immediate neighbour
        if abs(centre_row-r) == 1 || abs(centre_col-c) == 1
            % check the immediate neighbours of the neighbour and exit
            for hor = [0, -1, 1]
                for vert = [0, -1, 1]
                    search_row = centre_row+hor;
                    search_col = centre_col+vert;
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
                    % update accordingly
                    if cost < min_cost
                        min_cost = cost;
                        motion_vector(ceil(r/block_size), ceil(c/block_size), 1) = search_row-r;
                        motion_vector(ceil(r/block_size), ceil(c/block_size), 2) = search_col-c;
                    end
                end
            end
            MAD_sum = MAD_sum + min_cost;
            % early stop
            continue;
        else
            % Otherwise, continue with normal TSS (with step size 4 checked already)
            for step_size = [2, 1]
                for hor = [0, -step_size, step_size]
                    for vert = [0, -step_size, step_size]
                        search_row = centre_row+hor;
                        search_col = centre_col+vert;
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
                        % update accordingly
                        if cost < min_cost
                            min_cost = cost;
                            motion_vector(ceil(r/block_size), ceil(c/block_size), 1) = search_row-r;
                            motion_vector(ceil(r/block_size), ceil(c/block_size), 2) = search_col-c;
                        end
                    end
                end
                % update the centre to the new minimum
                centre_row = r+motion_vector(ceil(r/block_size), ceil(c/block_size), 1);
                centre_col = c+motion_vector(ceil(r/block_size), ceil(c/block_size), 2);
            end
        end
        MAD_sum = MAD_sum + min_cost;
    end
end

avg_MAD = MAD_sum/ceil(row/block_size)/ceil(col/block_size);

end