function obj = setMeasurementEqRestriction(obj,restrictions)
% Syntax:
%
% obj = setMeasurementEqRestriction(obj,restrictions)
%
% Description:
%
% Add restrictions in the measurement equation of the model on the form;
%
% restricted = parameters*variables'
%
% e.g.
%
% X = [0.5,0.5]*[Y;Z]
%
% where X is a observed variable, while Y and Z are state variables.
% So for a mixed frequency var, X and Y must be included in the state 
% equation. An error is provided if this is not the case!
%
% For the xxxMF priors this information is taken into account, otherwise
% it will only be used during conditional forecasting, i.e. the measurement
% restrictions will be appended to the solution after estimation is done. 
%
% See nb_var.priorTemplate for more on the supported priors.
%
% Input:
% 
% - obj          : An object of class nb_var
%
% - restrictions : A struct array with fields 
%                  > 'restricted' : A one line char with the varible to
%                                   restrict. It must be a dependent
%                                   variable or block exogenous variable.
%                  > 'parameters' : A cellstr with the names of the
%                                   variables storing the parameters of the
%                                   restriction, or a double array. Must
%                                   have same length as 'variables'.
%                  > 'variables'  : A cellstr with the names of the
%                                   variables included in the restriction.
%                  > 'frequency'  : Set to the frequency of the
%                                   observables. This is only important
%                                   for the mixed frequency VAR model. 
%                                   Give [], if the restriction is on the
%                                   same frequency as the data. Either
%                                   1 (yearly), 4 (quarterly) or 12 
%                                   (monthly).
%                  > 'mapping'    : Sets the mapping to use for this 
%                                   restricted variable. See the method
%                                   nb_mfvar.setMapping for more on the
%                                   mappings to choose from.
%                  > 'R_scale'    : Inverse prior scale of the variance 
%                                   of the measurement error of this
%                                   restrictions. 
%                                   
%                                   The variance of the measurement error 
%                                   is constructed by dividing the
%                                   variance of each 'restricted' variable 
%                                   by this scaling parameter.
% 
% Output:
% 
% - obj          : An object of class nb_var where the measurement equation 
%                  restrictions are added.
%
% See also:
% nb_var.template, nb_bVarEstimator.applyMeasurementEqRestriction,
% nb_var.priorTemplate, nb_mfvar.setMapping
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(restrictions)
        return
    end
    if ~isstruct(restrictions)
        error('The input assigned to the measurementEqRestriction option must be a struct array.')
    end
    if ~isfield(restrictions,{'restricted','parameters','variables','R_scale'})
        error(['The input assigned to the measurementEqRestriction option must ',...
               'be a struct array with fields ''restricted'', ''parameters''',...
               '''R_scale'' and ''variables''.'])
    end
    
    nobj = numel(obj);
    obj  = obj(:);
    for oo = 1:nobj
        for ii = 1:length(restrictions) 
            if ~nb_isOneLineChar(restrictions(ii).restricted)
                error(['The restricted field of the measurementEqRestriction ',...
                    'options must be set to a one line char, element ' int2str(ii) '.'])
            end
            if ~(iscellstr(restrictions(ii).parameters) || ...
                    isnumeric(restrictions(ii).parameters))
                error(['The parameters field of the measurementEqRestriction ',...
                       'must be set to a cellstr or a double array, element ' int2str(ii) '.'])
            end
            if ~isvector(restrictions(ii).parameters)
                error(['The parameters field of the measurementEqRestriction ',...
                       'must be a vector, element ' int2str(ii) '.'])
            end
            if ~iscellstr(restrictions(ii).variables)
                error(['The variables field of the measurementEqRestriction ',...
                       'must be set to a cellstr, element ' int2str(ii) '.'])
            end
            if ~isvector(restrictions(ii).variables)
                error(['The variables field of the measurementEqRestriction ',...
                       'must be a vector, element ' int2str(ii) '.'])
            end
            if length(restrictions(ii).parameters) ~= length(restrictions(ii).variables)
                error(['The length of the parameters and variables fields of ',...
                       'the measurementEqRestriction must be equal, element ' int2str(ii) '.'])
            end
            if isfield(restrictions(ii),'frequency')
                if ~(nb_isScalarInteger(restrictions(ii).frequency) || ...
                        isempty(restrictions(ii).frequency))
                    error(['The frequency field of the measurementEqRestriction ',...
                        'options must be set to a scalar integer, element ' int2str(ii) '.'])
                end
            end
            if isfield(restrictions(ii),'mapping')
                if ~nb_isOneLineChar(restrictions(ii).mapping)
                    error(['The mapping field of the measurementEqRestriction ',...
                        'options must be set to a one line char, element ' int2str(ii) '.'])
                end
            else
                if isfield(restrictions(ii),'frequency')
                    error(['If the frequency field of the measurementEqRestriction ',...
                        'options is used you also need to set the mapping field, element ' int2str(ii) '.'])
                end  
            end
            if ~nb_isScalarNumber(restrictions(ii).R_scale,0)
                error(['The R_scale field of the measurementEqRestriction ',...
                       'must be a scalar positive number, element ' int2str(ii) '.'])
            end
        end
        obj(oo).options.measurementEqRestriction = restrictions;
    end
    
end
