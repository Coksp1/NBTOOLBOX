function halfYear = getHalfYear(obj,first)
% Syntax:
% 
% halfYear = getHalfYear(obj,first)
%
% Description:
%    
% Get the first or last half year of the year, given as an 
% nb_semiAnnual object
% 
% Input:
% 
% - obj      : An object of class nb_year
% 
% - first    : 1 : first half year
%              0 : last half year
%
% Output:
% 
% - halfYear : An nb_semiAnnual object
%  
% Examples:
%
% halfYear = obj.getHalfYear();  % Will return first half year
% halfYear = obj.getHalfYear(1); % Will return last half year
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        first = 1;
    end
    
    if numel(obj) > 1
        siz           = size(obj);
        obj           = obj(:);
        s             = prod(siz);
        halfYear(1,s) = nb_semiAnnual;
        for ii = 1:s  
            halfYear(ii) = getHalfYear(obj(ii),first);
        end
        halfYear = reshape(halfYear,siz);
        return
    end

    if first
        halfYear = nb_semiAnnual(1,obj.year);
    else
        halfYear = nb_semiAnnual(2,obj.year);
    end
    halfYear.dayOfWeek = obj.dayOfWeek;

end
