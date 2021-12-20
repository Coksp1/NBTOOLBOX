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
% - obj         : A vector of objects of class 
%                 nb_model_recursive_detrending
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
% - obj   : A vector of objects of class nb_model_recursive_detrending.
%
% - valid : A logical with size 1 x nObj. true at location ii if 
%           updating of model group ii succeded, otherwise false. If 
%           'write' is not used an error will be thrown instead, so in 
%           this case this output will be true for all models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        
    % Update the data, re-estimate, solve and forecast sub-models
    inputs       = nb_model_generic.parseOptional(varargin{:});
    inputs       = nb_logger.openLoggerFile(inputs,obj);
    inputs.inGUI = inGUI;
    model        = obj.model;
    if isempty(model)
        error([mfilename ':: No model has yet to be added to the nb_model_recursive_detrending object.'])
    end

    [obj.modelIter,validM] = update(obj.modelIter,'estimate',warningOn,'off',[],inputs);
    if any(~validM)
        valid   = false;
        message = ['Error while updating the estimation of model; ' obj.name '::'];
        nb_logger.logging(nb_logger.ERROR,inputs,message);
    else
        valid = true;
    end
    
    % Then we update the forecast
    if strcmpi(type,'forecast') && valid
        
        if ~nb_isempty(obj.forecastOutput)
            
            try
                inputs = obj.forecastOutput.inputs;   
                obj    = forecast(obj,inputs);
            catch Err
                valid   = false;
                message = ['Error while forecasting the model; ' obj.name '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message);
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
                    nb_infoWindow('Data is updated and the model is re-estimated!')
                case 'solve'
                    nb_infoWindow('Data is updated and the model is re-estimated and re-solved!')
                case 'forecast'
                    nb_infoWindow(['Data is updated and the model is re-estimated, re-solved and re-forecasted!'])
            end
        end
        
    end
    
    % Close written file
    nb_logger.closeLoggerFile(inputs);
    
end
