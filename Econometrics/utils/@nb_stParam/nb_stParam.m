classdef nb_stParam < nb_st
% Description:
%
% A class representing a parameter in a equation during stationarization.
%
% Superclasses:
% nb_st, matlab.mixin.Heterogeneous
%
% See also:
% nb_stTerm, nb_stBase, nb_stParam
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties 
       
        % The parameter value, as a scalar double.
        value       = [];
        
    end
    
    methods
        
        function obj = nb_stParam(paramName,value)
            
            if iscellstr(paramName)
                nobj      = length(paramName);
                value     = value(:);
                if nobj ~= size(value,1)
                    error([mfilename ':: The length of paramName and value inputs must be the same.'])
                end
                obj = obj(ones(1,nobj),1);
                for ii = 1:nobj
                    obj(ii).value  = value(ii);
                    obj(ii).string = paramName{ii};
                end
            else
                obj.value  = value;
                obj.string = paramName;
            end
            
        end
        
    end
    
end
