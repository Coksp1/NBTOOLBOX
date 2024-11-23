function obj = setMapping(obj,map)
% Syntax:
%
% obj = setMapping(obj,freq)
%
% Description:
%
% Set the maping of the decleared nb_fmdyn of a formulated model. I.e. 
% how to map the higher frequency to lower frequency in the observation 
% equation.
%
% See setFrequency for the supported frequencies.
%
% Supported mappings (Examples are given for a monthly and quarterly 
% mixed frequency data):
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
% - obj : An object of class nb_fmdyn
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
% nb_fmdyn.setFrequency
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(map)
        return
    end

    if ~iscellstr(map)
        error([mfilename ':: The input assign to the mapping must be a cellstr array.'])
    end
    if rem(length(map),2) ~= 0
        error([mfilename ':: The length of the input assign to the mapping must be even.'])
    end
    
    supp = {'levelSummed','diffSummed','levelAverage','diffAverage','end'};
    siz  = size(obj);
    nobj = prod(siz);
    obj  = obj(:); 
    for oo = 1:nobj
    
        for ii = 1:2:length(map)
            var      = map{ii};
            mapOfVar = map{ii+1};
            if ~any(strcmpi(mapOfVar,supp))
                error([mfilename ':: The input assign to the mapping is wrong. The map ' mapOfVar ' assign to the variable ' var ' is not supported.'])
            end
            indVar = strcmp(var,obj(oo).observables.name);
            if ~any(indVar)
                error([mfilename ':: The input assign to the mapping is wrong. Tried to set the mapping of a variable that is not dependent nor block_exogenous.'])
            end
            obj(oo).observables.mapping{indVar} = mapOfVar;
        end
        
    end
    obj = reshape(obj,siz);
    
end
