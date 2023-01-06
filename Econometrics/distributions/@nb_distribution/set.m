function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of the nb_distribution object.
% 
% Type properties(obj) in the command line to get a  list of supported 
% properties, and type help nb_distribution.<propertyName> to get help on a  
% specific property.
%
% Caution : When the property type is set, the paramters property will be
%           set to its default value given the type of the distribution.  
%           See the paramters for more on this.
% 
% Caution : When the property type is set, the name property will be
%           set to its default value given the type and parameterization of  
%           the distribution.
%
% Input:
% 
% - obj      : An object of class nb_distribution
% 
% - varargin : 'propertyName',propertyValue,...
%
% Output:
% 
% - obj      : The input object with the updated properties.
%
% Examples:
% 
% set(obj,'propertyName',propertyValue);
% obj.set('propertyName',propertyValue,...)
% obj = obj.set('type','gamma');
% 
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nobj = size(obj,2);
    if nobj > 1
        for ii = 1:nobj
            set(obj(ii),varargin{:});
        end
        return
    end

    ind1 = find(strcmpi('type',varargin));
    ind2 = find(strcmpi('parameters',varargin));
    if not(isempty(ind1) || isempty(ind2))
        if any(ind2(end) < ind1(end))
            error([mfilename ':: If you want to set the parameters and the type of the distribution, the parameters must come last in the set call!'])
        end
    end

    if rem(length(varargin),2) ~= 0
        error([mfilename ':: Inputs must come in pairs.'])
    end
    for jj = 1:2:size(varargin,2)

        propertyName  = varargin{jj};
        propertyValue = varargin{jj + 1};
        if ischar(propertyName)

            switch lower(propertyName)
                
                case 'conditionalvalue'
                
                    if isscalar(propertyValue) && isnumeric(propertyValue) || isempty(propertyValue)
                        obj.conditionalValue = propertyValue;
                    else
                        error([mfilename ':: Conditional value must be set to a number.'])
                    end
                    
                case 'lowerbound'
                    
                    if ~isnumeric(propertyValue)
                        error([mfilename ':: Lower bound must be a number.'])
                    end
                    
                    if strcmpi(obj.type,'constant')
                        error([mfilename,':: It is not possible to add a lower bound to a non-random variable (constant).'])
                    end
                    
                    d = domain(obj,1);
                    if ~isempty(propertyValue)
                        if propertyValue > d(2) || propertyValue < d(1)
                            error([mfilename ':: The lower bound is outside the bounds of the ' obj.name ' distribution; [' num2str(d(1)) ',' num2str(d(2)) ']'])
                        end
                    end
                    obj.lowerBound = propertyValue;
                    
                case 'meanshift'
                    
                    if ~isempty(propertyValue)
                        if ~isnumeric(propertyValue) || ~isscalar(propertyValue)
                            error([mfilename ':: Lower bound must be a number.'])
                        end
                    end
                    obj.meanShift = propertyValue;
                    
                case 'name'
                    
                    if ~ischar(propertyValue)
                        error([mfilename ':: The name property must be set to a string. Is of class ' class(propertyValue)])
                    end
                    obj.editedName =  propertyValue;
                
                case 'parameters'
                    
                    switch obj.type
                        
                        case 'ast' 
                        
                            if iscell(propertyValue) && numel(propertyValue) == 5
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x5 cell; '...
                                    '{location,scale,skewness,lefttail,righttail}.'])
                            end  
                            
                        case 'beta'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The first paramter of the beta distribution cannot be negative or zero.'])
                                end
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The second paramter of the beta distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the parameters of the beta distribution.'])
                            end 
                            
                        case 'cauchy'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The scale paramter of the cauchy distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the parameters of the cauchy distribution.'])
                            end     
                            
                        case 'chis'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 1
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The first paramter of the chi squared distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x1 cell with '...
                                    'the degrees of freedom of the chi squared distribution.'])
                            end 
                            
                        case 'constant'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 1 
                                obj.parameters = propertyValue; 
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x1 cell with '...
                                    'the constant.'])
                            end
                            
                        case 'exp'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 1
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The rate paramter of the exponential distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x1 cell with '...
                                    'the parameters of the exponential distribution.'])
                            end 
                            
                        case 'f'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The first parameter of the F(m,k) distribution cannot be negative or zero.'])
                                end
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The second paramter of the F(m,k) distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the parameters of the F(m,k) distribution.'])
                            end 
                            
                        case {'fgamma','gamma'}
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The shape paramter of the gamma distribution cannot be negative or zero.'])
                                end
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The rate paramter of the gamma distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the shape and the rate parameters as element 1 and 2 respectively.'])
                            end
                            
                        case 'hist'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 1
                                if ~iscolumn(propertyValue{1})
                                    error([mfilename ':: The data points must be a nobs x 1 double.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x1 cell with '...
                                    'the data points as element 1.'])
                            end
                             
                        case {'finvgamma','invgamma'}
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The shape paramter of the inverse gamma distribution cannot be negative or zero.'])
                                end
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The rate parameter of the inverse gamma distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the scale and the shape parameters as element 1 and 2 respectively.'])
                            end    
                            
                        case {'kernel','empirical'}
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the domain and the density as element 1 and 2 respectively.'])
                            end    
                           
                        case 'logistic'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The scale parameter of the logistic distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the parameters of the logistic distribution.'])
                            end       
                            
                        case 'lognormal'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The first parameter of the log normal distribution cannot be negative or zero.'])
                                end
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The second parameter of the log normal distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the parameters of the log normal distribution.'])
                            end     
                            
                        case 'normal'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The variance of the normal distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the mean and the variance as element 1 and 2 respectively.'])
                            end 
                            
                        case 'skewedt'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 4
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x4 cell; '...
                                    '{mean,std,skewness,kurtosis}.'])
                            end  
                            
                        case 'skt'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 4
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x4 cell; '...
                                    '{location,scale,shape,dof}.'])
                            end       
                            
                        case 't'
                            
                            if iscell(propertyValue) && (numel(propertyValue) == 1 || numel(propertyValue) == 3)
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The number of degrees of freedom of the student-t distribution cannot be negative or zero.'])
                                end
                                if numel(propertyValue) == 3
                                    if propertyValue{3} <= 0
                                        error([mfilename ':: The scale parameter of the non-standardized student-t distribution cannot be negative or zero.'])
                                    end
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x1 cell with '...
                                    'the number of degrees of freedom as element 1 or with additional 2 more parameters; location as element 2 and scale as element 3'])
                            end
                            
                        case 'tri'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 3
                                if propertyValue{1} >= propertyValue{2}
                                    error([mfilename ':: The lower bound must be lower than the upper bound.'])
                                end
                                if propertyValue{1} > propertyValue{3}
                                    error([mfilename ':: The lower bound must be lower than or equal to the mode.'])
                                end
                                if propertyValue{2} < propertyValue{3}
                                    error([mfilename ':: The upper bound must be higher than or equal to the mode.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x3 cell with '...
                                    'the parameters of the triangular distribution.'])
                            end     
                            
                        case 'uniform'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the lower and upper support as element 1 and 2 respectively.'])
                            end 
                            
                        case 'wald'
                            
                            if iscell(propertyValue) && numel(propertyValue) == 2
                                if propertyValue{1} <= 0
                                    error([mfilename ':: The mean parameter of the wald distribution cannot be negative or zero.'])
                                end
                                if propertyValue{2} <= 0
                                    error([mfilename ':: The shape parameter of the wald distribution cannot be negative or zero.'])
                                end
                                obj.parameters = propertyValue;
                            else
                                error([mfilename ':: When type is set to ''' obj.type ''' the parameters property must be set to a 1x2 cell with '...
                                    'the mean and the shape parameter as element 1 and 2 respectively.'])
                            end     
                            
                    end
                
                case 'type'
                    
                    if ischar(propertyValue)
                        
                        supported = {'ast','beta','cauchy','chis','constant','exp','f','fgamma','finvgamma',...
                                     'gamma','hist','invgamma','kernel','empirical','lognormal','logistic',...
                                     'normal','skewedt','skt','t','tri','uniform','wald'};
                        ind       = strcmpi(propertyValue,supported);
                        if all(~ind)
                            error([mfilename ':: The distribution type ' propertyValue ' is not supported.'])
                        end
                        
                        % Do not allow type change if bounds are unsupported
                        domainFun  = str2func(['nb_distribution.' lower(propertyValue) '_domain']);
                        parameters = nb_distribution.defaultParameters(propertyValue);
                        d          = domainFun(parameters{:});
                        
                        % Check lowerBound
                        if ~isempty(obj.lowerBound)
                            if obj.lowerBound > d(2) || obj.lowerBound < d(1)
                                error([mfilename ':: The lower bound is outside the bounds of the ' propertyValue ' distribution; [' num2str(d(1)) ',' num2str(d(2)) ']'])
                           end
                        end
                        
                        % Check upperBound
                        if ~isempty(obj.upperBound)
                            if obj.upperBound > d(2) || obj.upperBound < d(1)
                                error([mfilename ':: The upper bound is outside the bounds of the ' propertyValue ' distribution; [' num2str(d(1)) ',' num2str(d(2)) ']'])
                            end
                        end
                        
                        obj.type = lower(propertyValue);
                        setDefaultParamters(obj);
                        
                    else
                        error([mfilename ':: The ' propertyName ' property must be a string.'])
                    end
                    
                case 'userdata'
                    
                    obj.userData = propertyValue;   

                case 'upperbound'
                    
                    if ~isnumeric(propertyValue)
                        error([mfilename ':: Upper bound must be a number.'])
                    end
                    
                    if strcmpi(obj.type,'constant')
                        error([mfilename,':: It is not possible to add a upper bound to a non-random variable (constant).'])
                    end
                    
                    if ~isempty(propertyValue)
                        d = domain(obj,1);
                        if propertyValue > d(2) || propertyValue < d(1)
                            error([mfilename ':: The upper bound is outside the bounds of the ' obj.name ' distribution; [' num2str(d(1)) ',' num2str(d(2)) ']'])
                        end
                    end
                    obj.upperBound = propertyValue;   
                    
                otherwise

                    error([mfilename ':: The class nb_distribution has no property ''' propertyName ''' or you have no access to set it.'])

            end

        end

    end
    
end
