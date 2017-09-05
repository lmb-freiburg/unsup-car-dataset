function generate_dataset_annotations(models,phi_abs,inliers_list_index,ids,scenes_dir_list,annot_dir)

if(exist(annot_dir,'dir'))
    error('Annotations directory already exists! You probably don''t want to overwrite it');
end

mkdir(annot_dir);

parfor i = 1:length(inliers_list_index)
    fprintf('Generating annotations file #%d \n',ids(inliers_list_index(i)));

    model = models{inliers_list_index(i)};

    base_path = scenes_dir_list{inliers_list_index(i)};
    segment_dir = [base_path,'/refined/'];
    transformation_file_name = [segment_dir,'/transformation_parameters.txt'];
    camera_file = [base_path,'/results.nvm.cmvs/00/cameras_v2.txt'];

    [R,T] = load_segmentation_transformation(transformation_file_name);

    % transform back the model to its original position
    model = transform_3d_rigid(model,R',-R'*T);
    
    cameras = load_camera_v2(camera_file,1);
    [frame_file_names,view_points] = find_frame_file_names_and_viewpoints(cameras,R,T,-phi_abs(i));


    fp = fopen(sprintf('%s/%d_annot.txt',annot_dir,ids(inliers_list_index(i))),'wt');
    for c = 1 : length(cameras) %--- loop on all the frames
        [bbox,trunc] = bbox_from_3d_single_frame(model,cameras{c});
        fprintf(fp,'%s\t%d %d %d %d\t%d\n',frame_file_names{c},bbox.x1,bbox.y1,bbox.x2,bbox.y2,wrapTo360(round(view_points(c))));
    end
    fclose(fp);

end
