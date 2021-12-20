function obj = addEquation(obj,varargin)
% Syntax:
% 
% obj = addEquation(obj,varargin)
%
% Description:
%
% Add more equations to the model.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
%
% Optional input:
%
% - 'endogenous'   : A char or cellstr with the added endogenous 
%                    variable(s).
%
% - 'exogenous'    : A char or cellstr with the added exogenous variable(s).
% 
% - 'parameters'   : A char or cellstr with the added parameter(s).
%
% - 'equations'    : A char or cellstr with the added equation(s).
%
% - 'steady_state' : A double with the same length as the number of added
%                    endogenous variables (and in the same order!). This
%                    will use the 'steady_state_fixed' option, so do not
%                    override it!
%
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_dsge.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: The obj input must be a scalar nb_dsge object.'])
    end
    
    if rem(length(varargin),2) ~= 0
        error([mfilename ':: The number of optional arguments must come in pairs.'])
    end
    
    newEndo     = {};
    newExo      = {};
    newParam    = {};
    newEqs      = {};
    steadyState = [];
    for ii = 1:2:length(varargin)
        
        type  = varargin{ii};
        input = varargin{ii+1};

        if strcmpi(type,'steady_state')
            
            if ~isnumeric(input)
                error([mfilename ':: The input given to the specification ' type ' must be double.'])
            end
            steadyState = input(:)';
            
        else
        
            if ischar(input)
                input = cellstr(input);
            elseif ~iscellstr(input)
                error([mfilename ':: The input given to the specification ' type ' must be either a char or a cellstr array.'])
            end

            switch lower(type)  
                case 'endogenous' 
                    newEndo = input(:)';
                case 'exogenous'
                    newExo = input(:)';
                case 'parameters' 
                    newParam = input(:)';    
                case 'equations' 
                    newEqs = input(:);
                otherwise
                    error([mfilename ':: Unsupported classification ' type '.'])
            end
            
        end
        
    end
    
    if ~isempty(obj.parser.unitRootVars)
        % Revert to the non-stationary representation of the model
        obj = revert2NonStationary(obj);
    end
    
    % Add the new equation
    parser            = obj.estOptions.parser;
    newEqs            = nb_model_parse.removeEquality(newEqs);
    parser.equations  = [parser.equations;newEqs];
    [paramS,paramI]   = sort([parser.parameters,newParam]);
    parser.parameters = flip(paramS,2);
    paramI            = flip(paramI,2);
    parser.endogenous = [parser.endogenous(~parser.isAuxiliary),newEndo];
    parser.exogenous  = [parser.exogenous,newExo];
    
    % Get lead/lag incidence
    parser = nb_dsge.getLeadLag(parser);
    if ~isempty(obj.parser.obs_equations)
        parser = nb_dsge.getLeadLagObsModel(parser,true);
    else
        parser.all_endogenous  = parser.endogenous;
        parser.all_exogenous   = parser.exogenous;
        parser.all_isAuxiliary = parser.isAuxiliary;
    end
    
    % Indicate the static representation of the model has changed. (This 
    % will trigger it being created again in nb_dsge.solveSteadyStateStatic)
    parser.createStatic = true;
    
    % Update nb_dsge object
    parser.observables  = obj.observables.name;
    obj                 = updateObject(obj,parser,paramI);
    parser              = rmfield(parser,'observables');
    obj.parser          = parser;
    
    % Steady-state
    if ~isempty(steadyState)
        if size(steadyState,2) ~= size(newEndo,2)
            error([mfilename ':: The ''steady_state'' must have length ' int2str(size(newEndo,2)) ', but has length ' int2str(size(steadyState,2))])
        end
        for ii = 1:size(steadyState,2)
           obj.options.steady_state_fixed.(newEndo{ii}) = steadyState(ii);
        end
    end
    
    % Indicate the model need to be resolved
    obj = indicateResolve(obj);
    
end
