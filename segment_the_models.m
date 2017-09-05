function [segmented_models, Rotations, Translations, segmented_filenames] = segment_the_models(settings,scenes_dir_list,overwrite)

if(~exist('overwrite','var'))
    overwrite = 0;
end

if(overwrite)
    r = round(rand*10,2);
    a = input(sprintf('WARNING: going to overwrite all the currently existing segmentations. If you are OK with that enter the number %g: ',r));
    if(a ~= r)
        fprintf('Wrong ---> WILL NOT OVERWRITE!\n');
        overwrite = 0;
    end
end

N = length(scenes_dir_list);
segmented_models = cell(N,1);
Rotations = cell(N,1);
Translations = cell(N,1);

parfor i = 1:N
    if(settings.deterministic),rng(1,'twister');end
    
    
    base_path = scenes_dir_list{i};
    
    if(isempty(base_path))
        continue;
    end
    
    %--- setup some file and dir names
    segment_dir = [base_path,'/refined/'];
    segment_file_name_ply = [segment_dir,'/refined.ply'];
    transformation_file_name = [segment_dir,'/transformation_parameters.txt'];
    SceneFileName = [base_path,'/results.0.ply'];
    camera_file = [base_path,'/results.nvm.cmvs/00/cameras_v2.txt'];
   
    %--- Skip if the folder currently exists
    if(~overwrite && exist(segment_dir,'dir'))
        fprintf(['!Skipping. Segmentation destination dir already exists: ' segment_dir '\n']);

        segmented_models{i} = import_3D_model(segment_file_name_ply);
        [Rotations{i}, Translations{i}] = load_segmentation_transformation(transformation_file_name);
        segmented_filenames{i} = segment_file_name_ply;
        
        continue;
    end

    %--- Do the segmentation
    model = import_3D_model(SceneFileName);
        
    cameras = load_camera_v2(camera_file);
    [segmented_models{i},Rotations{i},Translations{i}]  = segment_the_model(model,cameras);
            
        mkdir(segment_dir);
        fprintf('writing: %s\n',segment_file_name_ply);
        export_3D_model(segmented_models{i},segment_file_name_ply);
        myparsave(transformation_file_name,Rotations{i},Translations{i}); %simple save command does not work with parfor
        segmented_filenames{i} = segment_file_name_ply;
end

function myparsave(filename,Rotation,Translation)
save(filename,'Rotation','Translation','-ASCII');