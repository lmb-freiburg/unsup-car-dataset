function [new_model, new_indices] = remove_clutter2(model)

if(isempty(model.x))
    new_model = model;
    new_indices = [];
    return;
end

[x y z] = model_to_components(model);

[A,ax,bx,ay,by,az,bz] = pointcloud_to_voxels_2(x,y,z,200,1);

t = sum(A,3);

foreground_mask = imerode(t,strel('disk',4));

foreground_mask = imdilate(foreground_mask,strel('disk',4));

foreground_mask = im2bw(foreground_mask);

CC = bwconncomp(foreground_mask);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
foreground_mask = zeros(size(foreground_mask));
foreground_mask(CC.PixelIdxList{idx}) = 1;

B = A;
for iz = 1 : size(B,3)
    B(:,:,iz) = B(:,:,iz) .* foreground_mask;
end

X2 = round(ax*(x+bx)+1);
Y2 = round(ay*(y+by)+1);
Z2 = round(az*(z+bz)+1);

i = sub2ind(size(B),X2,Y2,Z2);
new_indices = B(i)>0;

new_model = model_index(model,new_indices);