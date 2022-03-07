function ret = isEqualFreq(obj,aObj)
% Syntax:
% 
% ret = isEqualFreq(obj,aObj)
%
% Description:
%   
% Test if two date objects have the same frequency
% 
% Input:
% 
% - obj   : An object which is of class nb_date or a subclass of 
%           the nb_date class
% 
% - aObj  : An object which is of class nb_date or a subclass of 
%           the nb_date class
% 
% Output:
% 
% - ret   : 1 if equal frequency, 0 else
%     
% Examples:
%
% d   = nb_day(1,1,2012);
% q   = nb_quarter(4,2012);
% ret = d.isEqualFreq(q); % Will return 0
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(obj,'nb_date') && isa(aObj,'nb_date')

        try
            ret = obj.getFreq() == aObj.getFreq();
        catch 
            % Here we are dealing with empty nb_date 
            % objects
            ret = [];
        end

    else
        error([mfilename ':: Can only compare objects which is a subclass of the nb_date class. I.e. nb_day, nb_month, nb_quarter , nb_semiAnnual and nb_year.'])
    end
    
end
