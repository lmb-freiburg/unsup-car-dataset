function [new_model,Ng,inliers] = cut_clutter_out_of_camera_circle(model,cams)

for i = 1 : length(cams)
  P{i} = cams{i}.Position;
  V{i} = cams{i}.HeadingVector;
end

C = mean(cell2mat(P)');

sV = 0;
for i = 1 : length(V)
    for j = i : length(V)
        sV = sV + cross(V{i},V{j});
    end
end

Ng = sV ./ norm(sV);

for i = 1 : length(cams)
    r(i) = norm(P{i} - C');
end


D = [model.x-C(1),model.y-C(2),model.z-C(3)];
NN = repmat(Ng',size(D,1),1);
d = cross(NN,D);
d2 = sum(d.^2,2);

new_model = make_empty_3D_model();
thresh = max(r).^2 * .8;
ind = d2<thresh;

new_model.x = model.x(ind);
new_model.y = model.y(ind);
new_model.z = model.z(ind);
new_model.nx = model.nx(ind);
new_model.ny = model.ny(ind);
new_model.nz = model.nz(ind);
new_model.r = model.r(ind);
new_model.g = model.g(ind);
new_model.b = model.b(ind);

inliers = ind;
