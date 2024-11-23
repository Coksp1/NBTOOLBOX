function [regularization,obj] = getRegularization(obj,varargin)
% Syntax:
%
% regularization       = getRegularization(obj)
% [regularization,obj] = getRegularization(obj,varargin)
%
% Description:
%
% Calibrate regularization coefficient used for LASSO estimation.
% 
% LASSO solves the constrained optimization problem:
%
% min (y - X*beta)^2 
% s.t. sum(abs(beta)) <= 1/t
%
% If we estimate beta by OLS, and from that calculate the t from the
% constraint (t_ols), we get the value of t that does not constrain the 
% LASSO estimation. The calibrated value will be returned as; t/perc.
%
% Caution: The option recursive_estim will be set to false!
%
% Input:
%
% - obj : A scalar nb_model_generic object that can be estimated by
%         LASSO!
%
% Optional input:
%
% - 'perc'        : The value used to calibrate the regularization 
%                   coefficient. Must be a scalar number 0 < x < 1.  
%                   Default is 0.5.
%
% - 'grid'        : If you want to set up a grid of regularization  
%                   coefficients, set this input to a scalar integer. This  
%                   will set the number of grid points. The grid will be  
%                   set up in the interval [t_ols/gridPercMax, 
%                   t_ols/gridPerc]. Default is 1, i.e. do not set up a 
%                   grid.
%
% - 'gridPerc'    : See the doc of the 'grid' input. Must be a scalar 
%                   number 0 < x < 1. Default is 0.1.
%
% - 'gridPercMax' : See the doc of the 'grid' input. Must be a scalar 
%                   number 0 < x < 1. Default is 0.9.
%
% Output:
% 
% - regularization : A double vector with size 1 x G, where G is the value
%                    of the 'grid' input.
%
% - obj            : Return a nb_model_generic vector with size 1 x G,
%                    where G is the value of the 'grid' input. These
%                    models has been assign the regularization
%                    coeffiecient of the grid points. See the 
%                    regularization of the options property of these
%                    objects.
%
% See also:
% nb_lasso
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Parse inputs
    default = {'perc',        0.5,  @(x)nb_isScalarNumber(x,0,1);...
               'grid',        1,    @(x)nb_iswholenumber(x);...
               'gridPerc',    0.1,  @(x)nb_isScalarNumber(x,0,1);...
               'gridPercMax', 0.9,  @(x)nb_isScalarNumber(x,0,1)};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    if ~isscalar(obj)
        error('Input must be a scalar nb_model_generic object.')
    end

    % Check that the class supports LASSO estimation
    if not(isa(obj,'nb_var') || isa(obj,'nb_midas') || isa(obj,'nb_singleEq') || isa(obj,'nb_sa'))
        error(['The class ' class(obj) ' does not support LASSO!'])
    end

    % Set up calibration estimation
    if isa(obj,'nb_midas')
        obj = set(obj,'algorithm','unrestricted');
    else
        obj = set(obj,'estim_method','ols');
    end
    recursive_estim = obj.options.recursive_estim;
    obj             = set(obj,'recursive_estim',false);

    % Estimate
    obj  = estimate(obj);
    beta = obj.results.beta;
    if obj.options.restrictConstant
        const = obj.options.constant;
    else
        const = 0;
    end
    t_ols = 1./sum(abs(beta(const+1:end,:)),1); % Constant is unrestricted!
    if inputs.grid > 1
        % Set up grid
        numEq  = size(beta,2);
        t_high = t_ols./inputs.gridPerc;
        t_low  = t_ols./inputs.gridPercMax;
        t      = nan(inputs.grid,numEq);
        for ii = 1:numEq
            t(:,ii) = t_low(ii):(t_high(ii)-t_low(ii))/(inputs.grid - 1):t_high(ii);
        end
        if const
            t = 1./(1./t + abs(beta(ones(inputs.grid,1),:)));
        end
    else
        % Calibrate
        t = t_ols./inputs.perc;
        if const
            t = 1./(1./t + abs(beta(1,:)));
        end
    end
    regularization = t;

    % Reset
    if isa(obj,'nb_midas')
        obj = set(obj,'algorithm','lasso');
    else
        obj = set(obj,'estim_method','lasso');
    end
    obj = set(obj,'recursive_estim',recursive_estim);

    if nargout > 1

        % Set up models
        obj = obj(1,ones(1,inputs.grid));
        for ii = 1:inputs.grid
            obj(ii).options.regularization = t(ii,:);
        end

    end

end
