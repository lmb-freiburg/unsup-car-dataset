clear;
clc;

%--------------------------------------------------------------------------
%--- Settings
%--------------------------------------------------------------------------
setup;
if(settings.deterministic),rng(1); end

%--------------------------------------------------------------------------
%--- Reconstruct the 3D models from videos
%--------------------------------------------------------------------------
fprintf('Reconstructing 3D models from videos...\n');
[scenes_dir_list,ids] = reconstruct_videos(videos_list_file,...
    reconstructions_destination,[120 3 5],reconstructions_on_cluster);
fprintf('Done\n');
N = numel(scenes_dir_list);

%--------------------------------------------------------------------------
%--- Segment out the cars
%--------------------------------------------------------------------------
fprintf('Performing segmentation on the reconstructed scenes...\n');
[models, Rotations, Translations, segmented_files] = ...
    segment_the_models(settings,scenes_dir_list,0);
segmented_files = segmented_files';
fprintf('Done\n');

%--------------------------------------------------------------------------
%--- Throw away empty models resulting from segmentation
%--------------------------------------------------------------------------
empties = find(cellfun(@(m)(isempty(m.x)),models));

scenes_dir_list(empties) = [];
segmented_files(empties) = [];
models(empties) = [];
ids(empties) = [];
N = numel(models);


%--------------------------------------------------------------------------
%--- Do pairwise matching
%--------------------------------------------------------------------------

% pre-create the ssd of the models
parfor i = 1 : N
    ssd{i} = ssd_the_model(segmented_files{i},...
        generate_ssd_file_name_for_model(segmented_files{i},5),5);
end

[I,J] = meshgrid(1:N,1:N);
whole_timer = tic;
matching = zeros(N);
matching_cost = zeros(N);
timing = zeros(N);
parfor ind = 1 : N*N
    i = I(ind);
    j = J(ind);
    
    model1 = models{i};
    fprintf('matching %02dx%02d ...',i,j)
        
    model2 = models{j};
    
    local_timer = tic;
    [matching(ind), matching_cost(ind)] = ...
        match_two_cars_HOH_plus_GradientDescent(settings,ssd{i},ssd{j});
    timing(ind) = toc(local_timer);
end

matching = matching';
timing = timing'; 

toc(whole_timer)
save main_last

%% 
clear;load main_last


%%-------------------------------------------------------------------------
% Find each model's pose, by optimizing the cost function
%--------------------------------------------------------------------------
new_matching = matching;
inliers1 = 1 : size(matching,1);

fprintf('Optimizing the estimated viewpoints...\n');
[phi,J,niter,s1,s2] = optimize_viewpoints(new_matching*pi/180,1e-10);
phi = phi * 180/pi;
ss = s1' + s2;
fprintf('Done:\n');
disp(J);


outliers2 = find(ss >= 2.5);
fprintf('outlier ids: %d \n',ids(inliers1(outliers2)));
inliers2 = 1:numel(inliers1);
inliers2(outliers2) = []

figure;
visualize_all_aligned_models(ssd,ids,inliers1,phi,ss);

pause

fprintf('Re-optimizing the estimated viewpoints...\n');
new_matching2 = new_matching(:,inliers2);
new_matching2 = new_matching2(inliers2,:);
[phi,J,niter,s1_,s2_] = optimize_viewpoints(new_matching2*pi/180,1e-10);
phi = phi * 180/pi;
fprintf('Done:\n');
disp(J);

inliers_list_index = inliers1(inliers2);

%%-------------------------------------------------------------------------
% Deduct a manually defined phi value from the view-points 
% = define the ground 0 viewpoint
%--------------------------------------------------------------------------
phi_abs = phi - manual_rotation;
figure;visualize_all_aligned_models(ssd,ids,inliers_list_index,phi_abs,ss);

%%-------------------------------------------------------------------------
% Generate the dataset annotations and save them
%--------------------------------------------------------------------------
generate_dataset_annotations(models,phi_abs,inliers_list_index,ids,...
    scenes_dir_list,annot_dir);
