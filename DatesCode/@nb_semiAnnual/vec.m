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
% obj   : An nb_semiAnnual object which represents the start date of the vector
%
% end   : An nb_semiAnnual object or a double, representing the end date or the
%         number of periods you want in your vector
%  
% Output:
% 
%  obj  : A nPeriods*1 vector of nb_semiAnnual objects.
%
% Examples:
% f = nb_semiAnnual(1,2010);
% g = nb_semiAnnual(2,2011);
% vector = f.vec(g)
% 
% See also:
% nb_semiAnnual
%
% Written by Tobias Ingebrigtsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(endD, 'nb_semiAnnual') && ~(length(obj) == length(endD))
        error('The start vector must be of the same length as the end vector');
    
    end
    
    if length(obj) == 1
        if isa(endD, 'nb_semiAnnual')
            endInd  = endD-obj + 1;
            periods = 0:endInd-1;
            
        elseif isa(endD,'double') 
            periods = 0:endD-1;
        
        else 
            error([mfilename '::Wrong input format for endD. Must be either an nb_semiAnnual '...
                  'object or a double.'])
              
        end
         if isempty(periods)
           error([mfilename ':: The end date needs to be after the start '...
                            'date.'])
        end
        out = toDates(obj,periods,'nb_date',2,1);    
    else
        error([mfilename '::The input needs to be a scalar object. '])
        
    end
   
end
