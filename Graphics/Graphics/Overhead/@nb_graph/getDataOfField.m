function getDataOfField(obj)
% Syntax:
% 
% getDataOfField(obj)
%
% See also: 
% nb_graph_ts.graphInfoStruct, nb_graph_data.graphInfoStruct
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    expression          = obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1};
    notFound            = ~ismember(expression,obj.DB.variables);
    obj.variablesToPlot = {};
    if notFound
        try
            if nb_contains(expression,'[')
                expression = strrep(expression,'[','');
                expression = strrep(expression,']','');
                splitted   = regexp(expression,'[,\s]','split');
                ind        = cellfun(@(x)isempty(x),splitted);
                splitted   = splitted(~ind);
                dataToG    = nan(obj.endGraph - obj.startGraph + 1,length(splitted));
                for vv = 1:length(splitted)
                    if ismember(splitted{vv},obj.DB.variables)
                        dataToG(:,vv) = getVariable(obj.DB,splitted{vv},obj.startGraph,obj.endGraph);
                    else
                        data          = obj.DB.createVariable(splitted{vv},splitted{vv},obj.parameters);
                        dataToG(:,vv) = getVariable(data,splitted{vv},obj.startGraph,obj.endGraph);
                    end
                end
            else
                data = obj.DB.createVariable(expression,expression,obj.parameters);
                if isa(obj,'nb_graph_bd')
                    dataToG = getVariable(data,obj.dataType,expression,obj.startGraph,obj.endGraph);
                else
                    dataToG = getVariable(data,expression,obj.startGraph,obj.endGraph);
                end
                dataToG = permute(dataToG,[1,3,2]);
            end
        catch
            if isa(obj,'nb_graph_ts')
                type = 'nb_math_ts';
            else
                type = 'double';
            end
            warning('nb_graph:plotEmptyVariable',...
            [mfilename ':: could not evaluate the expression; ' obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1} ' '...
                       'Remember that it is only possible to evaluate methods of the ' type ' class.'])
            dataToG = nan(obj.endGraph - obj.startGraph + 1,1);
        end
    else
        if isa(obj,'nb_graph_bd')
            dataToG = getVariable(obj.DB,obj.dataType,expression,obj.startGraph,obj.endGraph);
        else
            dataToG = getVariable(obj.DB,expression,obj.startGraph,obj.endGraph);
        end
        dataToG = permute(dataToG,[1,3,2]);
    end
    if isa(obj,'nb_graph_ts')
        obj.dataToGraph = nb_math_ts(dataToG,obj.startGraph);
    else % nb_graph_data
        obj.dataToGraph = dataToG;
    end
    obj.variablesToPlot = {expression};     
    
end
