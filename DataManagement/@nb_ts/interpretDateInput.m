function date = interpretDateInput(obj,date)
% Syntax:
%
% date = interpretDateInput(obj,date)
%
% Description:
%
% Hidden method.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isempty(obj.localVariables)
        date = nb_date.toDate(date,obj.frequency);
    else
        if ischar(date)
            found = strfind(date,'%#');
            if isempty(found)
                date = nb_date.toDate(date,obj.frequency);
            else
                date = nb_localVariables(obj.localVariables,date);
                date = nb_date.toDate(date,obj.frequency);
            end
        else
            date = nb_date.toDate(date,obj.frequency);
        end
    end
        
end
