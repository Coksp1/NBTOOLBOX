function halfYear = getHalfYear(obj)
% Syntax:
% 
% halfYear = getHalfYear(obj)
%
% Description:
%    
% Get the half year of the week, given as an nb_semiAnnual object
% 
% Input:
% 
% - obj      : An object of class nb_week
%
% Output:
% 
% - halfYear : An nb_semiAnnual object
%  
% Examples:
%
% halfYear = obj.getHalfYear();  % Will return the half year
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        siz           = size(obj);
        obj           = obj(:);
        s             = prod(siz);
        halfYear(1,s) = nb_semiAnnual;
        for ii = 1:s  
            halfYear(ii) = getHalfYear(obj(ii));
        end
        halfYear = reshape(halfYear,siz);
        return
    end

    day                = getDay(obj);
    halfYear           = getHalfYear(day);
    halfYear.dayOfWeek = obj.dayOfWeek;

end
