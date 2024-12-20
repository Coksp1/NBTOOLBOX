function date = getEarliestDate(c)
% Syntax:
%
% date = nb_date.getEarliestDate(c)
%
% Description:
%
% Get the earliest date among the dates in c.
% 
% Input:
% 
% - c    : A cellstr of dates.
% 
% Output:
% 
% - date : A nb_date object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~iscellstr(c)
        error([mfilename ':: Input must be a cellstr'])
    end
    
    date = nb_date.date2freq(c{1});
    for ii = 2:length(c)
        dateT = nb_date.date2freq(c{ii});
        if dateT < date
            date = dateT;
        end        
    end

end
