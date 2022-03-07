function list = getVariablesAndSources(plotter)
% Syntax:
%
% list = nb_viewInfoSpreadsheetGUI.getVariablesAndSources(plotter)
%
% Description:
%
% Part of DAG. Given the plotter object, create a n x 2 cell with variable 
% names in the first column and the code use to create the variables in 
% the second column. Variables that are not plotted in the graph will have 
% "(not plotted)" added to their names. Note that only relatively simple 
% code will show in the second column.
% 
% Written by Per Bjarne Bye 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    vars         = plotter.DB.variables;
    varCell      = cell(length(vars),2);
    varCell(:,1) = sort(vars);
    try
        sourceVars = getCreatedVariables(plotter.DB);
    catch % Want spreadsheet to work even if get method fails.
        nb_errorWindow(['There was an error thrown by getCreatedVariables when creating the spreadsheet. ',...
        'Continuing without transformations...'])
        sourceVars = [];
    end

    if ~isempty(sourceVars)
        [C,ia,~]  = unique(sourceVars(:,1),'last');
        if length(C) < size(sourceVars,1) % Duplicate variables
            sourceVars = sourceVars(ia,:);
        end
        
        [~,sortIdx] = sort(sourceVars(:,1)); % Need to compare sorted arrays for ismember matching
        sourceVars  = sourceVars(sortIdx,:);
        idxVars     = ismember(varCell(:,1),sourceVars(:,1));
        idxSource   = ismember(sourceVars(:,1),varCell(:,1));
        varCell(idxVars,2) = sourceVars(idxSource,2);
    end
    plotvars       = getPlottedVariables(plotter);
    idx            = ~ismember(varCell(:,1),plotvars);
    varCell(idx,1) = cellfun(@(s) [s,' (not plotted)'],varCell(idx,1),'UniformOutput',false);
    list           = [varCell(~idx,:);varCell(idx,:)];
end
