function list = nb_getDatesAndLocals(object)
% Syntax:
%
% list = nb_getDatesAndLocals(plotter)
%
% Description:
%
% Get all the dates and local variables which represents dates on the same
% frequency as the data of a nb_graph_ts or nb_ts object
% 
% Input:
% 
% - plotter : An object of class nb_graph_ts or nb_ts
% 
% Output:
% 
% - list    : A list of dates and local variables that represent dates
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get all the dates of the data of the graph object
    if isa(object,'nb_graph_ts')
        allDates = dates(object.DB);
        freq     = object.DB.frequency;
    else
        allDates = dates(object);
        freq     = object.frequency;
    end
    % Check for local variables that represent dates of the same freq
    % of the data of the graph
    locVar  = object.localVariables;
    fields  = fieldnames(locVar);
    nFields = length(fields);
    ind     = true(1,nFields);
    for ii = 1:nFields
       
        tested = locVar.(fields{ii});
        try
            nb_date.toDate(tested,freq);
        catch %#ok<CTCH>
            ind(ii) = false;
        end
        
    end
    allLocals = fields(ind);
    allLocals = strcat('%#',allLocals);
    
    % Return all
    list = [allDates;allLocals];
    
end
