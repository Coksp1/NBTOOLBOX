classdef nb_distribution < matlab.mixin.Copyable
% Description:
%
% A class for evaluate the pdf, cdf, icdf etc of a known distribution as 
% well as for a estimated distribution (using kernel density estimates)
%
% Caution: Some of the methods utilizes the MATLAB statistics package.
%
% Superclasses:
% handle
%
% Constructor:
%
%   obj = nb_distribution(varargin)
% 
%   Input:
%
%   - varargin : Property name and property value pair arguments. See the
%                set method for a example. Type properties(obj) in the 
%                command line to get a  list of supported properties, and 
%                type help nb_distribution.<propertyName> to get help on a  
%                specific property.
%
%                Caution : When the property type is set, the parameters 
%                          property will be set to its default value given 
%                          the type of distribution. See the paramters
%                          for more on this.
% 
%   Output:
% 
%   - obj      : An object of class nb_distribution
% 
%   Examples:
%   obj = nb_distribution('type','gamma');
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   properties 
       
       % The value to condition on when included in a nb_copula object and
       % the 'conditional' type is used by the pdf, cdf and random methods,
       % otherwise it has no effect.
       conditionalValue = [];
       
   end

   properties (SetAccess=protected)
       
       % Lower bound of truncated distribution. Use the set method to 
       % truncate the distribution.
       lowerBound       = [];           
       
       % Shift mean. As a double. If the distribution is truncated this
       % will only shift the untruncated distributions mean with this
       % magnitude. Default is empty, i.e. no mean shift.
       meanShift        = [];
       
       % The paramteres of the wanted distribution. This property will
       % depend on the distribution type;
       %
       % Caution : When the property type is set, the paramters property 
       %           will be set to its default value given the type of  
       %           distribution.
       %
       % - 'ast '      : The paramters property must be set to a 1x5 cell.
       %                 {location,scale,skewness,lefttail,righttail}, 
       %                 where location is any double, scale > 0, skewness
       %                 is between 0 and 1, leftail > 0 and righttail > 0.
       %                 Default is {0,1,0,1000,1000} ~ N(0,1). 
       %
       % - 'beta'      : The paramters property must be set to a 1x2 cell.
       %                 {param1,param2}, where both must be set to a 1x1  
       %                 double greater than 0. Default is {2,2}. The
       %                 mean will be given by param1/(param1 + param2).
       %
       % - 'cauchy'    : The paramters property must be set to a 1x2 cell.
       %                 {location,scale}, where location must be set to a   
       %                 1x1 double, and scale must be set to a 1x1 double 
       %                 greater than 0. Default is {0,2}.
       %
       % - 'chis'      : The paramters property must be set to a 1x1 cell.
       %                 {param1}, where param1 must be set to a 1x1  
       %                 double greater than 0. Default is {2}.
       %
       % - 'constant'  : The paramters property must be set to a 1x1 cell.
       %                 {constant}, where constant must be set to a 1x1  
       %                 double. Default is {0}.
       %
       % - 'empirical' : The parameters property must be set to a 1 x 2 
       %                 cell. First element must be the domain 
       %                 (1 x N double) and the second element must be the
       %                 probability density (1 x N double). 
       %
       % - 'exp'       : The paramters property must be set to a 1x1 cell.
       %                 {param1}, where param1 must be set to a 1x1  
       %                 double greater than 0. Default is {2}.
       %
       % - 'f'         : The paramters property must be set to a 1x1 cell.
       %                 {param1,parma2}, where both must be set to a 1x1  
       %                 double greater than 0. Default is {10,10}.
       %
       % - 'fgamma'    : The paramters property must be set to a 1x2 cell.
       %                 {shape,scale}, where shape and scale must both be  
       %                 a 1x1 double greater than 0. Default is {2,2}. The
       %                 mean will be given by shape*scale.
       %
       % - 'finvgamma' : The paramters property must be set to a 1x2 cell.
       %                 {shape,scale}, where shape and scale must both be  
       %                 a 1x1 double greater than 0. Default is {4,2}. The
       %                 mean will be given by scale/(shape - 1) for 
       %                 shape > 1.
       %
       % - 'gamma'     : The paramters property must be set to a 1x2 cell.
       %                 {shape,scale}, where shape and scale must both be  
       %                 a 1x1 double greater than 0. Default is {2,2}. The
       %                 mean will be given by shape*scale.
       %
       % - 'hist'      : The paramters property must be set to a 1x1 cell.
       %                 {data}, where data must be a Nx1 double. Default 
       %                 is {randn(100,1)}. 
       %
       % - 'invgamma'  : The paramters property must be set to a 1x2 cell.
       %                 {shape,scale}, where shape and scale must both be  
       %                 a 1x1 double greater than 0. Default is {4,2}. The
       %                 mean will be given by scale/(shape - 1) for 
       %                 shape > 1.
       %
       % - 'kernel'    : The parameters property must be set to a 1 x 2 
       %                 cell. First element must be the domain 
       %                 (1 x N double) and the second element must be the
       %                 probability density (1 x N double).
       %
       % - 'laplace'   : The paramters property must be set to a 1x2 cell.
       %                 {location,scale}, where location must be a 
       %                 1x1 double and scale must be 1x1 double greater 
       %                 than 0. Default is {0,1}.
       %
       % - 'logistic'  : The paramters property must be set to a 1x2 cell.
       %                 {location,scale}, where location must be set to a   
       %                 1x1 double, and scale must be set to a 1x1 double 
       %                 greater than 0. Default is {0,2}.
       %
       % - 'lognormal' : The paramters property must be set to a 1x2 cell.
       %                 {param1,param2}, where both must be set to a 1x1  
       %                 double greater than 0. Default is {1,1}.
       %
       % - 'normal'    : The paramters property must be set to a 1x2 cell.
       %                 {mean,std}, where mean must be a 1x1 double
       %                 and std must be 1x1 double greater than 0.
       %                 Default is {0,1}.
       %
       % - 'skewedt'   : The paramters property must be set to a 1x4 cell.
       %                 {mean,std,skewness,kurtosis}. Default is 
       %                 {0,1.2910,0,2.5}, i.e. same as student-t with 5
       %                 degrees of freedom.
       %
       % - 't'         : The paramters property must be set to a 1x1 cell.
       %                 {dof}, where dof must be set to a 1x1 double 
       %                 greater than 0. Default is {5}.
       %
       %                 You can also use the Non-standardized student-t 
       %                 distribution by setting this property to a 1x3
       %                 cell, where the two additional inputs are location
       %                 and scale. location must be set to a 1x1 double 
       %                 and scale must be set to a 1x1 double greater 
       %                 than 0.  
       %
       % - 'tri'       : The paramters property must be set to a 1x3 cell.
       %                 {low,high,mode}, where low, high and mode must be 
       %                 set to a 1x1 double. Default is {0,1,0.5}.
       %
       % - 'uniform'   : The paramters property must be set to a 1x2 cell.
       %                 {lower,upper}, where bust must be a 1x1 double.
       %                 Default is {0,1}.
       %
       % - 'wald'      : The paramters property must be set to a 1x2 cell.
       %                 {mean,shape}, where mean must be a 1x1 double
       %                 greater than 0 and shape must be 1x1 double 
       %                 greater than 0. Default is {1,1}.
       parameters       = {0,1}
       
       % The type of distributions. The following are supported;
       %
       % - 'ast'       : Asymetric student-t distribution. See Zhu and 
       %                 Galbraith (2009)  
       %
       % - 'beta'      : Beta distribution
       %
       % - 'cauchy'    : Chauchy distribution
       %
       % - 'chis'      : Chi-squared distribution
       %
       % - 'constant'  : A constant. I.e. the distribution of a non-random 
       %                 variable.
       %
       % - 'empirical' :  Empirical (Kaplan-Meier) cumulative distribution 
       %                  function.
       %
       % - 'f'         : F-distribution
       %
       % - 'fgamma'    : Flipped gamma distribution
       %
       % - 'finvgamma' : Flipped inverse gamma distribution
       %
       % - 'gamma'     : Gamma distribution
       %
       % - 'hist'      : Create a histogram. This to make it easy to
       %                 compare the estimated distribution against a
       %                 histogram. For the moments operators the
       %                 empirical counterparts are returned!
       %
       % - 'invgamma'  : Inverse gamma distribution 
       %
       % - 'kernel'    : Kernel density estimation. Please see the 
       %                 method estimate on how to estimate a kernel
       %                 distribution. 
       %
       % - 'laplace'   : Laplace distribution.
       %
       % - 'lognormal' : Lognormal distribution.
       %
       % - 'logistic'  : Logistic distribution.
       %
       % - 'normal'    : Normal distribution. Default
       %
       % - 'skewedt'   : Skewed t-distribution. https://en.wikipedia.org/...
       %                 wiki/Skewed_generalized_t_distribution
       %
       % - 't'         : Student-t distribution
       %
       % - 'tri'       : Triangular distribution
       %
       % - 'uniform'   : Uniform distribution
       %
       % - 'wald'      : Wald distribution
       type             = 'normal';
         
       % Upper bound of truncated distribution. Use the set method to 
       % truncate the distribution.
       upperBound       = [];
       
       % User data stored to the object. Can be of any type
       userData         = [];
       
   end
   
   properties (Dependent=true)
   
       % The name of the distribution. It is possible to set this property
       % by the set method. If not set it will be given a default name
       % that will depend on the distribution and its parametrization.
       name
       
   end
   
   properties (Access=protected,Hidden=true)
      
       editedName = '';
       
   end
   
   %=======================================================================
   methods
       
       function obj = nb_distribution(varargin)
           
           obj.set(varargin{:});
           
       end
       
       function set.conditionalValue(obj,propValue)
           
          if isscalar(propValue) && isnumeric(propValue) || isempty(propValue) 
              obj.conditionalValue = propValue;
          else
              error([mfilename ':: Wrong property assigned to the conditionalValue property. Must be assigned a 1x1 double or empty double.'])
          end
          
       end
       
       function prop = get.name(obj)
          
           if ~isempty(obj.editedName)
               prop = obj.editedName;
           else
               prop = obj.type;
               if strcmpi(prop,'kernel') ||  strcmpi(prop,'empirical')
                   m = mean(obj);
                   if ~isempty(obj.meanShift)
                       m = m - obj.meanShift;
                   end
                   prop = ['kernel(' num2str(m) ',' num2str(std(obj)) ')'];
               elseif strcmpi(prop,'hist')
                   m = mean(obj);
                   if ~isempty(obj.meanShift)
                       m = m - obj.meanShift;
                   end
                   prop = ['hist(' num2str(m) ',' num2str(std(obj)) ')'];    
               else
                   if size(obj.parameters,2) == 1
                       prop = [prop '(' num2str(obj.parameters{1}) ')'];
                   elseif size(obj.parameters,2) == 2
                       prop = [prop '(' num2str(obj.parameters{1}) ',' num2str(obj.parameters{2}) ')'];
                   elseif size(obj.parameters,2) == 3
                       prop = [prop '(' num2str(obj.parameters{1}) ',' num2str(obj.parameters{2}) ',' num2str(obj.parameters{3}) ')'];
                   elseif size(obj.parameters,2) == 4
                       prop = [prop '(' num2str(obj.parameters{1}) ',' num2str(obj.parameters{2}) ',' num2str(obj.parameters{3}) ',' num2str(obj.parameters{4}) ')'];
                   elseif size(obj.parameters,2) == 5
                       prop = [prop '(' num2str(obj.parameters{1}) ',' num2str(obj.parameters{2}) ',' num2str(obj.parameters{3}) ',' num2str(obj.parameters{4}) ',' num2str(obj.parameters{5}) ')'];        
                   end
               end
               if ~isempty(obj.meanShift)
                   prop = [prop, '{shift=' num2str(obj.meanShift) '}'];
               end
               if ~isempty(obj.upperBound) || ~isempty(obj.lowerBound)
                   prop = [prop, '[' num2str(obj.lowerBound) ',' num2str(obj.upperBound) ']'];
               end
               if ~isempty(obj.conditionalValue)
                   prop = [prop '''cond=' num2str(obj.conditionalValue) ''''];
               end
           end
           
       end
       
   end
   
   %=======================================================================
   methods(Access=protected)
       
       varargout = setDefaultParamters(varargin)
       
   end
   
   %=======================================================================
   methods(Static=true)
       
       varargout = ast_cdf(varargin)
       varargout = ast_domain(varargin)
       varargout = ast_icdf(varargin)
       varargout = ast_kurtosis(varargin);
       varargout = ast_mean(varargin);
       varargout = ast_median(varargin);
       varargout = ast_mode(varargin);
       varargout = ast_pdf(varargin)
       varargout = ast_rand(varargin)
       varargout = ast_skewness(varargin);
       varargout = ast_std(varargin);
       varargout = ast_variance(varargin);
       
       varargout = beta_cdf(varargin)  
       varargout = beta_domain(varargin)
       varargout = beta_icdf(varargin)
       varargout = beta_kurtosis(varargin);
       varargout = beta_mean(varargin);
       varargout = beta_median(varargin);
       varargout = beta_mode(varargin);
       varargout = beta_pdf(varargin);
       varargout = beta_rand(varargin);
       varargout = beta_skewness(varargin);
       varargout = beta_std(varargin);
       varargout = beta_variance(varargin);
       
       varargout = cauchy_cdf(varargin)
       varargout = cauchy_domain(varargin)
       varargout = cauchy_icdf(varargin)
       varargout = cauchy_kurtosis(varargin);
       varargout = cauchy_mean(varargin);
       varargout = cauchy_median(varargin);
       varargout = cauchy_mode(varargin);
       varargout = cauchy_pdf(varargin);
       varargout = cauchy_rand(varargin);
       varargout = cauchy_skewness(varargin);
       varargout = cauchy_std(varargin);
       varargout = cauchy_variance(varargin);
       
       varargout = chis_cdf(varargin)
       varargout = chis_domain(varargin)
       varargout = chis_icdf(varargin)
       varargout = chis_kurtosis(varargin);
       varargout = chis_mean(varargin);
       varargout = chis_median(varargin);
       varargout = chis_mode(varargin);
       varargout = chis_pdf(varargin);
       varargout = chis_rand(varargin);
       varargout = chis_skewness(varargin);
       varargout = chis_std(varargin);
       varargout = chis_variance(varargin);
       
       varargout = constant_cdf(varargin)
       varargout = constant_domain(varargin)
       varargout = constant_icdf(varargin)
       varargout = constant_kurtosis(varargin);
       varargout = constant_mean(varargin);
       varargout = constant_median(varargin);
       varargout = constant_mode(varargin);
       varargout = constant_pdf(varargin);
       varargout = constant_rand(varargin);
       varargout = constant_skewness(varargin); 
       varargout = constant_std(varargin); 
       varargout = constant_variance(varargin);
       
       varargout = defaultParameters(varargin);
       varargout = double2Dist(varargin);
       varargout = double2NormalDist(varargin);
       varargout = estimate(varargin)
       varargout = estimateDomain(varargin)
       
       varargout = empirical_cdf(varargin)   
       varargout = empirical_domain(varargin)
       varargout = empirical_icdf(varargin)
       varargout = empirical_kurtosis(varargin);
       varargout = empirical_mean(varargin);
       varargout = empirical_median(varargin);
       varargout = empirical_mode(varargin); 
       varargout = empirical_pdf(varargin)
       varargout = empirical_rand(varargin)
       varargout = empirical_skewness(varargin);
       varargout = empirical_std(varargin);
       varargout = empirical_variance(varargin);
       
       varargout = exp_cdf(varargin) 
       varargout = exp_domain(varargin)
       varargout = exp_icdf(varargin)
       varargout = exp_kurtosis(varargin);
       varargout = exp_mean(varargin);
       varargout = exp_median(varargin);
       varargout = exp_mode(varargin);
       varargout = exp_pdf(varargin);
       varargout = exp_rand(varargin);
       varargout = exp_skewness(varargin);
       varargout = exp_std(varargin);
       varargout = exp_variance(varargin);
       
       varargout = f_cdf(varargin)
       varargout = f_domain(varargin)
       varargout = f_icdf(varargin)
       varargout = f_kurtosis(varargin);
       varargout = f_mean(varargin);
       varargout = f_median(varargin);
       varargout = f_mode(varargin);
       varargout = f_pdf(varargin);
       varargout = f_rand(varargin);
       varargout = f_skewness(varargin);
       varargout = f_std(varargin);
       varargout = f_variance(varargin);
       
       varargout = fgamma_cdf(varargin)
       varargout = fgamma_domain(varargin)
       varargout = fgamma_icdf(varargin)
       varargout = fgamma_kurtosis(varargin);
       varargout = fgamma_mean(varargin);
       varargout = fgamma_median(varargin);
       varargout = fgamma_mode(varargin);
       varargout = fgamma_pdf(varargin);
       varargout = fgamma_rand(varargin);
       varargout = fgamma_skewness(varargin);
       varargout = fgamma_std(varargin);
       varargout = fgamma_variance(varargin);
       
       varargout = finvgamma_cdf(varargin) 
       varargout = finvgamma_domain(varargin)
       varargout = finvgamma_icdf(varargin)
       varargout = finvgamma_kurtosis(varargin);
       varargout = finvgamma_mean(varargin); 
       varargout = finvgamma_median(varargin);
       varargout = finvgamma_mode(varargin);
       varargout = finvgamma_pdf(varargin);
       varargout = finvgamma_rand(varargin);
       varargout = finvgamma_skewness(varargin);
       varargout = finvgamma_std(varargin);
       varargout = finvgamma_variance(varargin);
       
       varargout = gamma_cdf(varargin)
       varargout = gamma_domain(varargin)
       varargout = gamma_icdf(varargin)
       varargout = gamma_kurtosis(varargin);
       varargout = gamma_mean(varargin);
       varargout = gamma_median(varargin);
       varargout = gamma_mode(varargin); 
       varargout = gamma_pdf(varargin);
       varargout = gamma_rand(varargin);
       varargout = gamma_skewness(varargin);
       varargout = gamma_std(varargin);
       varargout = gamma_variance(varargin);
       
       varargout = hist_cdf(varargin)
       varargout = hist_domain(varargin)
       varargout = hist_icdf(varargin)
       varargout = hist_kurtosis(varargin);
       varargout = hist_mean(varargin);
       varargout = hist_median(varargin);
       varargout = hist_mode(varargin);
       varargout = hist_pdf(varargin)
       varargout = hist_rand(varargin)
       varargout = hist_skewness(varargin);
       varargout = hist_std(varargin);
       varargout = hist_variance(varargin);
       
       varargout = initialize(varargin);
       
       varargout = invgamma_cdf(varargin)
       varargout = invgamma_domain(varargin)
       varargout = invgamma_icdf(varargin)
       varargout = invgamma_kurtosis(varargin);
       varargout = invgamma_mean(varargin);
       varargout = invgamma_median(varargin);
       varargout = invgamma_mode(varargin);
       varargout = invgamma_pdf(varargin);
       varargout = invgamma_rand(varargin);
       varargout = invgamma_skewness(varargin);
       varargout = invgamma_std(varargin);
       varargout = invgamma_variance(varargin);
       
       varargout = invwish_rand(varargin)
       
       varargout = kernel_cdf(varargin)
       varargout = kernel_domain(varargin)
       varargout = kernel_icdf(varargin)
       varargout = kernel_kurtosis(varargin);
       varargout = kernel_mean(varargin);
       varargout = kernel_median(varargin);
       varargout = kernel_mode(varargin);
       varargout = kernel_pdf(varargin)
       varargout = kernel_rand(varargin)
       varargout = kernel_skewness(varargin);
       varargout = kernel_std(varargin);
       varargout = kernel_variance(varargin);
       
       varargout = laplace_cdf(varargin)
       varargout = laplace_domain(varargin)
       varargout = laplace_icdf(varargin)
       varargout = laplace_kurtosis(varargin);
       varargout = laplace_mean(varargin);
       varargout = laplace_median(varargin);
       varargout = laplace_mode(varargin); 
       varargout = laplace_pdf(varargin)
       varargout = laplace_rand(varargin)
       varargout = laplace_skewness(varargin);
       varargout = laplace_std(varargin);
       varargout = laplace_variance(varargin);
       
       varargout = logistic_cdf(varargin)
       varargout = logistic_domain(varargin)
       varargout = logistic_icdf(varargin)
       varargout = logistic_kurtosis(varargin);
       varargout = logistic_mean(varargin);
       varargout = logistic_median(varargin);
       varargout = logistic_mode(varargin);
       varargout = logistic_pdf(varargin)
       varargout = logistic_rand(varargin)
       varargout = logistic_skewness(varargin);
       varargout = logistic_std(varargin);
       varargout = logistic_variance(varargin);
       
       varargout = lognormal_cdf(varargin)
       varargout = lognormal_domain(varargin)
       varargout = lognormal_icdf(varargin)
       varargout = lognormal_kurtosis(varargin);
       varargout = lognormal_mean(varargin);
       varargout = lognormal_median(varargin);
       varargout = lognormal_mode(varargin);
       varargout = lognormal_pdf(varargin)
       varargout = lognormal_rand(varargin)
       varargout = lognormal_skewness(varargin);
       varargout = lognormal_std(varargin);
       varargout = lognormal_variance(varargin);
       
       varargout = meanshift_cdf(varargin)
       varargout = meanshift_domain(varargin)
       varargout = meanshift_icdf(varargin)
       varargout = meanshift_kurtosis(varargin);
       varargout = meanshift_mean(varargin);
       varargout = meanshift_median(varargin);
       varargout = meanshift_mode(varargin);
       varargout = meanshift_pdf(varargin)
       varargout = meanshift_rand(varargin)
       varargout = meanshift_skewness(varargin);
       varargout = meanshift_std(varargin);
       varargout = meanshift_variance(varargin);
       
       varargout = mle(varargin);
       varargout = mme(varargin);
       
       varargout = normal_cdf(varargin)
       varargout = normal_domain(varargin)
       varargout = normal_icdf(varargin)
       varargout = normal_kurtosis(varargin);
       varargout = normal_mean(varargin);
       varargout = normal_median(varargin);
       varargout = normal_mode(varargin);
       varargout = normal_pdf(varargin)
       varargout = normal_rand(varargin)
       varargout = normal_skewness(varargin);
       varargout = normal_std(varargin);
       varargout = normal_variance(varargin);
       
       varargout = parametrization(varargin);
       varargout = parameterization(varargin);
       varargout = perc2Dist(varargin);
       varargout = perc2DistCDF(varargin);
       varargout = perc2ParamDist(varargin);
       varargout = qestimation(varargin);
       varargout = sim2KernelDist(varargin);
       
       varargout = skewedt_cdf(varargin)
       varargout = skewedt_domain(varargin)
       varargout = skewedt_icdf(varargin)
       varargout = skewedt_kurtosis(varargin);
       varargout = skewedt_mean(varargin);
       varargout = skewedt_median(varargin);
       varargout = skewedt_mode(varargin);
       varargout = skewedt_pdf(varargin)
       varargout = skewedt_rand(varargin)
       varargout = skewedt_skewness(varargin);
       varargout = skewedt_std(varargin);
       varargout = skewedt_variance(varargin);
       
       varargout = t_cdf(varargin) 
       varargout = t_domain(varargin)
       varargout = t_icdf(varargin)
       varargout = t_kurtosis(varargin);
       varargout = t_mean(varargin);
       varargout = t_median(varargin);
       varargout = t_mode(varargin);
       varargout = t_pdf(varargin)
       varargout = t_rand(varargin)
       varargout = t_skewness(varargin);
       varargout = t_std(varargin);
       varargout = t_variance(varargin);
       
       varargout = tri_cdf(varargin)
       varargout = tri_domain(varargin)
       varargout = tri_icdf(varargin)
       varargout = tri_kurtosis(varargin);
       varargout = tri_mean(varargin);
       varargout = tri_median(varargin);
       varargout = tri_mode(varargin);
       varargout = tri_pdf(varargin)
       varargout = tri_rand(varargin)
       varargout = tri_skewness(varargin);
       varargout = tri_std(varargin);
       varargout = tri_variance(varargin);
       
       varargout = truncated_cdf(varargin)
       varargout = truncated_domain(varargin)
       varargout = truncated_icdf(varargin)
       varargout = truncated_kurtosis(varargin);
       varargout = truncated_mean(varargin);
       varargout = truncated_median(varargin);
       varargout = truncated_mode(varargin);
       varargout = truncated_pdf(varargin)
       varargout = truncated_rand(varargin)
       varargout = truncated_skewness(varargin);
       varargout = truncated_std(varargin);
       varargout = truncated_variance(varargin);

       varargout = truncgamma_mean(varargin);
       varargout = truncgamma_variance(varargin);
       varargout = truncnormal_mean(varargin);
       varargout = truncnormal_variance(varargin);
       
       varargout = uniform_cdf(varargin)
       varargout = uniform_domain(varargin)
       varargout = uniform_icdf(varargin)
       varargout = uniform_kurtosis(varargin);
       varargout = uniform_mean(varargin);
       varargout = uniform_median(varargin);
       varargout = uniform_mode(varargin);
       varargout = uniform_pdf(varargin)
       varargout = uniform_rand(varargin)
       varargout = uniform_skewness(varargin);
       varargout = uniform_std(varargin);
       varargout = uniform_variance(varargin);
       
       varargout = wald_cdf(varargin)
       varargout = wald_domain(varargin)
       varargout = wald_icdf(varargin)
       varargout = wald_kurtosis(varargin);
       varargout = wald_mean(varargin);
       varargout = wald_median(varargin);
       varargout = wald_mode(varargin);
       varargout = wald_pdf(varargin)
       varargout = wald_rand(varargin)
       varargout = wald_skewness(varargin);
       varargout = wald_std(varargin);
       varargout = wald_variance(varargin);
       
       varargout = wish_rand(varargin)
       
   end
    
end
