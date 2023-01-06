function nr = getNr(obj)
% Syntax:
%
% nr = getNr(obj)
%
% Description:
%
% Get date number of a nb_date vector.
% 
% Input:
% 
% - obj : A vector of nb_date objects. 
% 
% Output:
% 
% - nr  : A double with the date numbers of each object in the nb_date
%         vector.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isrow(obj)
        func = @horzcat;
    elseif iscolumn(obj)
        func = @vertcat;
    else
        error([mfilename ':: Input must be either a row or column vector.'])
    end
    
    switch obj(1).frequency
        case 1
            nr = func(obj.yearNr);
        case 2
            nr = func(obj.halfYearNr);
        case 4
            nr = func(obj.quarterNr);
        case 12
            nr = func(obj.monthNr);
        case 52
            nr = func(obj.weekNr);
        case 365
            nr = func(obj.dayNr);
    end

end
