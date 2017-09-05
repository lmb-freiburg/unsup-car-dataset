function new_cameras = sort_cameras(cameras)
% This function sorts the cameras obtained from the function
% "load_camera_v2" based on the frame file names.

frame_id = [];
for i = 1 : length(cameras)
  [pathstr, name, ext] = fileparts(cameras{i}.ImageFileName);
  frame_id = [frame_id ; {name}]; %the id is actually the name of the file (which we hope contains the right number in it)
end
[frame_id,idx] = sort(frame_id);

new_cameras = cameras(idx);
