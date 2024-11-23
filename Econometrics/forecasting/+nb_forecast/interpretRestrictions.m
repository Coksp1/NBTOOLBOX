function [bounds,indY] = interpretRestrictions(bounds,endo,shocks)
% Syntax:
%
% [bounds,indY] = nb_forecast.interpretRestrictions(bounds,endo,shocks)
%
% Description:
%
% Interpret the restrictions given on bounded variables, e.g. zero lower
% bound
%
% See also:
% nb_forecast.setUpForBoundedForecast,
% nb_forecast.boundedConditionalProjectionEngine
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    fields = fieldnames(bounds);
    indY   = zeros(1,length(fields));
    for ii = 1:length(fields)

        bound = bounds.(fields{ii});
        if ~isstruct(bound)
            error([mfilename ':: All fields of the bounds structure must be a struct.'])
        end

        varName = fields{ii};
        ind     = find(strcmp(varName,endo));
        if isempty(ind)
            error([mfilename ':: The variable ' varName ' is not an endogenous variable of the model.'])
        end
        bound.endoInd = ind;
        indY(ii)      = ind;

        ret = isfield(bound,'shock');
        if ~ret
            error([mfilename ':: The variable ' varName ' has not been decleard a matching shock. Use the field shock.'])
        end

        shockName = bound.shock;
        ind       = find(strcmp(shockName,shocks));
        if isempty(ind)
            error([mfilename ':: The shock ' shockName ' is not part of the model. You try to match it with ' varName])
        end
        bound.exoInd = ind;

        ret = isfield(bound,'lower');
        if ~ret
            bound.lower = -inf; 
        end

        ret = isfield(bound,'upper');
        if ~ret
            bound.upper = inf; 
        end

        ret = isfield(bound,'half');
        if ~ret
            bound.half = false; 
        end
        
        bounds.(fields{ii}) = bound;

    end

end
