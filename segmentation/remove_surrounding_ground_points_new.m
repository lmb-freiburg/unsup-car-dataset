function [new_model, new_indices] = remove_surrounding_ground_points_new(model,th)

ground_points = (model.z < th | ( abs(model.nz) > 0.5 & model.z < th) );
new_indices = ~(ground_points);

new_model = model_index(model,new_indices);