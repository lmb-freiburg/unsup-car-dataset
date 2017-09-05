function dist = HOH_distance(f1,f2)

if(~iscell(f1) && ~isstruct(f1)) %single_vector fast comparison
    fm1 = f1;
    fm2 = f2;
else
    
    if(~isfield(f1,'main')) %Then it is in the old-style.
        f = f1;
        f1.main = f(1);
        f1.child = f(2:end);
    end
    
    if(~isfield(f2,'main')) %Then it is in the old-style.
        f = f2;
        f2.main = f(1);
        f2.child = f(2:end);
    end
    
    if(~isempty(f1.child))
        fc1 = cell2mat(f1.child(:));
        fm1 = [f1.main{1}(:); fc1(:)];
    else
        fm1 = [f1.main{1}(:)];
    end
    
    if(~isempty(f2.child))
        fc2 = cell2mat(f2.child(:));
        fm2 = [f2.main{1}(:); fc2(:)];
    else
        fm2 = [f2.main{1}(:)];
    end
    
end

%-- Chi-squared distance
dist = sum( (fm1(:) - fm2(:)).^2 ./ (fm1(:) + fm2(:) + 1e-20) ); 
dist = dist ./ length(fm1);