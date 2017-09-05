function ssd = refine_the_ssd(ssd,original_model)

[~,D0] = knnsearch([original_model.x original_model.y original_model.z],[ssd.x ssd.y ssd.z]);
ssd = sample_model(ssd, find(D0 < 5*median(D0)));


