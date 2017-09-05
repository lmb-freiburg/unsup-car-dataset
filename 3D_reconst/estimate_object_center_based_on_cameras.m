function C0 = estimate_object_center_based_on_cameras(cameras,model,Rot,Trans)

for i = 1 : length(cameras)
  C = cameras{i}.Position;
  C = Rot*C+Trans;
  P{i} = C;
  
  h = cameras{i}.HeadingVector;
  h = Rot*h;
  H{i} = h;
end

XX = find_intersections_of_a_set_of_lines_IGNORE_Z(P,H);

% try to remove the too distant instances (outliers)
X = cell2mat(XX);
X = X';
Xm = mean(X);

d = X - repmat(Xm,size(X,1),1);
d = abs(d);

md = mean(d);
md = mean(md);

f = (d(:,1) > 3*md) | (d(:,2) > 3*md);
f = find(f);

XX(f) = [];

% find the mean of all intersection points
X = cell2mat(XX);
X = X';
C0 = mean(X)';

%--- And finally we estimate the z element, based on the model points
C0(3) = mean(model.z);