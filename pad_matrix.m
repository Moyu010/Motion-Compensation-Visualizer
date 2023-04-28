function [res] = pad_matrix(matrix,block_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[row, col, channels] = size(matrix);
row_mod = mod(row, block_size);
col_mod = mod(col, block_size);
res = matrix;
if row_mod ~= 0
    res = [res; zeros(block_size-row_mod, col, channels)];
    row = size(res, 1);
end
if col_mod ~= 0
    res = [res, zeros(row, block_size-col_mod, channels)];
end
end

