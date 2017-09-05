function [new_model, new_indices] = remove_remaining_clutter_ssd_based(model,cameras,R,T)

if(isempty(model.x))
    warning('empty data passed to this function! Aborting...');
    new_points = [];
    new_indices = [];
end

%--- ssd the model
ssd = ssd_the_model(model,'',9);

%--- Find the biggest component in the ssd
[x, y, z] = model_to_components(ssd);
[A,ax,bx,ay,by,az,bz] = pointcloud_to_voxels_2(x,y,z,200,1);

B = A;

%find the estimated object center
C0 = estimate_object_center_based_on_cameras(cameras,model,R,T);
XC = round(ax*(C0(1)+bx)+1);
YC = round(ay*(C0(2)+by)+1);
ZC = round(az*(C0(3)+bz)+1);

% Find the connected components and pick the best one
CC = bwconncomp(B);
if CC.NumObjects
    for i  = 1 : CC.NumObjects
        ind = CC.PixelIdxList{i};
        numPixels(i) = length(ind);
        
        [xx yy zz] = ind2sub(size(B),ind);
        xxm = mean(xx);
        yym = mean(yy);
        zzm = mean(zz);
        d(i) = norm([xxm yym zzm]-[XC YC ZC]);
    end
    
    rank = d./numPixels;
    
    [dummy,idx] = min(rank);
    B = zeros(size(B));
    B(CC.PixelIdxList{idx}) = 1;
else
    B = zeros(size(B));
end

%--- Now generate a new point cloud, by applying this 3D mask to the main
% point cloud
X2 = round(ax*(x+bx)+1);
Y2 = round(ay*(y+by)+1);
Z2 = round(az*(z+bz)+1);

i = sub2ind(size(B),X2,Y2,Z2);
ind = B(i)>0;
new_ssd = model_index(ssd,ind);

%--- Map the ssd back to the main model
[~,D0] = knnsearch([new_ssd.x new_ssd.y new_ssd.z],[model.x model.y model.z]);
new_indices = find(D0 < 5*median(D0));
new_model = sample_model(model, new_indices);
