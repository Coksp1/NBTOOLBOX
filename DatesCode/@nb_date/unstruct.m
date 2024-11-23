function obj = unstruct(s)
% Syntax:
%
% obj = nb_date.unstruct(s)
%
% Description:
%
% Convert nb_date object from struct
% 
% Input:
% 
% - s   : A struct
% 
% Output:
% 
% - obj : A nb_date object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(s,'frequency')
        error('The struct does not represent a nb_date object!')
    end
    switch s.frequency
        case 1
            obj = nb_year(s.year);
        case 2
            obj = nb_semiAnnual(s.halfYear,s.year);
        case 4
            obj = nb_quarter(s.quarter,s.year);
        case 12
            obj = nb_month(s.month,s.year);
        case 52
            obj = nb_week(s.week,s.year);
        case 365
            obj = nb_day(s.day,s.month,s.year);
        otherwise 
            error(['Unsupported frequency ' int2str(s.frequency)])
    end
end
