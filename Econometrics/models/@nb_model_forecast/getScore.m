function scores = getScore(obj,type,allPeriods,startDate,endDate,invert,rollingWindow,lambda)
% Syntax:
%
% scores = getScore(obj,type,allPeriods)
% scores = getScore(obj,type,allPeriods,startDate,endDate,invert,...
%                   rollingWindow,lambda)
%
% Description:
%
% Get forecasting scores using recursive evaluation.
% 
% Input:
%
% - obj            : A vector of nb_model_group or nb_model_generic 
%                    objects.
% 
% - type           : A string with on of the following:
%                    - 'RMSE'  : One over root mean squared error
%                    - 'MSE'   : One over mean squared error
%                    - 'MAE'   : One over mean absolute error
%                    - 'MEAN'  : One over mean error
%                    - 'STD'   : One over standard error of the forecast 
%                                error
%                    - 'ESLS'  : Exponential of the sum of the log scores
%                    - 'EELS'  : Exponential of the mean of the log scores
%                    - 'MLS'   : Mean log score
%
%                    If the object intput is a vector, the type input can
%                    also be a cellstr array wit matching length.
%
%                    Caution: See comment to the invert input!
% 
% - allPeriods     : true if you want the scores to be calculated for all 
%                    periods recursivly, or else give false, i.e. only 
%                    calculate the score for the last period. false is
%                    default.
% 
% - startDate      : The date to begin constructing the score. Can be
%                    empty. Either as a string or an object of class
%                    nb_date. 
%
% - endDate        : The date to end constructiong the score. Can be
%                    empty. Either as a string or an object of class
%                    nb_date.
%
% - invert         : false or true. Default is false. Default is to report
%                    the score so that high value means good model. E.g.
%                    setting type to 'RMSE' and invert to true will give
%                    NOT inverted root mean squared error!
%
% - rollingWindow  : Set it to a number if the combination weights are to 
%                    be calculated using a rolling window. Default is 
%                    empty, i.e. to calculate the weights recursivly using 
%                    the the full history at each recursive step.
%
% - lambda         : Give the value of the parameter of the exponential  
%                    decaying weights on past forecast errors when 
%                    constructing the score. If empty the weights on all 
%                    past forecast errors are equal.
%
% Output:
% 
% - scores : A struct. Each field gives the forecasting evaluation for each
%            model, and for each model the output is given as a nb_data
%            object with size nHor x nVars x nPeriods. nPeriod is 1 if
%            allPeriod is given as false.
%
% See also:
% nb_model_group.combineForecast, nb_model_generic.constructScore
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        lambda = [];
        if nargin < 7
            rollingWindow = [];
            if nargin < 6
                invert = false;
                if nargin < 5
                    endDate = '';
                    if nargin < 4
                        startDate = '';
                        if nargin < 3
                            allPeriods = false;
                        end
                    end
                end
            end
        end
    end
    
    if nargin < 2
        error([mfilename ':: At least 2 inputs must be provided.'])
    end
    
    scores         = struct();
    obj            = obj(:);
    nobj           = size(obj,1);
    forecastOutput = {obj.forecastOutput};
    names          = {obj.name};
    classType      = isa(obj,'nb_model_group');
    if iscellstr(type)
        type = type(:);
        if length(type) ~= nobj
           error([mfilename ':: type must either be a 1 x ' int2str(nobj) ' or a one line char.']) 
        end
    else
        type = {type};
        type = type(ones(1,nobj));
    end
    for ii = 1:nobj
        
        if nb_isempty(forecastOutput{ii})
            name = names{ii};
            if isempty(name)
                name = ['model group ' int2str(ii)];
            end
            error([mfilename ':: You need to produce forecast using the forecast method for the model with name ' name])
        end
        
        try
            score = nb_model_generic.constructScore(forecastOutput{ii},type{ii},allPeriods,startDate,endDate,[],rollingWindow,lambda);
        catch Err
            name = names{ii};
            if isempty(name)
                name = ['model ' int2str(ii)];
            end
            nb_error([mfilename ':: You need to produce forecast with the needed forecasting evaluation for the model group '...
                             'with name ' name '. Error:: '], Err)
        end
        
        if invert
            if strncmpi(type{ii},'mse',3) || strncmpi(type{ii},'mae',3) || strncmpi(type{ii},'rmse',3) ||...
                    strncmpi(type{ii},'std',3) || strncmpi(type{ii},'mean',4)
                score = 1./score;
            end
        end
        
        if isfield(forecastOutput{ii},'nowcast')
            start = 1-forecastOutput{ii}.nowcast;
        else
            start = 1;
        end
        
        if classType
            vars  = forecastOutput{ii}.variables;
        else
            vars  = forecastOutput{ii}.dependent;
        end
        score = nb_data(score,type{ii},start,vars);
        try
            scores.(names{ii}) = score;
        catch %#ok<CTCH>
            scores.(['Model' int2str(ii)]) = score;
        end
        
    end

end
