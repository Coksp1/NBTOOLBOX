function out = vec(obj,endD)
% Syntax:
%
% out = vec(obj,endD)
%
% Description:
%
% A method to create a vector of dates between to dates.
% 
% Input:
%
% obj   : A nb_day object which represents the start date of the vector
%
% end   : A nb_day object or a double, representing the end date or the
%         number of periods you want in your vector
%  
% Output:
% 
%  obj  : A nPeriods*1 vector of nb_day objects.
%
% Examples:
% f = nb_day(1,1,2010);
% g = nb_day(10,1,2010);
% vector = f.vec(g)
% 
% See also:
% nb_day
%
% Written by Tobias Ingebrigtsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isa(endD, 'nb_day') && ~(length(obj) == length(endD))
        error('The start vector must be of the same length as the end vector');
    
    end
    
    if length(obj) == 1
        if isa(endD, 'nb_day')
            endInd  = endD-obj + 1;
            periods = 0:endInd-1; 
        elseif isa(endD,'double')
            periods = 0:endD-1;
        else
            error([mfilename '::Wrong input format for endD. Must be either an nb_day '...
                'object or a double. '])  
        end
        if isempty(periods)
            error([mfilename ':: The end date needs to be after the start '...
                'date.'])
        end
        out = toDates(obj,periods,'nb_date',365,1);
    else
        error([mfilename ':: The input needs to be a scalar object.'])
    end
   
end
