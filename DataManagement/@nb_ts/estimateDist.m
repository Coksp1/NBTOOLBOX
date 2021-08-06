function dist = estimateDist(obj,type,estimator,dim,output,varargin)
% Syntax:
%
% dist = estimateDist(obj,type)
%
% Description:
%
% Estimate distributions of the series in the nb_ts object.
% 
% Caution : This method strip all nan values.
%
% Input:
% 
% - obj       : An object of class nb_ts.
%
% - type      : The type of distribution to estimate. See the
%               'type' property of the nb_distribution class
%               for the supported types. (Some may not be possible
%               to estimate using 'mle' and/or 'mme'.) Default
%               is 'normal';
%
%               Caution : If estimator is equal to 'kernel', this
%                         input is not used.
%
%               Caution : If type is set to 'hist', no estimator is
%                         used but the returned nb_distribution 
%                         object instead represent a histogram.
% 
% - estimator : Either 'mle' (maximum likelihood), 'mme' (methods
%               of moments) or 'kernel' (normal kernel density 
%               estimation). Default is 'mle'.
%
% - dim       : The dimension to estimate densities over. Either
%               1, 2 or 3. Defualt is 1.
%
% - output    : Either 'nb_distribution' (default) or 'nb_dataSource'.
%               If 'nb_dataSource' is choosen the output will be a nb_ts
%               object if dim equal 2 or 3, while it will be a nb_cs object
%               if dim equal 1.
%
% Optional input:
%
% - varargin  : Optional input given to the nb_ksdensity function. Please 
%               see help for that function.
%
% Output:
% 
% - dist : An object of class nb_distribution, nb_ts or nb_cs.
%
% See also:
% nb_distribution
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        output = '';
        if nargin < 4
            dim = 1;
            if nargin < 3
                estimator = 'mle';
                if nargin < 2
                    type = 'normal';
                end
            end
        end
    end
    
    if isempty(type)
        type = 'normal';
    end
    if isempty(estimator)
        estimator = 'mle';
    end
    if isempty(dim)
        dim = 1;
    end

    d = obj.data;
    if dim == 2
        d = permute(d,[2,1,3]);
    elseif dim == 3
        d = permute(d,[3,2,1]);
    end
    [~,s2,s3] = size(d);
    
    dist(1,s2,s3) = nb_distribution;
    if strcmpi(type,'hist')  
        for pp = 1:s3
            for vv = 1:s2
                dt            = d(:,vv,pp);
                dt(isnan(dt)) = [];
                dist(1,vv,pp) = nb_distribution('type','hist','parameters',{dt});
            end
        end
        return
    elseif strcmpi(estimator,'kernel')
        for pp = 1:s3
            for vv = 1:s2
                dt            = d(:,vv,pp);
                dt(isnan(dt)) = [];
                dist(1,vv,pp) = nb_distribution.estimate(dt,[],varargin{:});
            end
        end
        return
    end

    
    switch lower(estimator)
        
        case 'mle'
            
            for pp = 1:s3
                for vv = 1:s2
                    dt            = d(:,vv,pp);
                    dt(isnan(dt)) = [];
                    dist(1,vv,pp) = nb_distribution.mle(dt,type);
                end
            end
            
        case 'mme'
            
            for pp = 1:s3
                for vv = 1:s2
                    dt            = d(:,vv,pp);
                    dt(isnan(dt)) = [];
                    dist(1,vv,pp) = nb_distribution.mme(dt,type);
                end
            end
            
        otherwise
            error([mfilename ':: Unsupported estimator ' estimator])
    end
    
    if dim == 2
        dist = permute(dist,[2,1,3]);
    elseif dim == 3
        dist = permute(dist,[3,2,1]);
    end
    
    if strcmpi(output,'nb_dataSource') 
        
        if dim == 2
            dist = nb_ts(dist,obj.dataNames,obj.startDate,{'Cross_variables'});
        elseif dim == 3
            dist = nb_ts(dist,'Cross_pages',obj.startDate,obj.variables);
        else
            dist = nb_cs(dist,obj.dataNames,'Cross_time',obj.variables);
        end
        
        if obj.isUpdateable()
            
            if dim == 1
                obj   = obj.addOperation(@estimateDist,[{type,estimator,dim,output},varargin]);
                links = obj.links;
                dist  = dist.setLinks(links);
            else
                dist  = dist.addOperation(@estimateDist,[{type,estimator,dim,output},varargin]);
            end
            
        end
        
    end
    
end
