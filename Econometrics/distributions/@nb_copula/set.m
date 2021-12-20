function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of the nb_copula object.
% 
% Type properties(obj) in the command line to get a  list of supported 
% properties, and type help nb_copula.<propertyName> to get help on a  
% specific property.
%
% Input:
% 
% - obj      : An object of class nb_copula
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
% obj = obj.set('type','kendall');
% 
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj = size(obj,2);
    if nobj > 1
        for ii = 1:nobj
            set(obj(ii),varargin{:});
        end
        return
    end

    bSet = 0;
    ind1 = find(strcmpi('distributions',varargin));
    ind2 = find(strcmpi('sigma',varargin));
    if not(isempty(ind1) || isempty(ind2))
        bSet = 1;
        if any(ind2(end) < ind1(end))
            error([mfilename ':: If you want to set the property sigma and the property type of the copula, the property sigma must set last in the call!'])
        end
    end
    
    for jj = 1:2:size(varargin,2)

        propertyName  = varargin{jj};
        propertyValue = varargin{jj + 1};

        if ischar(propertyName)

            switch lower(propertyName)
                
                case 'distributions'
                    
                    if ~isa(propertyValue,'nb_distribution')
                        error([mfilename ':: The distributions property must be set to a 1xN vector of nb_distribution objects, where N>1.'])
                    end

                    [dim1,dim2] = size(propertyValue);
                    if dim2 < 2 || dim1 ~= 1
                        error([mfilename ':: The distributions property must be set to a 1xN vector of nb_distribution objects, where N>1.'])
                    end
                    
                    if ~bSet && ~isempty(obj.sigma)
                        
                        if size(obj.sigma,2) ~= size(propertyValue,2)
                            error([mfilename ':: The size of the property sigma (' int2str(size(obj.sigma,2)) ') and the new '...
                                             'size of the property distributions (' int2str(dim2) ' does not match.'])
                        end
                        
                    end
                    obj.distributions = propertyValue;
                    
                    if isempty(obj.sigma) % Default correlation matrix
                        obj.sigma = diag(ones(dim2,1));
                    end
                    
                case 'sigma'
                    
                    [dim1,dim2] = size(propertyValue);
                    if dim1 ~= dim2
                        error([mfilename ':: The property sigma must be set to a symmetric matrix.'])
                    end
                    
                    if size(obj.distributions,2) ~= dim2
                        error([mfilename ':: The size of the property distributions (' int2str(size(obj.distributions,2)) ') and the new '...
                                         'size of the property sigma (' int2str(dim2) ') does not match.'])
                    end 
                    obj.sigma = propertyValue;
                    
                case 'type'
                    
                    if ischar(propertyValue)
                        
                        supported = {'none','spearman','kendall'};
                        ind       = strcmpi(propertyValue,supported);
                        if all(~ind)
                            error([mfilename ':: The type ' propertyValue ' is not supported.'])
                        end
                        obj.type = lower(propertyValue);
                        
                    else
                        error([mfilename ':: The ' propertyName ' property must be a string.'])
                    end

                otherwise

                    error([mfilename ':: The class nb_copula has no property ''' propertyName ''' or you have no access to set it.'])

            end

        end

    end
    
end
