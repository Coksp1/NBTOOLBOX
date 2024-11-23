classdef nb_var < nb_model_generic
% Description:
%
% A class for estimation and identification of VAR models.
%
% OLS estimated VAR models uses the package nb_olsEstimator, while
% if you select the maximum likelihood estimator the nb_mlEstimator
% package is used.
%
% The bayesian VARs are estimated using code that are based on code from
% a paper by Koop and Korobilis (2009), Bayesian Multivariate Time Series 
% Methods for Empirical Macroeconomics. These code are extended to handle
% block exogenous variables, priors for the long run, and missing
% observations. See the nb_bVarEstimator package for the implementation.
% 
% The code of the identifiction algorithm is based on code provided by 
% Andrew Binning, see paper Binning (2013), "Underidentified SVAR models:  
% A framework for combining short and long-run restrictions with 
% sign-restrictions". See the method nb_var.ABidentification for the
% implementation. We extend Binning (2013) to also allow for magnitude
% restrictions. 
%
% Superclasses:
%
% nb_model_generic
%
% Constructor:
%
%   obj = nb_var(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_var object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, nb_olsEstimator.estimate,
% nb_bVarEstimator.estimate, nb_mlEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the block exogenous 
        % variables, the tex_name holds the names in the tex format. The 
        % number field holds a double with the number of block exogenous 
        % variables. To set it use the set function. E.g. obj = 
        % set(obj,'block_exogenous',{'Var1','Var2'}); or use the 
        % <className>.template() method.
        block_exogenous     = struct(); 
        
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the factors, 
        % the tex_name holds the names in the tex format. The 
        % number field holds a double with the number of factors. To set 
        % it use the set function. E.g. obj = set(obj,'factors',
        % {'Var1','Var2'}); or use the <className>.template() method.
        factors             = struct(); 

    end
    
    methods
        
        function obj = nb_var(varargin)
        % Constructor

            obj                         = obj@nb_model_generic();
            temp                        = nb_var.template();
            temp                        = rmfield(temp,{'dependent','exogenous'});
            obj.options                 = temp;
            temp                        = struct();
            temp.name                   = {};
            temp.tex_name               = {};
            temp.number                 = [];
            temp.block_id               = [];
            temp.num_blocks             = 0;
            obj.block_exogenous         = temp;
            temp                        = struct();
            temp.name                   = {};
            temp.tex_name               = {};
            temp.number                 = [];
            obj.factors                 = temp;
            obj.solution.identification = struct();
            obj                         = set(obj,varargin{:});
            
            if ~nb_isempty(obj.options.prior)
                if strcmpi(obj.options.prior.type,'kkse')
                    obj.options.estim_method = 'tvpmfsv';
                else
                    obj.options.estim_method = 'bVar';
                end
            end
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            if ~nb_isempty(obj.options.prior)
                name = ['B_VAR_', upper(obj.options.prior.type)];
            else
                if strcmpi(obj.options.estim_method,'ml')
                    name = 'ML_VAR';   
                else
                    name = [upper(obj.options.estim_method),'_VAR'];
                    switch lower(obj.options.missingMethod)
                        case 'forecast'
                            name = [name ,'_F'];
                        case 'kalmanfilter'
                            name = [name ,'_KF'];
                    end
                end
            end
            name = [name ,'_V' int2str(nb_conditional(isempty(obj.dependent.number), 0, obj.dependent.number))];
            if isempty(obj.options.modelSelection)
                name = [name ,'_L' int2str(obj.options.nLags)];
            else
                name = [name ,'_MS'];
            end
            if ~isempty(obj.options.rollingWindow)
                name = [name ,'_RW' int2str(obj.options.rollingWindow)];
            end
            
        end
        
    end
    
    methods(Access=protected)
       
        function param = getParametersNames(obj)
            
            % Construct the coeff names
            if nb_isempty(obj.estOptions) || nb_isempty(obj.results)
                param = struct('name',{{}},'value',[]);
            else
                
                % Get the parameter names and values of the VAR
                [s1,s2,s3] = size(obj.results.beta);
                pName      = nb_bVarEstimator.getCoeff(obj.estOptions(end),'priors');
                pVal       = reshape(obj.results.beta,[s1*s2,1,s3]);
                
                % Get the parameter names and values of the covariance
                % matrix of the VAR
                secDim     = [obj.estOptions(end).dependent,obj.estOptions(end).block_exogenous]';
                [s1,s2,s3] = size(obj.results.sigma);
                pName2     = strcat('cov_',nb_strcomb(secDim,secDim));
                pVal2      = reshape(obj.results.sigma,[s1*s2,1,s3]);
                pName      = [pName;pName2];
                pVal       = [pVal;pVal2];
                
                param = struct('name',{pName},'value',pVal);
                
            end
            
        end
          
        varargout = wrapUpEstimation(varargin);
        
    end
    
    methods(Static=true)
        
        varargout = ABidentification(varargin)        
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)
        varargout = stateSpace(varargin)
        varargout = template(varargin)
        varargout = priorHelp(varargin)
        varargout = priorTemplate(varargin)
        varargout = help(varargin)
        
    end
    
    methods(Static=true,Hidden=true)
        
        function priors = mfPriors()      
            priors = {'minnesotaMF','nwishartMF','inwishartMF','glpMF','kkse'};
        end
        
    end
         
end

