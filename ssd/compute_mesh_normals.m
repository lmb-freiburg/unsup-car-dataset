function new_model = compute_mesh_normals(model)

meshdata.vertices = [model.x,model.y,model.z];
meshdata.faces = cell2mat(model.face.vertex_indices)+1;
normals = COMPUTE_mesh_normals(meshdata);

N = size(meshdata.faces,1); %number of faces
for i = 1 : N
    p = meshdata.vertices(meshdata.faces(i,1),:);
    p = p + meshdata.vertices(meshdata.faces(i,2),:);
    p = p + meshdata.vertices(meshdata.faces(i,3),:);
    
    p = p/3;
    
    new_model.x(i,:) = p(1);
    new_model.y(i,:) = p(2);
    new_model.z(i,:) = p(3);
    new_model.nx(i,:) = normals(i,1);
    new_model.ny(i,:) = normals(i,2);
    new_model.nz(i,:) = normals(i,3);

    if(model_has_colors(model))
        c = [model.r(meshdata.faces(i,1)) model.g(meshdata.faces(i,1)) model.b(meshdata.faces(i,1))];
        c = c + [model.r(meshdata.faces(i,2)) model.g(meshdata.faces(i,2)) model.b(meshdata.faces(i,2))];
        c = c + [model.r(meshdata.faces(i,3)) model.g(meshdata.faces(i,3)) model.b(meshdata.faces(i,3))];
        c = c ./ 3;
        
        new_model.r(i,:) = c(1);
        new_model.g(i,:) = c(2);
        new_model.b(i,:) = c(3);
    end    
end
