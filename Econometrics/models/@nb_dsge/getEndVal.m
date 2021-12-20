function ss = getEndVal(obj,varargin)
% Syntax:
%
% ss = getEndVal(obj,varargin)
%
% Description:
%
% Get end values when doing permanent shocks, i.e. resolve the steady-state
% given some values of the exogenous variables.
%
% The initial values that are used is the steady-state of the original
% model.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
%
% Optional input:
%
% Most relevant options are;
% 
% - 'steady_state_block' : See nb_dsge.help('steady_state_block'). Default
%                          is to use the current value of the 
%                          'steady_state_block'.
%
% - 'steady_state_exo'   : See nb_dsge.help('steady_state_exo'). Must be
%                          provided!
% 
% - 'homotopyAlgorithm'  : See nb_dsge.help('homotopyAlgorithm'). Default
%                          is 0, i.e. no homotopy.
%
% - 'homotopySteps'      : The number of homotopy steps. Default is 10.
%
% Caution : The homotopy option 'homotopySetup' does not do anything in
%           this method!
% 
% Output:
% 
% - ss     : A struct with the new full steady-state solution.
%
% See also:
% nb_dsge.set, nb_dsge.help
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method is only supported for a scalar nb_dsge object.'])
    end
    if ~isNB(obj)
        error([mfilename ':: This method is only supported for a DSGE model that has been parsed with NB Toolbox.'])
    end
    if isBreakPoint(obj)
        error([mfilename ':: Cannot call this method on a DSGE model with break-points.'])
    end
    if ~isfield(obj.solution,'ss')
        error([mfilename ':: You need to solve the initial steady-state first, as it is used as the initial ',...
                         'condition for find the end values. See the checkSteadyState method.'])
    end
    
    silent = obj.options.silent;
    if ~silent
        tic;
        if ~isempty(obj.name)
            disp(['Solving the end point problem of the model ' obj.name '...'])
        else
            disp('Solving the end point problem of the model...')
        end
    end
    
    % Get the options
    [steady_state_exo,varargin]  = nb_parseOneOptional('steady_state_exo',[],varargin{:});
    [homotopyAlgorithm,varargin] = nb_parseOneOptional('homotopyAlgorithm',0,varargin{:});
    [homotopySteps,varargin]     = nb_parseOneOptional('homotopySteps',10,varargin{:});
    if nb_isempty(steady_state_exo)
        
        % Just return the initial steady-state that is already found!
        ss = obj.solution.ss;
        ss = cell2struct(num2cell(ss),obj.parser.endogenous(~obj.parser.isAuxiliary));
        return
        
    end
    
    % Set object options
    obj = set(obj,varargin{:});
    
    % Get the final options
    options                    = obj.options;
    options.homotopyAlgorithm  = homotopyAlgorithm;
    options.homotopySteps      = homotopySteps;
    options.steady_state_init  = getSteadyState(obj,'','struct');
    options.steady_state_solve = true;
    options.steady_state_exo   = steady_state_exo;
    
    % Get the homotopy setup
    if homotopyAlgorithm > 0
        homotopyNames         = fieldnames(steady_state_exo);
        options.homotopySetup = [homotopyNames,struct2cell(steady_state_exo)];
    else
        options.homotopySetup = {};
    end
    
    % Solve for the new steady-state
    pKnown     = getParameters(obj,'struct','reverse');
    [ss,~,err] = nb_dsge.solveSteadyStateStatic(obj.parser,options,pKnown,false);
    if ~isempty(err)
        error([mfilename '::' err])
    end
    
    % Check steady-state
    err = nb_dsge.checkSteadyStateStatic(obj.estOptions,obj.parameters.value,...
                    obj.options.steady_state_tol,ss,options.steady_state_exo);
    if ~isempty(err)
        if obj.options.steady_state_debug
            endo = obj.parser.endogenous';
            ss   = nb_ss(obj.solution.ss);
            for ii = 1:size(endo,1)
                assignin('base',endo{ii},ss(ii));
            end
            param = obj.getParameters();
            for ii = 1:size(param,1)
                assignin('base',param{ii,1},param{ii,2});
            end
        end
        if nargout < 2
            error('nb_dsge:steadyStateCheckFailed',err,'');
        end
        return
    end
    
    % Return the steady-state
    ss = cell2struct(num2cell(flip(ss,1)),flip(obj.parser.endogenous,2));
    if ~silent
        elapsedTime = toc;
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
    
end
