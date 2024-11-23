function [condDB,obj] = getCondDB(obj,endDate,nSteps,exoOnly,recursive,recStart)
% Syntax:
%
% [condDB,obj] = getCondDB(obj,endDate,nSteps,exoOnly,recursive,recStart)
%
% Description:
%
% Get conditional information on the variables of the model given a end 
% date of estimation. May also provied recursive conditional information.
%
% Caution : If the dataset is of type real-time, this function interpret
%           the endDate input as the estimation end date for the last
%           recursion. It also assumes that each vintage give rise
%           to one new historical observation on each series of the model!
%           It will also remove the conditional information from the
%           obj.options.data option to make the estimation with real-time
%           data work as supposed to.
% 
% Caution : If you do some transformation of your data using the 
%           nb_modelData.createVariables you should run this before calling
%           this method!
%
% Input:
% 
% - obj       : An object of class nb_model_generic.
%
% - endDate   : An object of class nb_date or a string representing a date.
%               This option will be interpreted as the end date of 
%               estimation or as the end date of the last recursion if 
%               recursive estimation is done. See description for a note 
%               on real-time estimation.
%
% - nSteps    : Number of forecasting steps. As a scalar integer. 
%
% - exoOnly   : Set to true if you only want the conditinal information
%               on the exogenous variables of the model. Default is false.
%
% - recursive : Indicate if you want recursive conditional information
%               or not. If you want to do recursive conditional forecast
%               you should set this input to true, otherwise false. Default
%               is false.
%
% - recStart  : An object of class nb_date or a string representing a date.
%               This option will be interpreted as the start date of
%               recursive forecast, i.e. the first forecast period of the
%               recursive forecast. Only needed if recursive is set to
%               true.
% 
% Output:
% 
% - condDB    : As a nb_ts or nb_data object. Can be given as input to the
%               condDB option of the nb_model_generic.forecast method.
%
% - obj       : An object of class nb_model_generic. When dealing with 
%               real-time data we want to strip the data of forecast before
%               going to estimation, so the options.data option may change.
%
% See also:
% nb_modelData.createVariables, nb_model_generic.forecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        recStart = '';
        if nargin < 5
            recursive = false;
            if nargin < 4
                exoOnly = false;
            end
        end
    end

    data = obj.options.data;
    if isempty(data)
        error([mfilename ':: No data has been assign to the model.'])
    end
    
    if ~nb_isScalarInteger(nSteps)
        error([mfilename ':: nSteps must be a scalar integer greater than 0.'])
    elseif nSteps < 1
        error([mfilename ':: nSteps must be a scalar integer greater than 0.'])
    end
    
    endDate = nb_date.date2freq(endDate);
    if endDate.frequency ~= data.frequency
        error([mfilename ':: The frequency of the endDate (' nb_date.getFrequencyAsString(endDate.frequency) ') input is not '...
                         'the same as that of the data (' nb_date.getFrequencyAsString(data.frequency) ')'])
    end
    
    if recursive
        
        if isempty(recStart)
            error([mfilename ':: The recStart date must be provided if recursive is set to true.'])
        end
        
        recStart = nb_date.date2freq(recStart);
        if recStart.frequency ~= data.frequency
            error([mfilename ':: The frequency of the recStart (' nb_date.getFrequencyAsString(recStart.frequency) ') input is not '...
                             'the same as that of the data (' nb_date.getFrequencyAsString(data.frequency) ')'])
        end
        
    end
    
    if exoOnly
        vars = obj.exogenous.name;
    else
        vars = obj.dependent.name;
        if isprop(obj,'block_exogenous')
            vars = [vars, obj.block_exogenous.name];
        end
        vars = [vars,obj.exogenous.name];
    end
    
    if isempty(vars)
        error([mfilename ':: Model has not been formualted.'])
    end
    
    endFcst = endDate + nSteps;
    if endFcst > data.endDate
        error([mfilename ':: There is no data for the conditional information up until the date ' toString(endFcst) ' (endDate + nSteps)'])
    end
    
    if isRealTime(data)
        
        if recursive
            condDB                 = realTime2RecCondData(data,nSteps,data.frequency,false,2);
            condDB                 = window(condDB,'','',vars);
            obj.preventSettingData = false;
            obj.options.data       = stripFcstFromRealTime(obj.options.data);
            obj.preventSettingData = true;
        else
            condDB = window(data,endDate + 1,endFcst,vars,data.numberOfDatasets);
        end
        
    else
        
        if recursive
            condDB = window(data,recStart + 1,endFcst,vars);
            condDB = splitSample(condDB,nSteps,false);
        else
            condDB = window(data,endDate + 1,endFcst,vars);
        end
        
    end
    
    % Check that no exogenous variables has missing conditional information
    if ~isempty(obj.exogenous.name)
        conDBExo = window(condDB,'','',obj.exogenous.name);
        conDBExo = double(conDBExo);
        if any(isnan(conDBExo(:)))
            error([mfilename ':: None of the exogenous variables can have missing conditional data.'])
        end
    end
    
    % Assign inputs to userData as these are used during update!
    condDB.userData = {endDate,nSteps,exoOnly,recursive,recStart};

end
