function [res] = MAD(mat_1,mat_2)
% Computes the minimum absolute value
%
% Input
%   mat_1: first matrix
%   mat_2: second matrix
%
% Ouput
%   res: MAD found

res = (1/numel(mat_1))*sum(abs(mat_1-mat_2), "all");
end

