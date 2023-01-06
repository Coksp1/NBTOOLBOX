function obj = extrapolate(obj,toDate,varargin)
% Syntax:
%
% obj = extrapolate(obj,toDate)
% obj = extrapolate(obj,toDate,varargin)
%
% Description:
%
% Extrapolate the time-series.
%
% Input:
% 
% - obj          : An object of class nb_dateInExpr
% 
% - toDate       : Extrapolate to the given date. If the date is before the
%                  end date of the given variable no changes will be made,
%                  and with no warning. Can also be a integer with the
%                  number of periods to extrapolate.
%
% Optional inputs:
%
% - Any
%
% Output:
% 
% - obj          : An nb_dateInExpr object.
% 
% Examples:
%
% obj = nb_dateInExpr('2000M1');
% obj = extrapolate(obj,'2004M3');
% obj = extrapolate(obj,'2004M3','method','ar');
% obj = extrapolate(obj,'low','method','ar','freq',4);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    types   = {'flow','stock','test'};
    default = {'alpha',     0.05,   @(x)nb_isScalarNumber(x,0);...
               'constant',  false,  @nb_isScalarLogical;...
               'draws',     1000,   @(x)nb_isScalarInteger(x,0);...
               'freq',         1,   @(x)nb_isScalarInteger(x,0);...
               'method',    'end',  @nb_isOneLineChar;...   
               'nLags',     5,      @(x)nb_isScalarInteger(x,0);...
               'takeLog',   false,  @nb_isScalarLogical;...
               'type',      'flow', @(x)nb_ismemberi(x,types)};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Interpret the toDate input
    if isempty(toDate)
        error([mfilename ':: toDate cannot be empty.'])
    else
        if nb_isScalarInteger(toDate)
            nPeriods = round(toDate);
            toDate   = obj.date + nPeriods;
        elseif nb_isOneLineChar(toDate)
            if strcmpi(toDate,'low')
                if inputs.freq > obj.date.frequency
                    error([mfilename ':: The ''freq'' input must be a ',...
                        'frequency that is lower than the object itself.'])
                end
                endDateLow = convert(obj.date,inputs.freq);
                toDate     = convert(endDateLow,obj.date.frequency,false);
            else
                toDate = nb_date.toDate(toDate,obj.date.frequency);
            end
        elseif isa(toDate,'nb_date')
            if toDate.frequency ~= obj.frequency
                error([mfilename ':: The toDate input must be of the same frequency as the object itself.'])
            end
        end
    end
    obj.date = nb_date.max(obj.date,toDate);
       
end
