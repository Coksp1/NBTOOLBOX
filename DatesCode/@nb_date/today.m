function obj = today(freq)
% Syntax:
%
% obj = nb_date.today(freq)
%
% Description:
%
% Get the current day as a nb_day object. 
%
% Input:
%
% - freq : The wanted frequency of the date of today.
%
%          1,2,4,12,52,{365}
%
% Output:
% 
% obj : An object of class nb_date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        freq = 365;
    end

    switch freq
        
        case 1
            obj = nb_year.today();
        case 2
            obj = nb_semiAnnual.today();
        case 4
            obj = nb_quarter.today();
        case 12
            obj = nb_month.today();
        case 52
            obj = nb_week.today();
        case 365
            obj = nb_day.today();
        otherwise
            error([mfilename ':: Unsupported frequency ' int2str(freq)])
    end
    
end
