function [obj,valid] = update(obj,type,warningOn,inGUI,groupIndex,varargin)
% Syntax:
%
% obj = update(obj,type)
% [obj,valid] = update(obj,type,warningOn,inGUI,groupIndex,varargin)
%
% Description:
%
% Update data of model group, and optionally re-estimate, re-solve and 
% forecast the models given the updated data
% 
% Input:
% 
% - obj         : A vector of objects of class nb_model_group
% 
% - type        : > ''         : Only update data. Default
%                 > 'estimate' : Update data and estimate.
%                 > 'solve'    : Update data, estimate and solve
%                 > 'forecast' : Update data, estimate, solve and forecast.
%
% - warningOn   : 'on' or 'off'. If 'on' only warnings are given while 
%                 the data source is updated, else an error will be given.
%                 Default is 'on'. Set it to 'off', if the 'write' option
%                 is used.
%
% - inGUI       : 'on' or 'off'. Indicate if the update command is called 
%                 in the GUI or not. Default is 'off'.
% 
% - groupIndex  : A 1 x nLevel double with the group level.
%
% Optional input:
%
% - 'write'     : Give this string as one of the optional inputs to write
%                 an error file if estimation or forecasting failes. The
%                 models that failes will then be removed when calling
%                 methods as compareForecast and aggregateForecast etc.
%                 See the valid property.
%
% Output:
% 
% - obj   : A vector of objects of class nb_model_group.
%
% - valid : A logical with size 1 x nObj. true at location ii if 
%           updating of model group ii succeded, otherwise false. If 
%           'write' is not used an error will be thrown instead, so in 
%           this case this output will be true for all models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        groupIndex = [];
        if nargin < 4
            inGUI = 'off';
            if nargin < 3
                warningOn = 'on';
                if nargin < 2
                    type = '';
                end
            end
        end
    end
    
    obj  = obj(:);
    nobj = numel(obj);
    if nobj > 1
        if isempty(groupIndex)
           groupIndex = 1; 
        end
        groupIndex = [groupIndex,1];
        valid      = true(1,nobj);
        for ii = 1:nobj
            groupIndex(1,2)     = ii; 
            [obj(ii),valid(ii)] = update(obj(ii),type,warningOn,'off',groupIndex,varargin{:});
        end
        return
    end
    
    inputs       = nb_model_generic.parseOptional(varargin{:});
    inputs       = nb_logger.openLoggerFile(inputs,obj);
    inputs.inGUI = inGUI;
        
    % Update the data, re-estimate, solve and forecast sub-models
    models = obj.models;
    if isempty(models)
        error([mfilename ':: No models has yet to be added to the model group.'])
    end

    validSub      = obj.valid;
    indMGroup     = cellfun(@(x)isa(x,'nb_model_group'),models);
    modelGroups   = models(indMGroup);
    modelsGeneric = models(~indMGroup);
    if ~isempty(modelGroups)
        [modelsG,validG]    = update([modelGroups{:}],type,warningOn,'off',[],inputs);
        models(indMGroup)   = nb_obj2cell(modelsG);
        validSub(indMGroup) = validG;
    end
    if ~isempty(modelsGeneric)
        [modelsG,validG]     = update([modelsGeneric{:}],type,warningOn,'off',[],inputs);
        models(~indMGroup)   = nb_obj2cell(modelsG);
        validSub(~indMGroup) = validG;
    end
    obj.models = models;
    obj.valid  = validSub;
    valid      = any(validSub); % If all fail, there are no need to continue

    % Update output from model group itself
    if isa(obj,'nb_model_selection_group') && valid

        % It is important the shift variables are updated first at 
        % this is needed in checkExpressions method later
        new = obj.options;
        if isfield(obj.options,'shift')
            if ~isempty(obj.options.shift)
                try
                    new.shift = update(new.shift,warningOn,inGUI);
                catch Err
                    
                    if strcmpi(warningOn,'on') && strcmpi(inGUI,'off')
                        message = ['Could not update the shift data of model with name ' obj.name];
                        nb_logger.logging(nb_logger.WARN,inputs,message,Err);
                    else
                        valid   = false;
                        message = ['Error while updating the shift data of model group; ' obj.name '::'];
                        nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                    end
                    
                end
            end
        end

        try
            new.data = update(new.data,warningOn,inGUI);
        catch Err
            
            if strcmpi(warningOn,'on') && strcmpi(inGUI,'off')
                message = ['Could not update the data of model with name ' obj.name];
                nb_logger.logging(nb_logger.WARN,inputs,message,Err);
            else
                valid   = false;
                message = ['Error while updating the data of model group; ' obj.name '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
            end
            
        end

        obj = setOptions(obj,new);

    end

    % Then we update the forecast
    if strcmpi(type,'forecast') && valid
        
        if ~nb_isempty(obj.forecastOutput)
            
            inputsGroup = obj.forecastOutput.inputs;
            func        = inputsGroup.function;
            inputsGroup = rmfield(inputsGroup,{'function'});
            if strcmpi(func,'aggregateForecast')
                
                type = 're-aggregated';
                if isa(inputsGroup.weights,'nb_ts')
                    if isUpdateable(inputsGroup.weights)
                        try
                            inputsGroup.weights = update(inputsGroup.weights,warningOn,inGUI);
                        catch Err
                            
                            if strcmpi(warningOn,'on') && strcmpi(inGUI,'off')
                                message = ['Could not update the weights the model group; ' obj.name];
                                nb_logger.logging(nb_logger.WARN,inputs,message,Err);
                            else
                                valid   = false;
                                message = ['Error while update the weights of model group; ' obj.name '::'];
                                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                            end

                        end
                    end
                end
                
                try
                    obj = aggregateForecast(obj,inputsGroup);
                catch Err
                    valid   = false;
                    message = ['Error while aggregating forecast of model group; ' obj.name '::'];
                    nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                end
                
            else
                
                type = 're-combined';
                try
                    obj = combineForecast(obj,inputsGroup);
                catch Err
                    valid   = false;
                    message = ['Error while combining forecast of model group; ' obj.name '::'];
                    nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                end
                
            end
            
        end
        
    end

    if strcmpi(inGUI,'on') && isempty(groupIndex)
        
        if ~valid
            nb_infoWindow('Something went wrong. See the error file in the nb_GUI folder located in your userpath.')
        else
            switch type   
                case ''
                    nb_infoWindow('Data is updated!')
                case 'estimate'
                    nb_infoWindow('Data is updated and the models are re-estimated!')
                case 'solve'
                    nb_infoWindow('Data is updated and the models are re-estimated and re-solved!')
                case 'forecast'
                    if nb_isempty(obj.forecastOutput)
                        nb_infoWindow(['Data is updated and the models are re-estimated, re-solved and re-forecasted, but the forecast could not be ' type '!'])
                    else
                        nb_infoWindow(['Data is updated and the models are re-estimated, re-solved, re-forecasted and the forecast is ' type '!'])
                    end
            end
        end
        
        models = obj.models;
        models = models(~obj.valid);
        names  = nb_getModelNames(models{:});
        if ~isempty(names)
            nb_errorWindow(['The following models/model groups did produce an error; ' toString(names)])
        end
        
    end
    
    % Close written file
    nb_logger.closeLoggerFile(inputs);
    
end
