function obj = setMixing(obj,mixing)
% Syntax:
%
% obj = setMixing(obj,mixing)
%
% Description:
%
% Set the mixing of the decleared dependent and/or block_exogenous
% variables of a formulated model, i.e. if some of the dependent variables
% represents the same variable, but with different frequencies.
%
% See setFrequency for the supported frequencies.
% 
% Input:
% 
% - obj    : An object of class nb_mfvar
%
% - mixing : A cellstr on the format; {'Var1_Q','Var1_M',...
%           'Var2_Q','Var2_M'}. For more see nb_mfvar.help('mixing').
% 
% Output:
% 
% - obj : An object of class nb_mfvar where the mixing of a set of
%         variables has been set. See the dependent and block_exogenous
%         properties.
%
% See also:
% nb_mfvar.setFrequency
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(mixing)
        return
    end

    if ~iscellstr(mixing)
        error([mfilename ':: The input assign to the mixing must be a cellstr array.'])
    end
    if rem(length(mixing),2) ~= 0
        error([mfilename ':: The length of the input assign to the mixing must be even.'])
    end
    
    if obj.dependent.number == 0
        error([mfilename ':: Set the dependent variables before setting the mixing option.'])
    end
    
    supp = [obj.dependent.name,obj.block_exogenous.name];
    num  = [obj.dependent.number,obj.block_exogenous.number];
    nobj = numel(obj);
    obj  = obj(:);
    for oo = 1:nobj
    
        for ii = 1:2:length(mixing)
            var      = mixing{ii};
            indVar   = strcmpi(var,supp);
            if ~any(indVar)
                error([mfilename ':: The input assign to the mixing is wrong. Tried to set the mixing of a variable (' var...
                                 ') that is not dependent nor block_exogenous.'])
            end
            otherVar = mixing{ii+1};
            indVarO  = strcmpi(otherVar,supp);
            if ~any(indVarO)
                error([mfilename ':: The input assign to the mixing is wrong. The variable ' otherVar ' assign to the variable ' var ...
                                 ' is not dependent nor block_exogenous.'])
            end
            if strcmpi(var,otherVar)
                error([mfilename ':: The input assign to the mixing is wrong. The variable ' otherVar ' assign to the variable ' var ...
                                 ' is the same variable.'])
            end
            if any(indVar(1:num(1))) && any(indVarO(1:num(1)))
                obj(oo).dependent.mixing{indVar} = otherVar;
            elseif any(indVar(num(1) + 1:end)) && any(indVarO(num(1) + 1:end))
                indVar = indVar(num(1) + 1:end);
                obj(oo).block_exogenous.mixing{indVar} = otherVar;
            else
                error([mfilename ':: The input assign to the mixing is wrong. The ' var ' that is assign the variable ' otherVar ...
                                 ' as the same variable, but with another frequency must either both be dependent or both be block exogenous.'])
            end
            
        end
        
    end
    
end
