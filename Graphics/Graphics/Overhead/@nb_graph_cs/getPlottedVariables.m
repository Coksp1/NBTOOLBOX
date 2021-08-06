function vars = getPlottedVariables(obj,forLegend)
% Syntax:
% 
% vars = getPlottedVariables(obj,forLegend)
% 
% Description:
% 
% Get the plotted variables of the graph
% 
% Input:
% 
% - obj       : An object of class nb_graph_cs
% 
% - forLegend : true or false (default)
%
%               When forLegend is used the variables are listed as needed 
%               for the legend, but without fake legends and patches, and
%               duplicates are not removes.
%
% Output:
%
% - vars     : A cellstr
%
% Example:
% 
% vars = obj.getPlottedVariables();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        forLegend = false;
    end

    if forLegend
        
        if strcmpi(obj.graphMethod,'graphSubPlots')  
            if ~isempty(obj.DB)
                vars = obj.DB.dataNames;
            end
            return
        end
        
        % Get the plotted variables
        plotType = obj.plotType;
        if strcmpi(plotType,'scatter')
            vars = [obj.scatterVariables(1:2:end), obj.scatterVariablesRight(1:2:end)];
        elseif strcmpi(plotType,'candle')
            vars = 'candle';
        elseif ~isempty(obj.plotTypes) || strcmpi(plotType,'line')
            
            % Are some of the variable set with lineStyle 'none'?
            vars  = removeNoneLines(obj,obj.variablesToPlot);
            varsR = removeNoneLines(obj,obj.variablesToPlotRight);
            
            % Merge
            vars = [vars,varsR]; 
            
        else
            vars = [obj.variablesToPlot,obj.variablesToPlotRight];
        end
        
        if strcmpi(obj.plotType,'dec')
            vars = ['sum',vars];
        end
        
        if strcmpi(obj.legAuto,'off')
            if ~isempty(obj.patch)
                vars  = [obj.patch(1:4:end),vars]; 
            end
            if ~isempty(obj.fakeLegend)
                vars = [vars, obj.fakeLegend(1:2:end)];
            end
        end
        
    else

        if strcmpi(obj.plotType,'scatter')

            vars = {};
            for ii = 2:2:size(obj.scatterVariables,2)
                vars  = [vars, obj.scatterVariables{ii}]; %#ok
            end
            for ii = 2:2:size(obj.scatterVariablesRight,2)
                vars  = [vars, obj.scatterVariablesRight{ii}]; %#ok
            end

        elseif strcmpi(obj.plotType,'candle')
            vars  = obj.candleVariables(2:2:end);
        else
            vars  = [obj.variablesToPlot,obj.variablesToPlotRight];
        end

        % Include the variables creating the patches
        if ~isempty(obj.patch)
            patchVar1 = obj.patch(2:4:end);
            patchVar2 = obj.patch(3:4:end);
            vars      = [vars, patchVar1, patchVar2]; 
        end

        % Remove duplicates
        vars  = RemoveDuplicates(sort(vars));
        
    end

end

%==========================================================================
function vars = removeNoneLines(obj,vars)

    keep = true(1,length(vars));
    for ii = 1:length(vars)
        line  = true;
        indPT = find(strcmp(vars{ii},obj.plotTypes),1);
        if ~isempty(indPT)
            plotTypeT = obj.plotTypes{indPT + 1};
            if ~strcmpi(plotTypeT,'line')
                line = 0; % The splitted line should not be added to the legend as it is not plotted
            end
        elseif ~strcmpi(obj.plotType,'line') 
            line = 0;% The splitted line should not be added to the legend as it is not plotted
        end
        if line

            indLS = find(strcmp(vars{ii},obj.lineStyles),1);
            if ~isempty(indLS)
                lineStyle = obj.lineStyles{indLS + 1};
                if iscell(lineStyle) 
                    if strcmpi(lineStyle{1},'none')
                        keep(ii) = false;
                    end
                elseif strcmpi(lineStyle,'none')
                    keep(ii) = false;
                end
            end

        end

    end
    vars = vars(keep);
            
end
