function [P, inliers] = find_ground_plane(points,tolerance)

[B, P, inliers] = ransacfitplane(points,tolerance);