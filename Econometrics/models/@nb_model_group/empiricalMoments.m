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
% autocovariance/autocorrelation of the data of the nb_model_group 
% object. The options.data property of the models property must contain 
% the selected variables!
%
% Caution: This method only works on time-series models
% 
% Input:
% 
% - obj         : An object of class nb_model_group
%
% Optional inputs;
%
% - 'vars'      : A cellstr with the wanted variables.
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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargout < 1
        return
    end
 
    default = {'vars',         '',              @iscellstr;...
               'output',       'nb_cs',         {{@nb_ismemberi,{'nb_cs','double'}}};...
               'startDate',    '',              {{@isa,'nb_date'},'||',@ischar,'||',@isempty};...
               'endDate',      '',              {{@isa,'nb_date'},'||',@ischar,'||',@isempty};...
               'nLags',        1,               @(x)nb_isScalarInteger(x,0);...
               'stacked',      false,           @nb_isScalarLogical;...
               'demean',       true,            @nb_isScalarLogical;...
               'shrink',       false,           {@nb_isScalarLogical,'||',@(x)nb_isScalarNumberClosed(x,0,1)};...
               'type',         'correlation',   {{@nb_ismemberi,{'correlation','covariance'}}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    dep = inputs.vars; 
    if isempty(dep)
        error([mfilename ':: The ''vars'' input must be provided'])
    end
    
    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar nb_model_group object.'])
    end
    
    % Get the variables to calculate the moments of
    histData = getHistory(obj,dep);
    histData = window(histData,inputs.startDate,inputs.endDate);
    found    = ismember(dep,histData.variables);
    if any(~found)
        error([mfilename ':: Cannot locate the variable(s); '])
    end
    histData = reorder(histData,dep);
    emp      = histData.data;
    
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
            varargout{1} = nb_cs(m,'',{'Mean'},dep);
        else
            varargout{1} = m;
        end

        for jj = 2:nLags+2

            if strcmpi(inputs.output,'nb_cs')
                [sDep,ind]    = sort(dep);
                varargout{jj} = nb_cs(c(ind,ind,jj-1),'',sDep,sDep);
            else
                varargout{jj} = c(:,:,jj-1,:);
            end

        end
        
    end
    
end
