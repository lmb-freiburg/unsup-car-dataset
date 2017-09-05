function ssd = ssd_the_model(model,cache_file,OctreeLevels)

if(isempty(model))
    error('model is empty!');
end

caching = 0;
if(exist('cache_file','var'))
    if(~isempty(cache_file))
        caching = 1;
    end
end

if(~exist('OctreeLevels','var'))
    OctreeLevels = 5;
end

temp_file = ['temp_for_ssd_' datestr(now,'HHMMSSFFF') num2str(randi(1000)) '.ply'];

if ischar(model) %model file name
    
    if(~exist(model,'file'))
        error('Input file does not exist: %s',model);
    end
    
    % First try to load the cache_file, if it is there, and is up to date
    if(caching && cache_file_is_there_and_newer_than(cache_file,model))
        fprintf(['ssd: loading currently cached file: ',cache_file,'\n']);
        ssd = import_3D_model(cache_file);
        return;
    end
    
    input_filename = model;
    extra_randomization = strrep(input_filename,'/','_');
    extra_randomization = strrep(extra_randomization,'.','_');
    temp_file = [extra_randomization,temp_file];
    
    if(caching)
        temp_file = cache_file;
    end
else %model in memory
    export_3D_model(model,temp_file);
    input_filename = temp_file;
    
    if(caching)
        error('ssd: caching is only possible when the input is a file name!');
        return;
    end
end

cmd = sprintf('ssd_recon -oL %d -c %s %s >/dev/null',OctreeLevels,input_filename,temp_file);
[~,cmd_output] = system(cmd)

try
    ssd = import_3D_model(temp_file);
catch err
        error(['failed importing: ' temp_file]);
end

delete(temp_file);

ssd = compute_mesh_normals(ssd);

%--- Try to remove the "out-skirts"!! of the reconstructed model
if(ischar(model))
    ssd = refine_the_ssd(ssd,import_3D_model(model));
else
    ssd = refine_the_ssd(ssd,model);
end

%--- Caching...
if (ischar(model) && caching)
    fprintf(['ssd: saving cache file: ',cache_file,'\n']);
    export_3D_model(ssd,cache_file);
end
