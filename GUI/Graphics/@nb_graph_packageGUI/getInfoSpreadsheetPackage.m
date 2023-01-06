function cellout = getInfoSpreadsheetPackage(gui)
% Syntax:
%
% cellout = getInfoSpreadsheetPackage(gui)
%
% Description:
%
% Part of DAG. Given the GUI object, create the cellstr which is used to 
% display info about graphs and variables.
% 
% Written by Per Bjarne Bye 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    graphObj = gui.package.graphs;
    
    % Find number of rows needed in the spreadsheet
    n = 0;
    for ii = 1:length(graphObj)
        for jj = 1:length(graphObj{ii}.plotter)
            n = n + length(graphObj{ii}.plotter(jj).DB.variables);
        end
        % Gap between figures, last iteration creates space for a header
        n = n + 1;
    end
    
    c      = cell(n,4);
    c(1,:) = {'Figure number','Figure name','Series','Transformations'};
    number = nb_numbering(gui.package.start - 1,gui.package.chapter,'norsk',gui.package.bigLetter);

    rowctr = 2;
    for ii = 1:length(graphObj)
        numStr = nb_getFigureNumbering(graphObj{ii},number,ii);
        for jj = 1:length(graphObj{ii}.plotter)
            if length(graphObj{ii}.plotter) > 1
                panel = true;
            else
                panel = false;
            end
            if ~panel
                c(rowctr,1)  = {numStr};
                figureTitle  = nb_localVariables(graphObj{ii}.localVariables,graphObj{ii}.figureNameNor);
                figureTitle  = nb_localFunction(graphObj{ii},figureTitle);
                c(rowctr,2)  = {figureTitle};
                variableList = nb_viewInfoSpreadsheetGUI.getVariablesAndSources(graphObj{ii}.plotter);
                numrows      = length(variableList)-1;
                c(rowctr:rowctr+numrows,3:4) = variableList;
                rowctr       = rowctr + numrows + 2;
            elseif panel && jj == 1
                c(rowctr,1)  = {[numStr,'a']};
                figureTitle  = nb_localVariables(graphObj{ii}.localVariables,graphObj{ii}.figureNameNor);
                figureTitle  = nb_localFunction(graphObj{ii},figureTitle);
                c(rowctr,2)  = {figureTitle};
                variableList = nb_viewInfoSpreadsheetGUI.getVariablesAndSources(graphObj{ii}.plotter(1));
                numrows      = length(variableList)-1;
                c(rowctr:rowctr+numrows,3:4) = variableList;
                rowctr       = rowctr + numrows + 1;
            else
                c(rowctr,1)  = {[numStr,'b']};
                variableList = nb_viewInfoSpreadsheetGUI.getVariablesAndSources(graphObj{ii}.plotter(2));
                numrows      = length(variableList)-1;
                c(rowctr:rowctr+numrows,3:4) = variableList;
                rowctr       = rowctr + numrows + 2;
            end
        end
    end
    
    cellout = c;
end
