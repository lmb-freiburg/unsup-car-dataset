function [scenes_dir_list,ids] = reconstruct_videos(videos_list_files,reconstructions_destination,reconst_params,on_cluster)

if(~exist('reconst_params','var')), 
    reconst_params = [inf 3 5];
end;

if(~exist('on_cluster','var'))
    on_cluster = 0; 
end;

%--- Load the video list
fid = fopen(videos_list_files,'rt');
list = textscan(fid,'%s\n');
list = list{1};
fclose(fid);

%--- Reconstruct them all
nFrames = reconst_params(1);
ranges = reconst_params(2:3);
wait_files = {};
for i = 1 : numel(list)
    destination_dir = sprintf(reconstructions_destination,i);
    scenes_dir_list{i,:} = destination_dir;
    ids(i) = i;

    %--- Skip if the folder currently exists
    if(exist(destination_dir,'dir'))
        fprintf(['!Skipping. Reconstruction destination dir already contains nvm files: ' destination_dir '\n']);
        continue;
    end
    

    %--- Do the real reconstruction (on cluster or locally)
    if(on_cluster)
        wait_files{i} = cluster_submit_job(); % You should implement this function based on your own cluster manager's settings.
        fprintf('Job #%d submitted.\n',i);
    else
        tic
        reconstruct_single_video(list{i},destination_dir,nFrames,ranges);
        fprintf('\n\nsingle video reconstruction took %d seconds\n\n',toc);
    end
    
end

if(on_cluster)
    tic
    fprintf('Waiting for jobs to complete...\n');
    wait_for_files(wait_files);
    fprintf('Done. All reconstructions together took %d seconds\n\n',toc);
end