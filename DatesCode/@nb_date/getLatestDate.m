function date = getLatestDate(c)
% Syntax:
%
% date = nb_date.getLatestDate(c)
%
% Description:
%
% Get the lates date among the dates in c.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~iscellstr(c)
        error([mfilename ':: Input must be a cellstr'])
    end
    
    date = nb_date.date2freq(c{1});
    for ii = 2:length(c)
        dateT = nb_date.date2freq(c{ii});
        if dateT > date
            date = dateT;
        end        
    end

end
