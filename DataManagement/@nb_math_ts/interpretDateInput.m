function date = interpretDateInput(obj,date)
% Syntax:
%
% date = interpretDateInput(obj,date)
%
% Description:
%
% Hidden method.
% 
% Written by Atle Loneland

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

        date = nb_date.date2freq(date);
        
end
