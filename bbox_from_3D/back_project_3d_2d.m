function [A,xp,yp, truncated] = back_project_3d_2d(model,camera,image_size)

xyz = [model.x model.y model.z];

f = camera.FocalLength;
K = [f, 0 0; 0 f 0; 0 0 1];

% here we do the real back-projection
proj = xyz*camera.R';
proj = proj + repmat(camera.T',length(model.x),1);
proj = proj*K';

% extract out the 3 components
xp = proj(:,1);
yp = proj(:,2);
zp = proj(:,3);

% find the principal points
mx = camera.PrincipalPoint(1);
my = camera.PrincipalPoint(2);

xp = xp./zp+mx;
yp = yp./zp+my;

truncated = 0;
if(any(xp < 1)); 
    xp(xp<1)=1;
    truncated = 1;
end;

if(any(yp < 1)); 
    yp(yp<1)=1;
    truncated = 1;
end;

if(any(xp >  image_size(2))); 
    xp(xp> image_size(2)) = image_size(2);
    truncated = 1;
end;

if(any(yp >  image_size(1))); 
    yp(yp> image_size(1)) = image_size(1);
    truncated = 1;
end;


A = zeros(image_size(1),image_size(2));
ind = sub2ind(size(A),round(yp),round(xp));
A(ind) = 1;
