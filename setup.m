%---- Setup the paths
addpath('nply/');
addpath('general_tools/');
addpath('3D_reconst/');
addpath('segmentation/');
addpath('ssd/');
addpath('HOH/');
addpath('3d_model_matching/');
addpath('bbox_from_3D/');

addpath('extern/ransac/');
addpath('extern/COMPUTE_mesh_normals/COMPUTE_mesh_normals/');

%----
videos_list_file = 'videos_list.txt';
reconstructions_destination = 'temp_reconstructions_cars/r120_3_5/car%03d';
reconstructions_on_cluster = 0;
annot_dir = './temp_annotations';

%-- HOH parameters
settings.HOH.root_phi_divisions = 32;
settings.HOH.root_theta_divisions = 8;
settings.HOH.nchildren = 8;
settings.HOH.child_phi_divisions = 16;
settings.HOH.child_theta_divisions = 4;

%-- A manually defined phi value to be dedeucted from the floating phi 
% values (i.e. define the ground 0 viewpoint)
manual_rotation = 0;

%-- Try to generate deterministic (reproducible) results. 
% Note that there are other random-ness sources in the process, which 
% should be taken care of, to get exact same results in multuple 
% runs -- more specifically the ones in the VSFM package. 
settings.deterministic = 1;