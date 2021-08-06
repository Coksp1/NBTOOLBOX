function [obj,err] = solveSteadyState(obj,varargin)
% Syntax:
%
% [obj,err] = solveSteadyState(obj,varargin)
%
% Description:
%
% If the 'steady_state_solve' is set to true, the solution will be solved
% for analytically. If the 'steady_state_file' option is not empty, it is
% assumed to provided the solution (see comment below also!). If neither
% of them is used the steady-state is assumed to be 0 for all variables.
%
% Caution: This function is automatically called inside 
%          nb_dsge.checkSteadyState if the option 'steady_state_solve' is 
%          set to true and is not called by the user manually!
%
% Caution: If the 'steady_state_file' option is not empty and the option 
%          'steady_state_solve' is set to true, the provided file 
%          will be used as the starting point for the solver, i.e.
%          use this file can be used to set initial values for the 
%          solution of the steady-state.
% 
% Caution: If some variable is not been given any value in the 
%          steady-state file it is assumed that it is 0 in steady-state.
% 
% Input:
% 
% - obj                  : An object of class nb_dsge.
% 
% Optional inputs:
%
% - 'silent'             : See nb_dsge.help('silent')
%
% - 'steady_state_file'  : See nb_dsge.help('steady_state_file')
%
% - 'steady_state_solve' : See nb_dsge.help('steady_state_solve')
%
% - 'solver'             : See nb_dsge.help('solver')
%
% Output:
% 
% - obj : An object of class nb_dsge, where the solution of the
%         steady-state can be found at obj.solution.ss.
%
% - err : If two outputs are called for a potential error message is not
%         thrown, but instead return as a string. Is empty if not error
%         occure. Caution: This is only the case if numel(obj) == 1.
%
%
% See also:
% nb_dsge.help, nb_dsge.checkSteadyState, nb_dsge.solveSteadyStateStatic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    err  = '';
    obj  = obj(:);
    nobj = numel(obj);
    if nobj > 1
        names = getModelNames(obj);
        for ii = 1:nobj
            try
                obj(ii) = solveSteadyState(obj(ii),report);
            catch Err
                nb_error(['Could not solve for the steady-state of model ' names{ii} '.'],Err);
            end
        end
        return
    end
    
    if ~isNB(obj)
        error([mfilename ':: The model is not parsed by the NB Toolbox parser.'])
    end
    
    % Initial check and create the eqFunction to evaluate derivatives
    % and steady-state
    obj = checkModelEqs(obj);
    obj = createEqFunction(obj);
    
    % Set options
    obj = set(obj,varargin{:});
    if ~isempty(obj.options.steady_state_file)
        if ~(isa(obj.options.steady_state_file,'function_handle') || ischar(obj.options.steady_state_file))
            error([mfilename ':: The steady_state_file option must be set to either a string or a function_handle object.'])
        end
    end
    
    % Provide the steady-state growth rates, if we are dealing with a 
    % non-stationary model (in the model file)
    if ~isempty(obj.parser.unitRootVars)
        varsWithTrend = regexprep(obj.parser.growthVariables,['^', nb_dsge.growthPrefix],'');
        [~,loc]       = ismember(varsWithTrend,[obj.parser.originalEndogenous,obj.parser.unitRootVars]);
        for ii = 1:length(varsWithTrend)
            obj.options.steady_state_init.(obj.parser.growthVariables{ii}) = obj.solution.bgp(loc(ii));
        end
    end
    
    % Check if we are dealing
    if isfield(obj.solution,'bgp')
        bgp = struct('rates',obj.solution.bgp,'variables',{[obj.parser.originalEndogenous,obj.unitRootVariables.name]});
    else
        bgp = [];
    end
    
    % Get the steady-state values
    pKnown                = getParameters(obj,'struct','reverse','skipBreaks');
    [ss,p,err,obj.parser] = nb_dsge.solveSteadyStateStatic(obj.parser,obj.options,pKnown,true,bgp);
    if ~isempty(err)
        if nargout < 2
            if obj.options.steady_state_debug
                dumpSteadyState(obj,ss);
            end    
            ss     = nb_dsge.assignSteadyState(obj.parser,ss);
            errEqs = nb_dsge.checkSteadyStateStatic(obj.estOptions,obj.parameters.value,...
                    obj.options.steady_state_tol,ss,obj.options.steady_state_exo);
            error('nb_dsge:solvingSteadyStateFailed',[err,'\n',errEqs],'');
        end
        return
    end
    
    % Assign values of parameters solved for in the steady-state
    if ~nb_isempty(p)
        obj = assignParameters(obj,p);
    end
    
    % Save the steady-state to the object
    obj.solution.ss = ss;
     
end
