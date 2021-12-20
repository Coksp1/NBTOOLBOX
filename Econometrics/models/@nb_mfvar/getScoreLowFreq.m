function scores = getScoreLowFreq(obj,type,freq,highPeriod,allPeriods,startDate,endDate,invert,rollingWindow,lambda)
% Syntax:
%
% scores = getScore(obj,type,freq)
% scores = getScore(obj,type,freq,highPeriod,allPeriods,startDate,...
%                   endDate,invert,rollingWindow,lambda)
%
% Description:
%
% Get forecasting scores using recursive evaluation. Nowcast is not
% evaluated, in this case see nb_mfvar.getForecastLowFreq! 
% 
% Input:
%
% - obj            : A vector of nb_model_group or nb_model_generic 
%                    objects.
% 
% - type           : A string with on of the following:
%                    - 'RMSE'  : Root mean squared error
%                    - 'MSE'   : Mean squared error
%                    - 'MAE'   : Mean absolute error
%                    - 'MEAN'  : Mean error
%                    - 'STD'   : Standard error of the forecast error
%                    - 'ESLS'  : Exponential of the sum of the log scores
%                    - 'EELS'  : Exponential of the mean of the log scores
%                    - 'MLS'   : Mean log score
% 
% - freq           : The frequency of the evaluated forecast. Only the
%                    variables observed at this frequency are evaluated.
%
% - highPeriod     : Give 0 to get the forecast when the data of low and  
%                    high frequency is balanced, 1 if the high frequency  
%                    data has one more observation, and so on. Default is 
%                    0.   
%
% - allPeriods     : true if you want the scores to be calculated for all 
%                    periods recursivly, or else give false, i.e. only 
%                    calculate the score for the last period. false is
%                    default.
% 
% - startDate      : The date to begin constructing the score. Can be
%                    empty. Either as a string or an object of class
%                    nb_date. Must be on the frequency of the most 
%                    frequent data used.
%
% - endDate        : The date to end constructiong the score. Can be
%                    empty. Either as a string or an object of class
%                    nb_date. Must be on the frequency of the most 
%                    frequent data used.
%
% - invert         : false or true. Default is false. Default is to report
%                    the score so that high value means good model. 
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

    if nargin < 10
        lambda = [];
        if nargin < 9
            rollingWindow = [];
            if nargin < 8
                invert = true;
                if nargin < 7
                    endDate = '';
                    if nargin < 6
                        startDate = '';
                        if nargin < 5
                            allPeriods = false;
                            if nargin < 4
                                highPeriod = 0;
                            end
                        end
                    end
                end
            end
        end
    end
    
    if nargin < 3
        error([mfilename ':: At least 2 inputs must be provided.'])
    end
    
    scores         = struct();
    obj            = obj(:);
    nobj           = size(obj,1);
    forecastOutput = {obj.forecastOutput};
    names          = {obj.name};
    for ii = 1:nobj
        
        if nb_isempty(forecastOutput{ii})
            name = names{ii};
            if isempty(name)
                name = ['model group ' int2str(ii)];
            end
            error([mfilename ':: You need to produce forecast using the forecast method for the model with name ' name])
        end
        
        try
            score = nb_mfvar.constructScoreLowFreq(forecastOutput{ii},type,freq,highPeriod,allPeriods,startDate,endDate,rollingWindow,lambda);
        catch Err
            name = names{ii};
            if isempty(name)
                name = ['model ' int2str(ii)];
            end
            nb_error([mfilename ':: You need to produce forecast with the needed forecasting evaluation for the model group '...
                             'with name ' name '. Error:: '], Err)
        end
        
        if invert
           switch lower(type)
                case {'mse','rmse','mae','std'} 
                    score = 1./score;
            end 
        end
        score = nb_data(score,type,1,forecastOutput{ii}.dependent);
        try
            scores.(names{ii}) = score;
        catch %#ok<CTCH>
            scores.(['Model' int2str(ii)]) = score;
        end
        
    end

end
