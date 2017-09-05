function [A,x,y] = refine_bw_img_for_bbox(A)

A = imclose(A,strel('disk',4));
A = imerode(A,strel('diamond',2));
[y,x] = ind2sub(size(A),find(A));