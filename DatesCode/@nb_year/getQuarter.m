function quarter = getQuarter(obj,first)
% Syntax:
% 
% quarter = getQuarter(obj,first)
%
% Description:
%   
% Get the first or last quarter of the year, given as an nb_quarter 
% object
% 
% Input:
% 
% - obj     : An object of class nb_year
% 
% Output:
% 
% - quarter : An nb_quarter object
% 
% - first   : 1 : first quarter
%             0 : last quarter
% 
% Examples:
%
% quarter = obj.getQuarter();  % Will return the first quarter
% quarter = obj.getQuarter(1); % WIll return the last quarter
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        first = 1;
    end
    
    if numel(obj) > 1
        siz           = size(obj);
        obj           = obj(:);
        s             = prod(siz);
        quarter(1,s)  = nb_quarter;
        for ii = 1:s  
            quarter(ii) = getQuarter(obj(ii),first);
        end
        quarter = reshape(quarter,siz);
        return
    end

    if first
        quarter = nb_quarter(1,obj.year);
    else
        quarter = nb_quarter(4,obj.year);
    end
    quarter.dayOfWeek = obj.dayOfWeek;

end
