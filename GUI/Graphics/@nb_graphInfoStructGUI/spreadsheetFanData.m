function spreadsheetFanData(gui,~,~)
% Syntax:
%
% spreadsheetFanData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Create simple spreadsheet of fan chart data behind figure  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the data of the curent displayed graph
    %--------------------------------------------------------------
    GraphStruct = gui.plotter.GraphStruct;
    fnames      = fieldnames(GraphStruct);
    GraphInfo   = GraphStruct.(fnames{1});
    expressions = GraphInfo(:,1);
    data        = gui.plotter.fanDatasets;
    variables   = data.variables;

    try

        % Remove empty variables
        ind         = ~cellfun('isempty',expressions);
        expressions = expressions(ind);
        
        indexedVars = {};
        for ii = 1:size(expressions,1)

            if ~any(strcmp(expressions{ii},variables))

                ind = strfind(expressions{ii},'[');
                if isempty(ind)
                    data        = data.createVariable(expressions{ii},expressions{ii});
                    indexedVars = [indexedVars, expressions{ii}]; %#ok
                else
                    % We are dealing with expressions like
                    % [var1,var2]
                    
                    expr     = strtrim(expressions{ii});
                    expr     = expr(2:end-1);
                    
                    indC     = strfind(expr,',');
                    indS     = strfind(expr,' ');
                    indSplit = sort([indC,indS]);
                    
                    start = 1;
                    for kk = 1:size(indSplit,2)
                        
                        tempExpr = expr(start:indSplit(kk)-1);
                        if ~any(strcmp(tempExpr,variables))
                            data     = data.createVariable(tempExpr,tempExpr);
                        end
                        start       = indSplit(kk) + 1;
                        indexedVars = [indexedVars, tempExpr]; %#ok
                        
                    end
                    
                    tempExpr = expr(start:end);
                    if ~any(strcmp(tempExpr,variables))
                        data     = data.createVariable(tempExpr,tempExpr);
                    end
                    indexedVars = [indexedVars, tempExpr]; %#ok
                    
                end
                
            else
                indexedVars = [indexedVars, expressions{ii}]; %#ok
            end

        end
        
        indexedVars = RemoveDuplicates(sort(indexedVars));
        data        = data.window(gui.plotter.startGraph,gui.plotter.endGraph,indexedVars);

        % Display data in its own window
        %--------------------------------------------------------------
        nb_spreadsheetSimpleGUI(gui.plotter.parent,data);
        
    catch %#ok<CTCH>
        nb_errorWindow('The data behind the figure could not be evaluated'); 
    end

end
