function note = nb_when2Notify(number)
% Syntax:
%
% note = nb_when2Notify(number)
%
% Description:
%
% This function governs how often the waitbars used in the NBTOOLBOX
% notify the status
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if number > 10000
        note = 250;
    elseif number > 5000
        note = 100;
    elseif number > 1000
        note = 50;
    elseif number > 500
        note = 20;
    elseif number > 50
        note = 10;
    else
        note = 1;
    end

end
