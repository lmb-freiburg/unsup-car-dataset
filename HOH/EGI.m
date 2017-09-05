function [f] = EGI(model,n_phi,n_theta,normalize,min_points)

if(~exist('min_points','var'))
    min_points = 0;
end

% suppress models with too few points
if isempty(model.x) || numel(model.x) < min_points
    f = zeros(n_theta,n_phi);
    return;
end

[x,y,z,nx,ny,nz] = model_to_components(model);

phi = atan2(ny,nx);
phi = phi + pi; %now phi is in [0,2pi]
phi_ = ceil(phi/(2*pi/n_phi)); % Discretization
phi_(phi_ == 0) = 1; % This is to put all the numbers in [1,n]. 

theta = atan(nz./(sqrt(nx.^2+ny.^2)));
theta = theta + pi/2; %now theta is in [0,pi]
theta_ = ceil(theta/(pi/n_theta)); % Discretization
theta_(theta_ == 0) = 1;% This is to put all the numbers in [1,n]. 

%--- Do the binning
f = zeros(n_theta,n_phi);
for i = 1 : n_phi
    p_ = (phi_ == i);
    for j = 1 : n_theta
        f(j,i) = sum( p_ & (theta_ == j) );
    end
end

%--- Do the cell weighting
mid_angle = (pi/n_theta)*( (1:n_theta)-0.5 );
w = abs(sin(mid_angle));
w2d = meshgrid(w,1:n_phi)';
f = f .* w2d;

%--- Do smoothing (circular in phi, simple in Theta direction)
if(1)
    %smoothing kernel
    krn = fspecial('gaussian',[3 3], 0.7);
    
    %do some padding
    f = [f(:,end) f f(:,1)];
    f = [f(1,:) ; f ; f(end,:)];
    
    %apply the kernel
    f = conv2(f,krn,'same');
    
    %undo the padding
    f = f(2:end-1,2:end-1);
end

%--- Do normalization
switch(normalize)
    case 1
        f = f ./ sum(f(:));
    case 2
        f = f ./ max(f(:));
end
