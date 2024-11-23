function halfYear = getHalfYear(obj)
% Syntax:
% 
% halfYear = getHalfYear(obj)
%
% Description:
%    
% Get the half year of the quarter, given as an 
% nb_semiAnnual object
% 
% Input:
% 
% - obj      : An object of class nb_quarter
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
          
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

	halfYear           = nb_semiAnnual(1 + floor((obj.quarter - 1)/2),obj.year);
    halfYear.dayOfWeek = obj.dayOfWeek;        
    
end
