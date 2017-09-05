function [p,q] = loop_closure_suggestions(nvm_file,max_distance_percentage,min_index_distance)

Cameras = load_camera_from_nvm(nvm_file,1);

pos = [];
for i = 1 : length(Cameras)
  pos = [pos; Cameras{i}.Position'];
end


% find the distances
[x1,x2] = meshgrid(pos(:,1),pos(:,1));
[y1,y2] = meshgrid(pos(:,2),pos(:,2));
[z1,z2] = meshgrid(pos(:,3),pos(:,3));
d = sqrt( (x1-x2).^2 + (y1-y2).^2 + (z1-z2).^2 );

% pick the appropriate ones
M = max(d(:));
f = find(d < M*max_distance_percentage);
[i,j] = ind2sub(size(d),f);
ind = (abs(i-j) > min_index_distance) & (j > i);
p = i(ind);
q = j(ind);