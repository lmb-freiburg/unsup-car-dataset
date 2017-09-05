function list2 = create_pairs_from_images_list(list,range)

if(size(range) == 1)
    list2 = {};
    for i = 1:length(list)
        for j = 1 : min(range,length(list)-i)
            list2{end+1} = [list{i},' ',list{i+j}];
        end
    end
else %in this case we explicitly have the indices to the pairs
    list2 = {};
    for i = 1:length(range)
        list2{end+1} = [list{range(i,1)},' ',list{range(i,2)}];
    end
end

list2 = list2';