function addPatch(obj,page)
% Syntax:
%
% addPatch(obj,page)
%
% Description:
%
% Add patch to current graph. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
            
    if any(strcmpi(obj.plotType,{'radar','pie','image'}))
        return
    end

    if nargin < 2
        page = 1:obj.DB.numberOfDatasets;
    end

    pSize = size(obj.patch,2);

    if mod(pSize,4) ~= 0
        error([mfilename ':: Wrong input ''patch''. The input must be a cell array on the form; {''patchName1'',''var1'',''var2'',''color1'',...}'])
    end

    for ii = 1:4:pSize

        var1  = obj.patch{ii + 1};
        var2  = obj.patch{ii + 2};
        ind1  = find(strcmp(var1,obj.DB.variables),1);
        ind2  = find(strcmp(var2,obj.DB.variables),1);
        if ~isempty(ind1) && ~isempty(ind2)

            if isa(obj,'nb_graph_ts') || isa(obj,'nb_graph_data')
                ind = obj.startIndex:obj.endIndex;
            elseif isa(obj,'nb_graph_cs')
                ind = ismember(obj.typesToPlot,obj.DB.types);
            end

            data1 = obj.DB.data(ind,ind1,page)*obj.factor;
            data2 = obj.DB.data(ind,ind2,page)*obj.factor;
            color = obj.patch{ii + 3};

            if ischar(color)
                color = nb_plotHandle.interpretColor(color);
            end

            % Get the plot data
            yup   = data2(:,:,end);
            ydown = data1(:,:,end);
            good  = ~isnan(ydown) & ~isnan(yup);
            y     = [yup(good);flipud(ydown(good))];
            if isa(obj,'nb_graph_data')
                if ~isempty(obj.variableToPlotX)
                    x = getVariable(obj.DB,obj.variableToPlotX,obj.startGraph,obj.endGraph)';
                else
                    x = 1:size(yup,1);
                end
            else
                x = 1:size(yup,1);
            end
            x = x(good);
            x = [x(:);flipud(x(:))];

            % Add the patch
            nb_patch(x,y,color,...
                     'parent',      obj.axesHandle,...
                     'faceAlpha',   obj.patchAlpha,...
                     'edgeColor',   'none');

        else
            warning('nb_graph:addPatch:VarNotFound',[mfilename ':: One of the variables ' var1 ' or  ' var2 ' could not be found in the given database.'])
        end

    end

end
