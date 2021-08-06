function [obj,err] = checkSteadyState(obj,varargin)
% Syntax:
%
% [obj,err] = checkSteadyState(obj,varargin)
%
% Description:
%
% If isNB is true for the nb_dsge object obj, this method must be ran to
% check that your soultion of the steady-state of the model is correct.
%
% Use obj = set(obj,'steady_state_file','filename.m') to give nb_dsge class
% the file that solves the steady-state or 
% obj = checkSteadyState(obj,'steady_state_file','filename.m').
%
% Caution: If no steady-state file is provided and the option 
%          'steady_state_solve' is false a zero for all variable
%          solution will be tested.
%
% Caution: If some variable is not been given any value in the steady-state
%          file it is assumed that it is 0 in steady-state.
% 
% Input:
% 
% - obj                 : An object of class nb_dsge.
% 
% Optional inputs:
%
% - 'silent'            : See nb_dsge.help('silent')
%
% - 'steady_state_file' : See nb_dsge.help('steady_state_file')
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
% Examples:
% 
% See Econometrics\test\DSGE\OptimalPolicy\FRWZ\frwz_nk_nb_steadystate.m
%
% See also:
% nb_dsge.help, nb_dsge.solveSteadyState
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
                obj(ii) = checkSteadyState(obj(ii),report);
            catch Err
                nb_error(['The provided steady-state of model ' names{ii} ' does not solve the steady-state'],Err);
            end
        end
        return
    end
    
    if ~isNB(obj)
        error([mfilename ':: The model is not parsed by the NB Toolbox parser.'])
    end
     
    obj    = set(obj,varargin{:});
    silent = obj.options.silent;

    % Check the validity of the steady-state
    if ~silent
        tic;
        if ~isempty(obj.name)
            disp(['Solving and checking the steady-state of the model ' obj.name '...'])
        else
            disp('Solving and checking the steady-state of the model...')
        end
    end
   
    % Solve steady-state if not already found!
    obj = solveSteadyState(obj);
    
    % Check the validity of the provided steady-state
    err = nb_dsge.checkSteadyStateStatic(obj.estOptions,obj.parameters.value,...
                    obj.options.steady_state_tol,obj.solution.ss,obj.options.steady_state_exo);
    if ~isempty(err)
        if obj.options.steady_state_debug
            dumpSteadyState(obj);
        end
        if nargout < 2
            error('nb_dsge:steadyStateCheckFailed',err,'');
        end
        return
    end
    
    % Report
    if ~silent
        elapsedTime = toc;
        disp(['Correct! Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
    % Indicate that the model need to be re-solved, but that the
    % steady-state is already done.
    obj.needToBeSolved    = true;
    obj.steadyStateSolved = true;
    obj.takenDerivatives  = false;
    
end
