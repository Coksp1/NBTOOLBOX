function varargout = empiricalMoments(obj,varargin)
% Syntax:
%
% [m,c]             = empiricalMoments(obj,varargin)
% [m,c,ac1]         = empiricalMoments(obj,varargin)
% [m,c,ac1,ac2]     = empiricalMoments(obj,varargin)
% [m,c,ac1,ac2,...] = empiricalMoments(obj,varargin)
%
% Description:
%
% Calculate empirical moments; I.e. mean, covariance/correlation, 
% autocovariance/autocorrelation of the data of the nb_model_generic 
% object. The options.data property must contain the selected variables!
% 
% Caution: This method only works on time-series models
%
% Input:
% 
% - obj         : An object of class nb_model_generic
%
% Optional inputs;
%
% - 'vars'      : Either 'dependent' or a cellstr with the wanted variables. 
%                 'dependent' will return the moment of the dependent 
%                 variables. 'dependent' is default.
%
% - 'output'    : Either 'nb_cs' or 'double'. Default is 'nb_cs'.
%
% - 'stacked'   : I the output should be stacked in one matrix or 
%                 not. true or false. Default is false.
%
% - 'nLags'     : Number of lags to compute when 'stacked' is set to 
%                 true. 
% 
% - 'type'      : Either 'covariance' or 'correlation'. Default is 
%                 'correlation'.
%
% - 'startDate' : The start date of the calculations. Default is the start
%                 date of the options.data property. Only for time-series!
%                 Must be a string or a nb_date object.
%
% - 'endDate'   : The end date of the calculations. Default is the end
%                 date of the options.data property. Only for time-series!
%                 Must be a string or a nb_date object.
%
% - 'demean'    : true (demean data during estimation of the 
%                 autocovariance matrix), false (do not). Defualt is true.
%
% Output:
% 
% - varargout{1} : The mean, as a 1 x nVar nb_cs object or double.
%
% - varargout{2} : The contemporanous covariances/correlations, as a nVar 
%                  x nVar nb_cs object or double. The variance is along 
%                  the diagonal. (Will be symmetric)
%
% - varargout{i} : X > 2. The auto-covariances/correlations, as a nVar 
%                  x nVar nb_cs object or double. Along the diagonal is the
%                  auto-covariance/correlation with the variable itself. In
%                  the upper triangular part the you can find cov(x,y(-i)),
%                  where x is the variable along the first dimension. In
%                  the lower triangular part the you can find cov(x(-i),y),
%                  where x is the variable along the first dimension.
%
%                  E.g: You have two variables x and y, then to find
%                       cov(x,y(-i)) you can use 
%                       getVariable(varargin{i},'y','x'), 
%                       while to get cov(x(-i),y) (== cov(x,y(+i))) you  
%                       can use getVariable(varargin{i},'x','y'). (This 
%                       example only works if the output is of class nb_cs)
%
% See also:
% nb_model_generic.graphCorrelation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargout < 1
        return
    end
 
    default = {'vars',         'dependent',     {@ischar,'&&',{@nb_ismemberi,{'dependent',''}},'||',@iscellstr};...
               'output',       'nb_cs',         {{@nb_ismemberi,{'nb_cs','double'}}};...
               'startDate',    '',              {{@isa,'nb_date'},'||',@ischar,'||',@isempty};...
               'endDate',      '',              {{@isa,'nb_date'},'||',@ischar,'||',@isempty};...
               'nLags',        1,               {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'stacked',      false,           {@islogical,'&&',@isscalar};...
               'demean',       false,           {@islogical,'&&',@isscalar};...
               'type',         'correlation',   {{@nb_ismemberi,{'correlation','covariance'}}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar nb_model_generic object.'])
    end
    
    if ischar(inputs.vars) || isempty(inputs.vars)
        dep = obj.dependent.name;
    else
        dep = inputs.vars; 
    end
    
    % Get the variables to calculate the moments of
    opt       = obj.options;
    data      = opt.data;
    [ind,loc] = ismember(dep,data.variables);
    if any(~ind)
        error([mfilename ':: Some of the selected variables ' toString(dep(~ind)) ' is not stored in the options.data property.'])
    end
    if isa(data,'nb_ts')
        data = window(data,inputs.startDate,inputs.endDate);
    end
    emp = data.data(:,loc);
    
    % Calculate moments
    if inputs.stacked
        nLags = inputs.nLags;
    else
        nLags = nargout - 2;
    end
    m = mean(emp,1);
    if nLags > -1    
        if strcmpi(inputs.type,'correlation')
            c = nb_autocorrMat(emp,nLags,inputs.demean);
        else
            c = nb_autocovMat(emp,nLags,inputs.demean);
        end
    end
    
    if inputs.stacked
        
        % Construct stacked autocorrelation matrix
        sigmaF = nb_constructStackedCorrelationMatrix(c);
        
        % Construct object
        if strcmpi(inputs.output,'nb_cs')
            if size(dep,1) > 1
                dep = dep';
            end
            autoVars     = [strcat(dep,'_lag0'),nb_cellstrlag(dep,nLags,'varFast')];
            autoVars     = strrep(autoVars,'_lag','_period');
            varargout{1} = nb_cs(sigmaF,'',autoVars,autoVars,false);
        else
            varargout{1} = sigmaF;
        end

    else
    
        % Return in the wanted format
        varargout = cell(1,nargout);
        if strcmpi(inputs.output,'nb_cs')
            varargout{1} = nb_cs(m,'',{'Mean'},dep,false);
        else
            varargout{1} = m;
        end

        for jj = 2:nLags+2

            if strcmpi(inputs.output,'nb_cs')
                varargout{jj} = nb_cs(c(ind,ind,jj-1),'',dep,dep,false);
            else
                varargout{jj} = c(:,:,jj-1,:);
            end

        end
        
    end
    
end
