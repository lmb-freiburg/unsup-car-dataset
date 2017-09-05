function [bbox, truncated] = bbox_from_3d_single_frame(model,camera)

try
    frame_size = size(imread(camera.ImageFileName));
catch
    error('failed to read the image');
end

[A,xp,yp, truncated] = back_project_3d_2d(model,camera,frame_size);
[A] = refine_bw_img_for_bbox(A);

[yy,xx] = ind2sub(size(A),find(A));
bbox.x1 = min(xx);
bbox.y1 = min(yy);
bbox.x2 = max(xx);
bbox.y2 = max(yy);

if(bbox.x1 < 1); 
    bbox.x1 = 1; 
    truncated = 1;
end;

if(bbox.y1 < 1); 
    bbox.y1 = 1; 
    truncated = 1;
end;

if(bbox.x2 > frame_size(2)); 
    bbox.x2 = frame_size(2); 
    truncated = 1;
end;

if(bbox.y2 > frame_size(1)); 
    bbox.y2 = frame_size(1); 
    truncated = 1;
end;

bbox.w = bbox.x2 - bbox.x1 + 1;
bbox.h = bbox.y2 - bbox.y1 + 1;

