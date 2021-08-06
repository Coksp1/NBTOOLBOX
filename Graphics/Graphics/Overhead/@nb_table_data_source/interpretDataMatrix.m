function dataAsCell = interpretDataMatrix(obj,dataAsCell)

    for ii = 1:size(dataAsCell,1)
        
        for jj = 1:size(dataAsCell,2)
            dataAsCell{ii,jj} = doOne(obj,dataAsCell{ii,jj});
        end
        
    end

end

function element = doOne(obj,element)

    if ischar(element)
        
        if ~isempty(obj.lookUpMatrix)
            element = nb_graph.findVariableName(obj,element);
        end
        if ~isempty(obj.localVariables)
             element = nb_localVariables(obj.localVariables,element);
        end
        element = nb_localFunction(obj,element);
        
    end

end
