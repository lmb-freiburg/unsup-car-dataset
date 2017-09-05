function [voxel_model,ax,bx,ay,by,az,bz] = pointcloud_to_voxels_2(X,Y,Z,N,keep_aspect_ratio)

if(~exist('keep_aspect_ratio','var'))
    keep_aspect_ratio = 0;
end

if(isempty(X))
    warning('warning(pointcloud_to_voxels_2): empty data passed to this function! Aborting...');
    voxel_model = [];
    ax = [];
    bx = [];
    ay = [];
    by = [];
    az = [];
    bz = [];
end

if(keep_aspect_ratio)
    maxmax = max([max(X)-min(X),max(Y)-min(Y),max(Z)-min(Z)]);

    N1 = round(N*(max(X)-min(X))/maxmax);
    N2 = round(N*(max(Y)-min(Y))/maxmax);
    N3 = round(N*(max(Z)-min(Z))/maxmax);
    voxel_model = zeros(N1,N2,N3);

    ax = 1/(max(X)-min(X))*(N1-1);
    bx = -min(X);
    ay = 1/(max(Y)-min(Y))*(N2-1);
    by = -min(Y);
    az = 1/(max(Z)-min(Z))*(N3-1);
    bz = -min(Z);
else
    voxel_model = zeros(N,N,N);

    ax = 1/(max(X)-min(X))*(N-1);
    bx = -min(X);
    ay = 1/(max(Y)-min(Y))*(N-1);
    by = -min(Y);
    az = 1/(max(Z)-min(Z))*(N-1);
    bz = -min(Z);
end    

X2 = round(ax*(X+bx))+1;
Y2 = round(ay*(Y+by))+1;
Z2 = round(az*(Z+bz))+1;

voxel_model(sub2ind(size(voxel_model),X2,Y2,Z2)) = 1;
