function obj = derivative(obj,varargin)
% Syntax:
%
% obj = derivative(obj,varargin)
%
% Description:
%
% Calculates the derivatives of the model with respect to the variables
% of the model.
% 
% Caution only first order approximation is supported for the time being.
%
% Input:
% 
% - obj           : An object of class nb_dsge.
% 
% Optional input:
%
% - 'solve_order' : See nb_dsge.help('solve_order')
%
% Output:
%
% - obj : An object of class nb_dsge. See the solution property:
% 
%         > jacobian : Storing the first-order derivatives evaluated at the
%                      steady-state of the DSGE model. The ordering will 
%                      depend on the solver used.
%
%                      > NB Toolbox: See nb_dsge.getDerivOrder
%
% See also:
% nb_dsge.getDerivOrder
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj  = set(obj,varargin{:});
    nobj = numel(obj);
    if nobj > 1
        obj = obj(:);
        for ii = 1:nobj
            obj(ii) = derivative(obj(ii),varargin);
        end
        return
    end

    if ~nb_isScalarInteger(obj.options.solve_order)
        error([mfilename ':: The solve_order must be set to a scalar integer > 1'])
    elseif obj.options.solve_order < 1
        error([mfilename ':: The solve_order must be set to a scalar integer > 1'])
    end
        
    if obj.options.solve_order ~= 1
        error([mfilename ':: For now only first order derivatives are supported. See the solve_order option.'])
    end
    obj.options = nb_defaultField(obj.options,'derivativeMethod','automatic');
    silent      = obj.options.silent;
    if ~silent
        t = tic;
        if strcmpi(obj.options.derivativeMethod,'symbolic') 
            if isfield(obj.parser,'derivativeFunc')
                disp('Evaluating symbolic 1st order derivatives:')
            else
                disp('Calculating symbolic 1st order derivatives:')
            end
        else
            disp('Calculating automatic 1st order derivatives:')
        end
    end
    
    if isNB(obj)
        
        % Symbolic derivatives
        if strcmpi(obj.options.derivativeMethod,'symbolic') 
            if ~isfield(obj.parser,'derivativeFunc')
                [obj.parser.derivativeFunc,obj.parser.derivativeInd] = doSymbolicDerivatives(obj);
            end
            if ~isfield(obj.parser,'obsDerivativeFunc')
                if isfield(obj.parser,'obsEqFunction')
                    [obj.parser.obsDerivativeFunc,obj.parser.obsDerivativeInd] = doSymbolicDerivatives(obj,true);
                end
            end
        end
        obj.solution = nb_dsge.derivativeNB(obj.estOptions.parser,obj.solution,obj.results.beta); 
        
    else
        try
            obj.solution.jacobian = dsge.deriveJacobian(obj.estOptions);
        catch
            error([mfilename ':: Cannot evaluate the derivatives with this version of NB toolbox.'])
        end
    end
    
    obj.takenDerivatives = true;
    
    if ~silent
        elapsedTime = toc(t);
        disp(['Finished in ' num2str(elapsedTime) ' seconds'])
    end
     
end
