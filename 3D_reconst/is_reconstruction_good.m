function instability = is_reconstruction_good(cameras_file_name)

[Cameras, nCameras] = load_camera_v2(cameras_file_name,1);

pos = [];
for i = 1 : length(Cameras)
  pos = [pos; Cameras{i}.Position'];
end


%--- Obtain a reliability measure
v = -diff(pos);

l = size(v,1);
z = zeros(l,1);
d = sum(v'.^2)'; %a measure of the step sizes through the video

instability = (max(d)-median(d))/mean(d);
