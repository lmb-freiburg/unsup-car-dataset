function [f,f_better_structure,f_single_vector] = HOH(model,model_center,n_phi0,n_theta0,nChilds,n_phi,...
    n_theta,do_gridding,do_normalize_each_item,do_normalize_hier,min_points_per_child)

if(~exist('do_normalize_each_item','var'))
    do_normalize_each_item = 1;
end

if(~exist('do_normalize_hier','var'))
    do_normalize_hier = 0;
end

if(~exist('min_points_per_child','var'))
    min_points_per_child = 0;
end


%--- Obtian the root feature
f{1} = EGI(model,n_phi0,n_theta0,do_normalize_each_item);
f_single_vector = f{1}(:);

%--- do the slicing and obtain the features
[x,y,z,nx,ny,nz] = model_to_components(model);

if(isempty(model_center))
    
    error('Object centroid missing -- not computed inside this function any more');
    
    % Find the center of the containing box.
    xc = mean(minmax(x'));
    yc = mean(minmax(y'));
    zc = mean(minmax(z'));
else
    xc = model_center(1);
    yc = model_center(2);
    zc = model_center(3);
end
    
x = x-xc;
y = y-yc;
z = z-zc;

phi = atan2(y,x);
phi = wrapTo2Pi(phi);
phi_ = ceil(phi/(2*pi/nChilds)); % Discretization
phi_(phi_ == 0) = 1; % This is to put all the numbers in [1,n]. 

for i = 1 : nChilds
    ind = find(phi_ == i);

    f{i+1} = EGI(components_to_model(x(ind),y(ind),z(ind),nx(ind),ny(ind),nz(ind)),n_phi,n_theta,do_normalize_each_item,min_points_per_child);
    f{i+1} = 1 * f{i+1}; 
    f_single_vector = cat(1,f_single_vector,f{i+1}(:));
end


f_better_structure.main = f(1);
f_better_structure.child = f(2:end);