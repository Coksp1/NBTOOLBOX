function [lVarsXNew,lVarsYNew] = getLabelVariables(obj,type)
% Get labels of plot
%
% - type : > 1         : For nb_displayValue
%          > otherwise : For nb_plotLabels

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 1;
    end

    if strcmpi(obj.graphMethod,'graphSubPlots') || and(strcmpi(obj.graphMethod,'graphInfoStruct'),obj.DB.numberOfDatasets > 1)
        
        if isa(obj,'nb_graph_ts') || isa(obj,'nb_graph_data') 
            lVarsXNew = {obj.startGraph:obj.endGraph};
        elseif isa(obj,'nb_graph_bd')
            lVarsXNew = {obj.xDates};
        else % isa(obj,'nb_graph_cs')
            lVarsXNew = {obj.typesToPlot};
        end
        
        if ~isempty(obj.DB)
            vars = obj.DB.dataNames;
            for ii = 1:length(vars)
                [~,n,e]  = fileparts(vars{ii});
                vars{ii} = [n,e];
            end
            if ~isa(obj,'nb_graph_cs')
                if ~isempty(obj.dashedLine)
                    vars = [vars,vars];
                end
            end
            lVarsYNew = {vars};
        else
            lVarsYNew = {{}};
        end
        
        if ~isa(obj,'nb_graph_data')
            if any(cellfun(@(x)isa(x,'nb_fanChart'),obj.axesHandle.children))
                lVarsXNew = [{{}},lVarsXNew];
                lVarsYNew = [{{}},lVarsYNew];
            end
        end
        
        return
        
    elseif strcmpi(obj.graphMethod,'graphInfoStruct')
        
        if isa(obj,'nb_graph_ts') || isa(obj,'nb_graph_data')
            lVarsXNew = {obj.startGraph:obj.endGraph};
        elseif isa(obj,'nb_graph_bd')
            lVarsXNew = {obj.xDates};    
        else % isa(obj,'nb_graph_cs')
            lVarsXNew = {obj.typesToPlot};
        end
        
        expression = obj.GraphStruct.(obj.fieldName){obj.fieldIndex,1};
        ind        = strfind(expression,'[');
        if isempty(ind)
            vars = {expression};
            if ~isa(obj,'nb_graph_cs')
                if ~isempty(obj.dashedLine)
                    vars = [vars,vars];
                end
            end
            lVarsYNew = {vars};
        else
            vars      = regexp(expression,',','split');
            vars{1}   = vars{1}(2:end);
            vars{end} = vars{end}(1:end-1);
            if ~isa(obj,'nb_graph_cs')
                if ~isempty(obj.dashedLine)
                    vars = [vars,vars];
                end
            end
            lVarsYNew = {vars};
        end 
        
        if ~isa(obj,'nb_graph_data')
            if any(cellfun(@(x)isa(x,'nb_fanChart'),obj.axesHandle.children))
                lVarsXNew = [{{}},lVarsXNew];
                lVarsYNew = [{{}},lVarsYNew];
            end
        end
        
        return
        
    end
 
    if strcmpi(obj.plotType,'scatter')   
        [lVarsXNew,lVarsYNew] = getLabelVariablesScatter(obj,type);
    elseif strcmpi(obj.plotType,'candle') 
        lVarsXNew = {{}};
        lVarsYNew = {{}};
    elseif any(strcmpi(obj.plotType,{'pie','donut'}))
        lVarsXNew = {obj.typesToPlot};
        lVarsYNew = {obj.variablesToPlot};
    elseif strcmpi(obj.plotType,'radar')
        lVarsXNew = {obj.typesToPlot};
        lVarsYNew = {obj.variablesToPlot};
    else
        
        if isprop(obj,'variableToPlotX')
            varToPlotX = obj.variableToPlotX;
        else
            varToPlotX = '';
        end
        if isempty(varToPlotX)
            if isa(obj,'nb_graph_ts')
                lVarsXNew = {obj.dates};
            elseif isa(obj,'nb_graph_data')
                lVarsXNew = {obj.startGraph:obj.endGraph};
            elseif isa(obj,'nb_graph_bd')
                lVarsXNew = {obj.xDates};
            else % isa(obj,'nb_graph_cs')
                lVarsXNew = {obj.typesToPlot};
            end
        else
            lVarsXNew = {repmat({varToPlotX},[1,length(obj.dataToGraph)])};
        end
        
        if isa(obj,'nb_graph_ts')
            if ~isempty(obj.datesToPlot)
                varsSplit = getSplittedVars(obj,obj.datesToPlot);
                lVarsYNew = {[obj.datesToPlot,varsSplit]};
                return
            end
        end
        
        lVarsYNew = {};
        if ~isempty(obj.variablesToPlot) 
            varsSplit = getSplittedVars(obj,obj.variablesToPlot);
            lVarsYNew = {[obj.variablesToPlot,varsSplit]};
        end
        if ~isempty(obj.variablesToPlotRight)  
            varsSplit = getSplittedVars(obj,obj.variablesToPlotRight);
            lVarsYNew = [lVarsYNew,{[obj.variablesToPlotRight,varsSplit]}];
        end

        if size(lVarsYNew,2) == 2
            lVarsXNew = lVarsXNew(1,ones(1,2));
        end
        
        if isa(obj,'nb_graph_cs')
            if strcmpi(obj.barOrientation,'horizontal')
                lVarsYNewT = lVarsYNew;
                lVarsYNew  = lVarsXNew;
                lVarsXNew  = lVarsYNewT;
            end
        end
        
        if ~isa(obj,'nb_graph_data')
            if any(cellfun(@(x)isa(x,'nb_fanChart'),obj.axesHandle.children))
                lVarsXNew = [{{}},lVarsXNew];
                lVarsYNew = [{{}},lVarsYNew];
            end
        end
        
        if strcmpi(obj.plotType,'dec')
            lVarsXNew = [lVarsXNew,lVarsXNew];
            lVarsYNew = [{{'sum'}},lVarsYNew];
            
            
        end
        
    end

end

%==========================================================================
% SUB
%==========================================================================
function varsSplit = getSplittedVars(obj,vars)
% Get the names of the splitted line variables

    varsSplit = cell(1,length(vars));     
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

                    tempVar        = vars{ind};
                    tempVar2       = [tempVar '(second)'];
                    varsSplit{ind} = tempVar2;

                end

            end

        end
        
    end
    
    ind       = cellfun(@isempty,varsSplit);
    varsSplit = varsSplit(~ind);

end
 
    
