function [R,T] = load_segmentation_transformation(filename)

trans = importdata(filename);
R = trans(1:3,1:3);
T = trans(4:end,1); 
