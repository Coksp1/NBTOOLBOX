function list = nb_getDatesAndLocals(DB,flip)
% Syntax:
%
% list = nb_getDatesAndLocals(DB,flip)
%
% Description:
%
% Get all the dates and local variables which represents dates on the same
% frequency as the data of a nb_ts object
% 
% Input:
% 
% - DB   : An object of class nb_ts
%
% - flip : Flip the dates if 1, otherwise not
% 
% Output:
% 
% - list    : A list of dates and local variables that represent dates
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        flip = 0;
    end

    % Get all the dates of the data of the graph object
    allDates = dates(DB);
    if flip == 1
       allDates = flipud(allDates); 
    end

    % Check for local variables that represent dates of the same freq
    % of the data of the graph
    locVar  = DB.localVariables;
    if nb_isempty(locVar)
        list = allDates;
        return
    end
    
    fields  = fieldnames(locVar);
    nFields = length(fields);
    ind     = true(1,nFields);
    for ii = 1:nFields
       
        tested = locVar.(fields{ii});
        try
            nb_date.toDate(tested,DB.frequency);
        catch %#ok<CTCH>
            ind(ii) = false;
        end
        
    end
    allLocals = fields(ind);
    allLocals = strcat('%#',allLocals);
    
    % Return all
    list = [allDates;allLocals];
    
end
