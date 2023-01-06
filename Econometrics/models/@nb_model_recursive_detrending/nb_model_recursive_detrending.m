classdef nb_model_recursive_detrending < nb_model_forecast & nb_modelData
% Description:
%
% Do recursive de-trending of a model and produce recursive forecast based
% on this recursive detrending. The resulting object can be used by
% nb_model_group as a normal nb_model_generic object.
%
% Constructor:
%
% - obj = nb_model_recursive_detrending(model,varargin) 
%
% Input:
%
% - model : An object of a subclass of the nb_model_generic class.
%
% Optional input:
%
% - See the set method for more on the inputs. 
%   (nb_model_recursive_detrending.set)
%
% Output:
%
% - obj : An object of class nb_model_recursive_detrending.
%
% See also:
% nb_model_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % The underlying model to use for forecasting. As a subclass of 
        % the nb_model_generic class.
        model               = [];
        
        % A struct storing all the results of the estimation.
        results             = struct();
        
        % A struct storing the companion form of the model.
        %
        % Y_t = A*Y_t_1 + B*X_t + C*e_t, e ~ N(0,vcv)
        %
        % Observation equation (Factor models only):
        %
        % O_t = F + G*P_t + u_t, u ~ N(0,R)
        %
        % Observation equation (ARIMA models only):
        %
        % X_t = G*Z_t + Y_t
        %
        % Fields:
        %
        % - A     : See the equation above. A nendo x nendo double.
        %
        % - B     : See the equation above. A nendo x nexo double.
        %
        % - C     : See the equation above. A nendo x nres 
        %           double.
        %
        % - endo  : A 1 x nendo cellstr with the decleared endogenous  
        %           variables.
        %
        % - exo   : A 1 x nexo cellstr with the decleared exogenous 
        %           variables.
        %
        % - res   : A 1 x nres cellstr with the decleared 
        %           residuals/shocks.
        %
        % - vcv   : Variance/covariance matrix of the 
        %           residuals/shocks. As a nres x nres double.
        %
        % - class : The name of the model class.
        %
        % Factor models and ARIMA models (only):
        %
        % - factors     : A 1 x nfact cellstr with the estimated  
        %                 factors (exogenous variable in the case of ARIMA
        %                 models).
        %
        % - F           : See the equation above. A nobs x 1 double. 
        %                 (Storing the constant terms of the observation 
        %                 equation)
        %
        % - G           : See the equation above. A nobs x nfact double.
        %                 
        % - observables : A 1 x nobs cellstr with the decleared   
        %                 observable variables.
        %
        % - R           : Variance/covariance matrix of the 
        %                 residuals/shocks of the observation equation. 
        %                 As a nobs x nobs double.
        %
        % DSGE:
        %
        % - ss          : A nendo x 1 double with the steady-state of the 
        %                 model.
        %
        % - jacobian    : A neq x (nforward + nendo + nbackward + nres )
        %                 sparse double storing the jacobian of the model.
        %
        % - jacobianType: A 1 x (nforward + nendo + nbackward + nres )
        %                 indicating the type of each column of the
        %                 jacobian. 1 indicate leaded variables, 0 current
        %                 period variables, -1 indicate lagged variables,
        %                 and 2 indicate residuals (innovations).
        %
        % DSGE (with break-points):
        %
        % In this case the fields A, B, C and ss are all cell arrays with
        % size 1 x nbreaks. Each element has the size in the standard case.
        solution        = struct();
        
    end
    
    properties (Access=protected)
       
        % A vector of nb_model_generic objects with size equal to the 
        % number of recursive periods.
        modelIter           = [];
        
        % Indicator on call to checkReporting method.
        reported            = false;
        
    end
    
    properties
       
        % Adds the posibility to add user data. Can be of any type
        userData        = '';
        
    end
    
    methods
        
        function obj = nb_model_recursive_detrending(model,varargin)
            
            if nargin < 1
                obj.options = nb_model_recursive_detrending.template();
                return
            end
            obj.model   = model;
            obj.name    = model.name;
            obj.options = nb_model_recursive_detrending.template();
            obj         = set(obj,varargin{:});  
            
            % Create identifier for this object
            obj.identifier = nb_model_name.findIdentifier();
            
        end
        
        function s = saveobj(obj)
            s = struct(obj);
        end
        
    end
    
    methods(Hidden)
        
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            name = 'REC_DETREND';
            if numel(obj.model) > 0
                name = [name,'_',createName(obj.model)];
            end
            
        end
        
        function recEndDate = getRecursiveEndDate(obj)
            if isempty(obj.options.recursive_end_date)
                recEndDate = obj.model.options.data.endDate;
            else
                if ischar(obj.options.recursive_end_date)
                    recEndDate = nb_date.date2freq(obj.options.recursive_end_date);
                elseif ~isa(obj.options.recursive_end_date,'nb_date')
                    error([mfilename ':: The recursive_end_date options must either be set to a string date or an object of a subclass of the nb_date class.'])
                else
                    recEndDate = obj.options.recursive_end_date;
                end
            end
        end
        function ret = hasVariables(obj,vars)
            if isempty(obj.modelIter)
                ret = false;
                return
            end
            ret = ismember(vars,obj.modelIter(1).options.data.variables);
        end
    end

    methods(Access=protected)
         
    end
    
    methods(Static=true)
        varargout = help(varargin);
        varargout = template(varargin);
        varargout = unstruct(varargin);
        
        function obj = loadobj(s)
            obj = nb_model_recursive_detrending.unstruct(s);
        end
    end

end
