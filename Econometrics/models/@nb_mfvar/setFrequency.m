function obj = setFrequency(obj,freq)
% Syntax:
%
% obj = setFrequency(obj,freq)
%
% Description:
%
% Set the frequency of the decleared dependent and/or block_exogenous
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
% - obj  : An object of class nb_mfvar.
%
% - freq : A cellstr on the format; {'Var1',1,'Var2',4}. There is no need
%          to set the frequency of those variables that has the same
%          frequency as the data (options.data)!
%
%          You can also declare that one variable change frequency using
%          the syntax {'Var1',1,'Var2',{4,cDate,12}}. Here date must be
%          a nb_date object or date string on the same frequency as the
%          data property. It is interpreted as the variable 'Var2' has
%          quarterly frequency until and including the date cDate, from
%          there it has monthly frequency. See example NBTOOLBOX\...
%          Examples\Econometrics\MixedFrequency\test_nb_mfvar_changeFreq.m
% 
% Output:
% 
% - obj : An object of class nb_mfvar where the frequency of a set of
%         variables has been set. See the dependent and block_exogenous
%         properties.
%
% See also:
% nb_mfvar.setMapping
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
            if iscell(freqOfVar)
                if size(freqOfVar,2) ~= 3
                    error([mfilename ':: The input assign to the frequency is wrong. The frequency assign to the variable ' var ...
                                     ' must be a 1x3 cell array if given as a cell array.'])
                end
                if nb_isScalarInteger(freqOfVar{1})
                    if ~any(freqOfVar{1} ~= supp)
                        error([mfilename ':: The frequency ' int2str(freqOfVar{1}) ' assign to the first element of the frequency ',...
                                         'options of the variable ' var ' is not supported.'])
                    end
                else
                    error([mfilename ':: The input assign to first element of the frequency for the variable ' var ...
                                     ' must be a scalar integer.'])
                end
                if nb_isScalarInteger(freqOfVar{3})
                    if ~any(freqOfVar{3} ~= supp)
                        error([mfilename ':: The frequency ' int2str(freqOfVar{3}) ' assign to the first element of the frequency ',...
                                         'options of the variable ' var ' is not supported.'])
                    end
                else
                    error([mfilename ':: The input assign to first element of the frequency for the variable ' var ...
                                     ' must be a scalar integer.'])
                end
                if isa(freqOfVar{2},'nb_date')
                    % Do nothing
                elseif nb_isOneLineChar(freqOfVar{2})
                    try
                        freqOfVar{2} = nb_date.date2freq(freqOfVar{2});
                    catch 
                        error([mfilename ':: The input assign to second element of the frequency for the variable ' var ...
                                     ' could not be converted to a date; ' freqOfVar{2}])
                    end
                else
                    error([mfilename ':: The input assign to second element of the frequency for the variable ' var ...
                                     ' must be either a nb_date object or a date string.'])
                end
                
            elseif nb_isScalarInteger(freqOfVar)
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
                indVar = strcmp(var,obj(oo).block_exogenous.name);
            end
            if ~any(indVar)
                error([mfilename ':: The input assign to the frequency is wrong. Tried to set the frequency of a variable (' var ') that is not dependent nor block_exogenous.'])
            end
            if isDep
                obj(oo).dependent.frequency{indVar} = freqOfVar;
            else
                obj(oo).block_exogenous.frequency{indVar} = freqOfVar;
            end
            
        end
        
    end

end
