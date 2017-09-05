function visualize_all_aligned_models(ssd,ids,list,phi,e)

n = length(list);
for i = 1 : n
    model = ssd{list(i)};
    model = rotate_3D_model_around_z(model,-phi(i));
    
    subplot(4,ceil(n/4),i);
    visualize_model_and_normals(model);
    title(sprintf('%d(%d) -> e = %.2f',i,ids(list(i)),e(i)));
    axis tight
    axis equal
    view(2);
end
