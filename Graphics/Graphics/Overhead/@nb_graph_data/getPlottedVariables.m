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
% - obj       : An object of class nb_graph_data
% 
% - forLegend : true or false (default)
%
%               When forLegend is used the variables are listed as needed 
%               for the legend, but without fake legends and patches, and
%               duplicates are not removes.
%
% Output:
%
% - vars     : As a cellstr
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
                if ~isempty(obj.dashedLine)
                    varNames = strcat(obj.DB.dataNames,'(second)');
                    vars     = [vars,varNames];
                end
            end
            return
        end
        
        % Get the plotted variables
        plotType = obj.plotType;
        if strcmpi(plotType,'scatter')
            vars = [obj.scatterObs(1:2:end), obj.scatterObsRight(1:2:end)];
        elseif strcmpi(plotType,'candle')
            vars = {'candle'};
        elseif ~isempty(obj.plotTypes) || strcmpi(plotType,'line')
            
            vars  = obj.variablesToPlot;
            varsR = obj.variablesToPlotRight;
            
            % Added the splitted lines
            varsS  = getSplittedVars(obj,vars);
            varsRS = getSplittedVars(obj,varsR);
            
            % Are some of the variable set with lineStyle 'none'?
            vars  = removeNoneLines(obj,vars);
            varsR = removeNoneLines(obj,varsR);
            
            % Merge the normal and splitted 
            vars = [vars,varsS,varsR,varsRS];
            
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
    
        % Get the plotted variables
        plotType = obj.plotType;
        if strcmpi(plotType,'scatter')
            vars = [obj.scatterVariables, obj.scatterVariablesRight];
        elseif strcmpi(plotType,'candle')
            vars = obj.candleVariables(2:2:end);
        else
            vars = [nb_rowVector(obj.variablesToPlot),nb_rowVector(obj.variablesToPlotRight),obj.variableToPlotX];
        end

        % Include the variables creating the patches
        if ~isempty(obj.patch)
            patchVar1 = obj.patch(2:4:end);
            patchVar2 = obj.patch(3:4:end);
            vars = [vars, patchVar1, patchVar2]; 
        end

        % Remove duplicates
        vars = RemoveDuplicates(sort(vars));
        
    end

end

%==========================================================================
% SUB
%==========================================================================
function varsSplit = getSplittedVars(obj,vars)
% Get the names of the splitted line variables

    varsSplit = {};     
    if strcmpi(obj.plotType,'line') || ~isempty(obj.plotTypes) 
         
        for ii = 2:2:size(obj.lineStyles,2)

            var   = obj.lineStyles{ii - 1};
            ind   = find(strcmp(var,vars),1);
            add   = 1;
            indPT = find(strcmp(var,obj.plotTypes),1);
            if ~isempty(indPT)
                plotTypeT = obj.plotTypes{indPT + 1};
                if ~strcmpi(plotTypeT,'line')
                    add = 0; % The splitted line should not be added to the legend as it is not plotted
                end
            elseif ~strcmpi(obj.plotType,'line') 
                add = 0;% The splitted line should not be added to the legend as it is not plotted
            end

            if ~isempty(ind) && add

                lineStyle = obj.lineStyles{ii};
                if iscell(lineStyle)

                    tempVar   = vars{ind};
                    tempVar2  = [tempVar '(second)'];
                    varsSplit = [varsSplit,tempVar2]; %#ok

                end

            end

        end
        
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
