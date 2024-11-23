classdef nb_fmdyn < nb_model_generic & nb_factor_model_generic & nb_calculate_generic
% Description:
%
% A class for estimation of dynamic factor models on the form:
%
% X(t)   = B*W(t) + L*F(t) + eps(t)     (1)
% eps(t) = alpha*eps(t-1) + e(t)    (2)
% F(t)   = A*F(t-1) + u(t)          (3)
%
% where 
%
% > The data is assumed to have T observations. Some may be missing, and
%   have different frequencies.
% > X(t) is a vector of observed data with size N x 1. 
% > W(t) are the exogneous variables of the model, here the constant term 
%   will be included. W(t) has size NE x 1.
% > B is a matrix with size N x NE.
% > F(t) is the unobserved factors with size R*(nLags-1) x 1 (see comment  
%   on the A matrix), i.e. R is the number of factors to be estimated.
% > L is the factor loadings with size N x R*(nLags-1). Zero restrictions 
%   as in Banbura et al. (2010b) may be applied, and zeros will be added to 
%   be consistent with the comment for the matrix A. L may also be adjusted
%   to allow for mixed frequencies, again following the procedure of 
%   Banbura et al. (2010b).
% > e(t) ~ N(0,Sigma) for a diagonal covariance matrix Sigma.
% > alpha is a diagonal matrix of AR(1) parameters of the ideosyncartic
%   component of each variable in X. Optional. If turned of, it is assumed
%   that eps(t) ~ N(0,Sigma)
% > u(t) ~ N(0,Q), and is the residuals of the VAR model of the factors.
% > A is a matrix with size R*(nLags-1) x R*(nLags-1), where nLags is the
%   selected number of lags of the VAR of the factors, i.e. 
%   F(t) = [f(t),f(t-1),...,f(t-nLags)]. 
% > Let beta be the full set of parameters to estimate, and zeta(t) the
%   full set of unobserved state variables the model can be put on the 
%   form
%
%   X(t)    = mu + Z(beta)*zeta(t)         (4)
%   zeta(t) = T(beta)*zeta(t-1) + eta(t)   (5)
%
% The model can either be estimated using a two step frequentistic  
% algorithm, a bayesian gibbs sampling algorithm or the algorithm
% suggested by Koop and Korobilis (2014) extended by Schroder 
% and Eraslan (2021) to handle mixed frequency.
% 
% 1. Follows the two step procedure of Banbura et al. (2010a). First some 
%    initial values of the factors has to be estimated by principal 
%    components on a balanced datasets of X. Here we use a spline method
%    to fill in the missing values. As this is only used to initialize the
%    algorithm it is not of any more inportance than the speed up of the
%    convergence of the estimation algorithm. eps(t) is then estimated 
%    from using (1). From there parameters are then intiaialized with the 
%    ols estimator based on the inital values of the factors. The first  
%    step of ML algorithm is then to filter/smooth out the zeta(t)
%    given beta, and then use the expected maximum likelihood estimator
%    on beta given the filtered values of zeta(t). This is done until
%    convergance of the log likelihood. This is the algorithm used when
%    'estim_method' option isset to 'dfmeml'. 
%
% 2. In the bayesian setting we have a prior on beta. The conditional 
%    posterior of p(zeta|X,beta) and p(beta|X,zeta) are then known for
%    priors we offer. Here we drop (t) script to mean the full series. As
%    we have the conditional posteriors we can draw from them using the
%    Gibbs sampler as suggested by Carter and Kohn (1994). In practice 
%    we can draw from p(zeta|X,beta) using the kalman smoother given
%    the last draw of beta. When doing gibbs sampling you may need to
%    use a burn in face and use thinning to prevent autocorrelated draws
%    from the posterior. For more information on the prior spesification
%    see nb_fmdyn.priorTemplate and nb_fmdyn.setPrior. Bayesian estimation
%    is triggered by calling nb_fmdyn.setPrior, or else the algorithm under
%    1 is ran. This is the algorithm used when 'estim_method' option isset 
%    to 'bdfm'. (Not yet finished!)
%
% 3. Koop and Korobilis (2014) extended by Schroder and Eraslan (2021) to 
%    handle mixed frequency. See the nb_tvpmfsvEstimator package.
%
% Caution: Some small alteration to the referenced algorithm may have been 
%          done in special cases.
%
% References:
%
% Banbura and Modugno (2010a), "Maximum likelihood estimation of factor 
% models on data sets with arbitrary pattern of missing data".
%
% Banbura et al. (2010b), "Nowcasting"
%
% Carter and Kohn (1994), "On Gibbs sampling for state space models",
% Biometrika, Volume 81, Issue 3, September 1994, Pages 541-553
%
% Superclasses:
%
% nb_factor_model_generic, nb_model_generic
%
% Constructor:
%
%   obj = nb_fmdyn(varargin)
% 
%   Optional input:
%
%   - See the set method for more on the inputs. 
%     (nb_model_estimate.set)
% 
%   Output:
% 
%   - obj : An nb_fmdyn object.
% 
% See also:
% nb_model_generic, nb_model_estimate.set, 
% nb_dfmemlEstimator.estimate, nb_bdfmEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)
       
        % A struct with the fields name, tex_name and number. The name 
        % field holds a cellstr with the names of all the factors, 
        % the tex_name holds the names in the tex format. The number 
        % field holds a double with the number of factors. Cannot  
        % be set. Model must be estimated 
        factors          
        
    end
    
    properties (Hidden=true)
       
        % Property to store factor names added in the setBlocks method.
        factorNames     = [];
        
    end

    methods
        
        function obj = nb_fmdyn(varargin)
        % Constructor

            obj             = obj@nb_model_generic();
            temp            = nb_fmdyn.template();
            temp            = rmfield(temp,{'exogenous','observables'});
            obj.options     = temp;
            temp            = struct();
            temp.name       = {};
            temp.tex_name   = {};
            temp.number     = [];
            temp.frequency  = {};
            temp.mapping    = {};
            obj.observables = temp;
            obj.exogenous   = temp;
            obj             = set(obj,varargin{:});
            
        end
        
        function propertyValue = get.factors(obj)
            
            fNumber = obj.options.nFactors;
            if nb_isempty(obj.factorNames)
                fNames    = nb_appendIndexes('Factor',1:fNumber)';
                fTexNames = fNames;
            else
                fNames = obj.factorNames.name;
                if isfield(obj.factorNames,'tex_name')
                    fTexNames = obj.factorNames.tex_name;
                else
                    fTexNames = strrep(fNames,'_','\_');
                end
            end
            propertyValue = struct(...
                'name',     {fNames},...
                'number',   fNumber,...
                'tex_name', {fTexNames});
            
        end
        
    end
    
    methods (Hidden)
       
        function name = createName(obj)
            
            if ~isscalar(obj)
                error('This method only handle a scalar nb_model_name object.')
            end
            if ~isempty(obj.options.prior)
                name = 'B_FMDYN';
            else
                name = 'FMDYN';
            end
            name = [name ,'_L', int2str(obj.options.nLags)];
            NF   = nb_conditional(isempty(obj.options.nFactors),0,obj.options.nFactors);
            name = [name ,'_NF', int2str(NF)];
            if ~isempty(obj.options.rollingWindow)
                name = [name ,'_RW' int2str(obj.options.rollingWindow)];
            end
            
        end
        
    end

    methods(Access=protected)
       
        function param = getParametersNames(obj)
            
            % Construct the coeff names
            if nb_isempty(obj.estOptions)
                param = struct('name',{{}},'value',[]);
            else
                coeff = nb_dfmemlEstimator.getCoeff(obj.estOptions(end));
                param = struct('name',{coeff},'value',obj.results.beta);
            end
            
        end
   
    end
    
    methods(Static=true)
        
        varargout = solveNormal(varargin)
        varargout = solveRecursive(varargin)
        varargout = template(varargin)
        varargout = priorHelp(varargin)
        varargout = priorTemplate(varargin)
        varargout = help(varargin)
        
    end
         
end

