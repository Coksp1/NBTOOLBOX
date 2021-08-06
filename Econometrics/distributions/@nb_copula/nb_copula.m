classdef nb_copula < handle
% Description:
%
% A class for constructing a multivariate distribution given marginal 
% distributions of the seperate variables and a correlation matrix using a 
% gaussian copula.
%
% Caution: Some of the methods utilizes the MATLAB statistics package.
%
% Superclasses:
% handle
%
% Constructor:
%
%   obj = nb_copula(distr,varargin)
% 
%   Input:
%
%   - distr    : A 1xN vector of nb_distribution objects. N > 1.
%
%   - varargin : Property name and property value pair arguments. See the
%                set method for a example. Type properties(obj) in the 
%                command line to get a  list of supported properties, and 
%                type help nb_distribution.<propertyName> to get help on a  
%                specific property.
% 
%   Output:
% 
%   - obj      : An object of class nb_copula
% 
%   Examples:
%
%   distr = nb_distribution.initialize('type',{'normal','gamma'},...
%                                      'parameters',{{6,2},{2,2}});
%   obj   = nb_copula(distr);
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   properties (SetAccess=protected)
       
       % The marginal distributions of the seperate variables as a 1xN
       % vector of nb_distribution objects.
       distributions    = []
       
       % The linear correlation matrix. As a NxN double with ones along 
       % the diagonal. Must be oredered accordingly to the property 
       % distributions. Default is uncorrelated marginals.
       sigma            = [];
       
       % Set the transformation method to use to transform the rank 
       % correlation coefficients to the linear correlation 
       % coefficients.
       % 
       % - 'none'     : If the correlation in the data is calculated
       %              based on the linear correlation coefficients.
       %              Default.
       % 
       % - 'spearman' : Uses the formula rho = 2.*sin(sigma.*pi./6).
       %              Can be used if the rank correlation coefficients
       %              are calculated based on the data series.
       %              Using the corr(X,'type','spearman') function.
       % 
       % - 'kendall'  : Uses the formula rho = sin(sigma.*pi./2).
       %              Can be used if the rank correlation coefficients
       %              are calculated based on the data series.        
       %              Using the corr(X,'type','kendall') function.
       % 
       % The rank correlation coefficients are approximatly invariant
       % to the choice of marginal distribution used to transform the
       % draws from the copula to the draws of the different marginals.
       type             = 'none';
       
   end
   
   properties(Dependent=true,SetAccess=immutable)
       
       transformedSigma = [];
       
   end
   
   properties(Dependent=true,SetAccess=protected)
       
       % The number of distributions in the copula. As a scalar double.
       numberOfDistributions = [];
       
   end
   
   %=======================================================================
   methods
       
       function obj = nb_copula(distr,varargin)
           
           if nargin == 0
               return
           end
           
           if ~isa(distr,'nb_distribution')
               error([mfilename ':: The distr input must be a 1xN vector of nb_distribution objects, where N>1.'])
           end
           
           if size(distr,2) < 2 || size(distr,1) ~= 1
               error([mfilename ':: The distr input must be a 1xN vector of nb_distribution objects, where N>1.'])
           end
           
           obj.distributions = distr;
           obj.set(varargin{:});
           
       end
       
       function propertyValue = get.transformedSigma(obj)
           
           switch lower(obj.type) 
                case 'spearman'
                    propertyValue = 2.*sin(obj.sigma.*pi./6);
                case 'kendall'
                    propertyValue = sin(obj.sigma.*pi./2);
               case 'none'
                    propertyValue = obj.sigma;
            end
           
       end
       
       function propertyValue = get.numberOfDistributions(obj)
           propertyValue = size(obj.distributions,2);
       end
       
       varargout = cdf(varargin)
       
       varargout = domain(varargin)
       
       varargout = get(varargin)
       
       varargout = icdf(varargin)
       
       varargout = kurtosis(varargin)
       
       varargout = mean(varargin)
       
       varargout = median(varargin)
       
       varargout = mode(varargin)
       
       varargout = percentile(varargin)
       
       varargout = pdf(varargin)
       
       varargout = plot(varargin)
       
       varargout = random(varargin)
       
       varargout = set(varargin)
       
       varargout = skewness(varargin)
       
       varargout = std(varargin)
       
       varargout = variance(varargin)
       
   end
   
   
   %=======================================================================
   methods(Static=true)
       
       
       
   end
    
end
