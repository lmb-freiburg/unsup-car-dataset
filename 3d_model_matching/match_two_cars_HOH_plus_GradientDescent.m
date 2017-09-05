function [needed_rotation,J] = match_two_cars_HOH_plus_GradientDescent(settings,model1,model2)

% Some settings
root_phi_divisions = settings.HOH.root_phi_divisions;
root_theta_divisions = settings.HOH.root_theta_divisions;
nchildren = settings.HOH.nchildren;
child_phi_divisions = settings.HOH.child_phi_divisions;
child_theta_divisions = settings.HOH.child_theta_divisions;


%---- Compute the feature for the reference model
[~,f_ref] = HOH(model1,model_center_of_mass(model1),root_phi_divisions,root_theta_divisions,nchildren,child_phi_divisions,child_theta_divisions,0);

%---- Now quickly sample the search space (possibly without recomputation of
% the features)

J = [];
nsamples = 32;
rotations = [0:nsamples-1] * 360/nsamples;
for R = 0:nsamples-1
    phi = rotations(R+1);
    
    model_t = rotate_3D_model_around_z(model2,phi);
    [~,ft] = HOH(model_t,model_center_of_mass(model_t),root_phi_divisions,root_theta_divisions,nchildren,child_phi_divisions,child_theta_divisions,0);

    
    %-- Compute the distance
    J = [J; HOH_distance(f_ref,ft)];

    fprintf('%.2f ',phi);
end
fprintf('\n');


%---- Pick the k best minima of the samples, and perform gradient descent
%to find the global minimum
[M,im] = min(J);
phi = rotations(im);
alpha = 20;
delta = 5;

dJ_hist = [];
while(1)
    model_t = rotate_3D_model_around_z(model2,phi);
    [~,ft] = HOH(model_t,model_center_of_mass(model_t),root_phi_divisions,root_theta_divisions,nchildren,child_phi_divisions,child_theta_divisions,0);
    J = HOH_distance(f_ref,ft);

    model_t_ = rotate_3D_model_around_z(model2,phi+delta);
    [~,ft_] = HOH(model_t_,model_center_of_mass(model_t_),root_phi_divisions,root_theta_divisions,nchildren,child_phi_divisions,child_theta_divisions,0);
    J_ = HOH_distance(f_ref,ft_);

    dJ = J_ - J;
    phi = phi - alpha*dJ;
    
    dJ_hist(end+1) = dJ;
    
    if(numel(dJ_hist)>5 && nnz(abs(dJ_hist(end-4:end)) <1e-3) == 5)
        break;
    end

    if(numel(dJ_hist) > 500)
        break
    end
end

needed_rotation = phi;