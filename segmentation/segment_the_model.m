function [new_model,Rotation,Translation,inliers] = segment_the_model(model,cameras)

Rotation = eye(3);
Translation = [0;0;0];

%--- Mean normalize the loaded coordinates
Translation = [-mean(model.x) ; -mean(model.y) ; -mean(model.z)];
model = transform_3d_rigid(model,Rotation,Translation);
cameras = RotateCameras(cameras,Rotation,Translation);

    

%----------------------------------
% Align the ground plane 
% to the x-y plane
%----------------------------------
[model, R, T] = align_ground_plane_to_xy(model,cameras);
cameras = RotateCameras(cameras,R,T);
inliers = [1:length(model.x)];

Rotation = R*Rotation;
Translation = R*Translation+T;

%----------------------------------
% Normalize out the rotation around
% z axis (for multiple runs)
%----------------------------------
p = cameras{1}.Position;
phi = -atan2d(p(2),p(1));
R = [cosd(phi) -sind(phi) 0 ; sind(phi) cosd(phi) 0 ; 0 0 1];
T = [0;0;0];
model  = transform_3d_rigid(model,R,T);
cameras = RotateCameras(cameras,R,T);

Rotation = R*Rotation;
Translation = R*Translation+T;

%-------------------------------------------------------------
% Try to use the camera positions to obtain the 
% region of attention, and cut the rest out
%-------------------------------------------------------------
[model,Ng,ind] = cut_clutter_out_of_camera_circle(model,cameras);
inliers = inliers(ind);

%-------------------------------------------
% Remove the culutter in the background
%-------------------------------------------
[model,ind] = remove_clutter2(model);
inliers = inliers(ind);

%-------------------------------------------
% Remove the ground points (dumb, hacky version)
%-------------------------------------------
[model,ind] = remove_surrounding_ground_points_new(model,.3);
inliers = inliers(ind);

%-------------------------------------------
% Remove the clutter again!
%-------------------------------------------
if(~isempty(model.x))
    [model,ind] = remove_remaining_clutter_ssd_based(model,cameras,Rotation,Translation);
    inliers = inliers(ind);
else
    model = make_empty_3D_model();
    inliers = [];
end

%-------------------------------------------
% And put the model into the center of the
% scene -- and on the ground!
%-------------------------------------------
if(~isempty(model.x)) %if the model is already empty = we have lost all the points
    T = [-mean(model.x) ; -mean(model.y) ; -min(model.z)]; 
    model = transform_3d_rigid(model,eye(3),T);
    cameras = RotateCameras(cameras,eye(3),T);
    Translation = Translation + T;
end

new_model = model;