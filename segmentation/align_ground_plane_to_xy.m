function [new_model, rotation_matrix, translation_vector] = align_ground_plane_to_xy(model,cameras)


scene_points = [model.x,model.y,model.z];
scene_normals = [model.nx,model.ny,model.nz];

[P, ~] = find_ground_plane(scene_points',.01);

v1 = P(:,2)-P(:,1);
v2 = P(:,3)-P(:,1);
N = cross(v1,v2);

n = [N(2),-N(1),0]; %this is the unit vector around which we should rotate N
n = n./norm(n);     % so that it is aligned with the z axis

theta = acos(N(3)/norm(N));

n_ = [0 -n(3) n(2); ...
      n(3) 0  -n(1);...
      -n(2) n(1) 0];    % This is the skew symmetric matrix of n
  
rotation_matrix = expm(theta*n_);

new_points = (rotation_matrix * scene_points')';

%--- Adjust the ground plane to lie exactly on the z=0 plane
P2 = (rotation_matrix*P)';
z_ = mean(P2(:,3));
l = size(new_points,1);
new_points = new_points - [zeros(l,2),repmat(z_,l,1)];
translation_vector = [0 ; 0 ; -z_];


if(isempty(cameras)) %then we have to use the old method
    warning('No cameras provided! Using an unreliable method to check for upsidedown scenes');
    up_side_down = (mean(new_points(:,3)) < 0);
else %use camera positions to find the correct side of the ground plane
    cameras = RotateCameras(cameras,rotation_matrix,translation_vector);
    c = cell2mat(cameras);
    p = cell2mat({c.Position})';
    up_side_down = mean(p(:,3)) < 0;
end
if(up_side_down) 
    R2 = [1 0 0 ; 0 -1 0 ; 0 0 -1];
    new_points = (R2 * new_points')';
    rotation_matrix = R2*rotation_matrix;
    translation_vector = R2*translation_vector;
end

%--- And update the normals too
if(~isempty(scene_normals))
    new_normals = scene_normals * rotation_matrix';
else
    new_normals = [];
end

new_model.x = new_points(:,1);
new_model.y = new_points(:,2);
new_model.z = new_points(:,3);
if(~isempty(new_normals))
    new_model.nx = new_normals(:,1);
    new_model.ny = new_normals(:,2);
    new_model.nz = new_normals(:,3);
end
if(model_has_colors(model))
    new_model.r = model.r;
    new_model.g = model.g;
    new_model.b = model.b;
end
if(model_has_faces(model))
    new_model.face = model.face;
end