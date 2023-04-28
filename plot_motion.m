function plot_motion(motion_vector,block_size)
%PLOT_MOTION Summary of this function goes here
%   Detailed explanation goes here
sz = size(motion_vector);
[col, row] = meshgrid(1:sz(2), 1:sz(1));
quiver(col*block_size, row*block_size, motion_vector(:,:,1), motion_vector(:,:,2));
set(gca,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
end

