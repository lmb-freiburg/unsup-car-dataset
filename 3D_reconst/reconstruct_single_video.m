function reconstruct_single_video(video_dir,destination_dir,nFrames,ranges)

if(~exist('nFrames','var'))
    nFrames = 0; %to use all the existing frames
end

if(~exist('ranges','var'))
    ranges = [3 5];
end

%-- Check for currently existing stuff in the folder
d = dir(fullfile(destination_dir,'*.nvm'));
if(size(d,1))
    fprintf(['!Skipping. Reconstruction destination dir already contains nvm files: ' destination_dir '\n']);
    return;
end

%-- Create the destination dir
mkdir(destination_dir);

%-- Load the basic list (containing absolute file names)
list_file = [video_dir '/list_absolute.txt'];
if(~exist(list_file,'file'))
    system(sprintf('find %s -iname ''*ppm'' | sort > %s',video_dir,list_file));
end
fp = fopen(list_file,'rt');
list = textscan(fp,'%s\n');
list = list{1};
fclose(fp);

%-- Do down-sampling in time, if necessary
if(nFrames > 0)
    nFrames = min(nFrames,length(list)); %In the cases where there are not enough frames, we just use all of them
    
    %ind = ceil(linspace(1,length(list),nFrames));
    ind = 1:floor(length(list)/nFrames):length(list);
    list = list(ind);
end
ds_listfile = [destination_dir '/list_downsampled.txt'];
fp = fopen(ds_listfile,'wt');
fprintf(fp,'%s\n',list{:});
fclose(fp);

%-- In a loop, try to suggest a pair of frames for initialization (hacky)
counter = 0;
while(1)
    %-- create the Initialization list (for manual initialization pair
    %specification)
    init_list_file = [destination_dir '/init.txt'];
    fp = fopen(init_list_file,'wt');
    fprintf(fp,'%s %s',list{1},list{5+counter});
    fclose(fp);
    
    %-- Run sfm initialization (just a hack to force it use our own
    %initial pair)
    init_nvm_file = [destination_dir '/init.nvm'];
    cmd = ['VisualSFM sfm ' init_list_file ' ' init_nvm_file];
    fprintf('\n\nCUSTOM LOG - Running this command:\n %s \n\n',cmd);
    [~,cmdout] = system(cmd)
    
    %Check if it has been successful to do the initialization or not
    if(isempty(strfind(cmdout,'Failed to initialize with the chosen pair')))
        break;
    end
    
    counter = counter + 1;
    if(counter == 10)
        break;
    end
end

if(counter == 10)
    warning('Failed to initialize sfm for this item.');
    return;
end

%-- Create the manual list for pair matching of frames
range1 = ranges(1);
list1 = create_pairs_from_images_list(list,range1);

pairs_list_file = [destination_dir '/pairs_list.txt'];
fp = fopen(pairs_list_file,'wt');
fprintf(fp,'%s\n',list1{:});
fclose(fp);

%--- Do the actual sfm by resuming the init phase
results_nvm_file1 = [destination_dir '/results1.nvm'];
cmd = ['VisualSFM sfm+pairs ' ds_listfile ' ' results_nvm_file1 ' ' pairs_list_file ' +resume ' init_nvm_file ' +sort'];
fprintf('\n\nCUSTOM LOG - Running this command:\n %s \n\n',cmd);
system(cmd);

%--- Try to find suggestions for the loop closure
[p,q] = loop_closure_suggestions([destination_dir '/results1.nvm'],0.05,5);

%--- Create a new list, including the loop closure pairs, in addition to
% more regular pairs (higher range)
range2 = ranges(2);
list2 = create_pairs_from_images_list(list,range2);
list_closure = create_pairs_from_images_list(list,[p,q]);
list2 = cat(1,list2,list_closure);

pairs_list_file2 = [destination_dir '/pairs_list2.txt'];
fp = fopen(pairs_list_file2,'wt');
fprintf(fp,'%s\n',list2{:});
fclose(fp);

%--- Do the actual sfm by resuming the init phase (for the second time)
results_nvm_file = [destination_dir '/results.nvm'];
cmd = ['VisualSFM sfm+pmvs+pairs ' ds_listfile ' ' results_nvm_file ' ' pairs_list_file2 ' +resume ' init_nvm_file ' +sort'];
fprintf('\n\nCUSTOM LOG - Running this command:\n %s \n\n',cmd);
system(cmd);
