function obj = setMapping(obj,map)
% Syntax:
%
% obj = setMapping(obj,map)
%
% Description:
%
% Set the maping of the decleared dependent and/or block_exogenous
% variables of a formulated model. I.e. how to map the higher frequency to
% lower frequency in the observation equation.
%
% See setFrequency for the supported frequencies.
%
% Supported mappings (Examples are given for a mixed frequency VAR with
% monthly and quarterly data):
% - 'levelSummed'  : Y(q)      = Y(m) + Y(m-1) + Y(m-2)
% - 'diffSummed'   : Y(q)      = Y(m) + 2*Y(m-1) + 3*Y(m-2) +
%                                2*Y(m-3) + Y(m-4)
% - 'levelAverage' : Y(q)      = 1/3*(Y(m) + Y(m-1) + Y(m-2))
% - 'diffAverage'  : Y(q)      = 1/3*Y(m) + 2/3*Y(m-1) + Y(m-2) +  
%                                2/3*Y(m-3) + 1/3*Y(m-4)
% - 'end'          : Y(q)      = Y(m)
%
% The default mapping that is used for all series with lower frequency is
% 'diffAverage'.
% 
% Input:
% 
% - obj : An object of class nb_mfvar
%
% - map : A cellstr on the format; {'Var1','levelSummed',...
%         'Var2','diffSummed'}
% 
% Output:
% 
% - obj : An object of class nb_mfvar where the mapping of a set of
%         variables has been set. See the dependent and block_exogenous
%         properties.
%
% See also:
% nb_mfvar.setFrequency
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(map)
        return
    end

    if ~iscellstr(map)
        error([mfilename ':: The input assign to the mapping must be a cellstr array.'])
    end
    if rem(length(map),2) ~= 0
        error([mfilename ':: The length of the input assign to the mapping must be even.'])
    end
    
    if obj.dependent.number == 0
        error([mfilename ':: Set the dependent variables before setting the mapping option.'])
    end
    
    supp = {'levelSummed','diffSummed','levelAverage','diffAverage','end'};
    nobj = numel(obj);
    obj  = obj(:);
    for oo = 1:nobj
    
        for ii = 1:2:length(map)
            var      = map{ii};
            mapOfVar = map{ii+1};
            if ~any(strcmpi(mapOfVar,supp))
                error([mfilename ':: The input assign to the mapping is wrong. The map ' mapOfVar ' assign to the variable ' var ' is not supported.'])
            end
            isDep  = true;
            indVar = strcmp(var,obj(oo).dependent.name);
            if ~any(indVar)
                isDep  = false;
                indVar = strcmp(var,obj(oo).block_exogenous.name);
            end
            if ~any(indVar)
                error([mfilename ':: The input assign to the mapping is wrong. Tried to set the mapping of a variable (' var ') that is not ',...
                                 'dependent nor block_exogenous.'])
            end
            if isDep
                obj(oo).dependent.mapping{indVar} = mapOfVar;
            else
                obj(oo).block_exogenous.mapping{indVar} = mapOfVar;
            end
            
        end
        
    end
    
end
