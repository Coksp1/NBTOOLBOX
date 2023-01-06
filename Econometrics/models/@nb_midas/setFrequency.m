function obj = setFrequency(obj,freq)
% Syntax:
%
% obj = setFrequency(obj,freq)
%
% Description:
%
% Set the frequency of the decleared dependent and/or exogenous
% variables of a formulated model.
% 
% Supported frequencies:
% - 'yearly'    : 1
% - 'quarterly' : 4
% - 'monthly'   : 12
% - 'weekly'    : 52
%
% Input:
% 
% - obj  : An object of class nb_midas.
%
% - freq : A scalar integer with the frequency of the dependent variable,
%          or a cellstr on the format; {'Var1',1,'Var2',4}. There is no 
%          need to set the frequency of those variables that has the same
%          frequency as the data (options.data)!
%
%          Caution: The frequency of the dependent variable must be greater
%                   or equal to the frequency of the exogenous!
% 
% Output:
% 
% - obj : An object of class nb_midas where the frequency of a set of
%         variables has been set. See the dependent and exogenous
%         properties.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(freq)
        return
    end
    
    if nb_isScalarInteger(freq)
        obj.dependent.frequency = repmat({freq},[1,obj.dependent.number]);
        return
    end

    if ~iscell(freq)
        error([mfilename ':: The input assign to the frequency must be a cell array.'])
    end
    if rem(length(freq),2) ~= 0
        error([mfilename ':: The length of the input assign to the frequency must be even.'])
    end
    
    if obj.dependent.number == 0
        error([mfilename ':: Set the dependent variables before setting the frequency option.'])
    end
    
    supp = [1,4,12,52];
    nobj = numel(obj);
    obj  = obj(:);
    for oo = 1:nobj
    
        for ii = 1:2:length(freq)
            var       = freq{ii};
            freqOfVar = freq{ii+1};
            if nb_isScalarInteger(freqOfVar)
                if ~any(freqOfVar ~= supp)
                    error([mfilename ':: The input assign to the frequency is wrong. The frequency ' int2str(freqOfVar)...
                                     ' assign to the variable ' var ' is not supported.'])
                end
            else
                error([mfilename ':: The input assign to the frequency is wrong. The frequency assign to the variable ' var ...
                                 ' must be either a scalar integer or 1x3 cell array.'])
            end
            isDep  = true;
            indVar = strcmp(var,obj(oo).dependent.name);
            if ~any(indVar)
                isDep  = false;
                indVar = strcmp(var,obj(oo).exogenous.name);
            end
            if ~any(indVar)
                error([mfilename ':: The input assign to the frequency is wrong. ',...
                    'Tried to set the frequency of a variable (' var ') that is not ',...
                    'dependent nor exogenous.'])
            end
            if isDep
                obj(oo).dependent.frequency{indVar} = freqOfVar;
            else
                obj(oo).exogenous.frequency{indVar} = freqOfVar;
            end
            
        end
        
    end

end
