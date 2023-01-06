function obj = setFrequency(obj,freq)
% Syntax:
%
% obj = setFrequency(obj,freq)
%
% Description:
%
% Set the frequency of the decleared observables of a formulated model.
% 
% Supported frequencies:
% - 'quarterly' : 4
% - 'monthly'   : 12
%
% Input:
% 
% - obj  : An object of class nb_fmdyn.
%
% - freq : A cellstr on the format; {'Var1',4,'Var2',4}. There is no need
%          to set the frequency of those variables that has the same
%          frequency as the data (options.data)!
% 
% Output:
% 
% - obj : An object of class nb_fmdyn where the frequency of a set of
%         variables has been set. See the observables properties.
%
% See also:
% nb_fmdyn.setMapping
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(freq)
        return
    end

    if ~iscell(freq)
        error([mfilename ':: The input assign to the frequency must be a cell array.'])
    end
    if rem(length(freq),2) ~= 0
        error([mfilename ':: The length of the input assign to the frequency must be even.'])
    end
    
    supp = [4,12];
    siz  = size(obj);
    obj  = obj(:);
    nobj = prod(siz);
    for oo = 1:nobj
    
        for ii = 1:2:length(freq)
            var       = freq{ii};
            freqOfVar = freq{ii+1};
            if ischar(freqOfVar)
                switch lower(freqOfVar)
                    case 'm'
                        freqOfVar = 12;
                    case 'q'
                        freqOfVar = 4;
                    otherwise
                        error([mfilename ':: The frequency assign to the variable ' var ' is wrong. If ',...
                                         'char it must be either ''m'' or ''q''.'])
                end      
            elseif nb_isScalarInteger(freqOfVar)
                if ~any(freqOfVar ~= supp)
                    error([mfilename ':: The input assign to the frequency is wrong. The frequency ' int2str(freqOfVar) ,...
                                     ' assign to the variable ' var ' is not supported.'])
                end
            else
                error([mfilename ':: The frequency assign to the variable ' var ' is wrong. Must be an integer.'])
            end
            indVar = strcmp(var,obj(oo).observables.name);
            if ~any(indVar)
                error([mfilename ':: The input assign to the frequency is wrong. Tried to set the frequency of a variable that is not ',...
                                 'declared in the observables property.'])
            end
            obj(oo).observables.frequency{indVar} = freqOfVar;
        end
        
    end
    obj = reshape(obj,siz);

end
