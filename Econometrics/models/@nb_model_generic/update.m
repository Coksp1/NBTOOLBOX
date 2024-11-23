function [obj,valid] = update(obj,type,warningOn,inGUI,groupIndex,varargin)
% Syntax:
%
% obj         = update(obj,type)
% [obj,valid] = update(obj,type,warningOn,inGUI,groupIndex,varargin)
%
% Description:
%
% Update data of model, and optionally re-estimate, re-solve and forecast
% the models given the update data
% 
% Input:
% 
% - obj         : A vector of object of class nb_model_generic
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
%                 in the GUI or not. Default is 'off'. When 'on' a waitbar
%                 will be created to tell the user about the status.
%
% - groupIndex  : A 1 x nLevel double with the group level. Default is
%                 [].
% 
% Optional input:
%
% - 'write'     : Give this string as one of the optional inputs to write
%                 an error file if updating of data, estimation or  
%                 forecasting failes. All objects will be returned, but  
%                 can be removed by indexing by the valid output.
%
% - 'waitbar'   : Give this string as one of the optional inputs to add 
%                 waitbar for the loop over models in the estimation step.
%
% Output:
% 
% - obj   : A vector of object of class nb_model_generic
%
% - valid : A logical with size 1 x nObj. true at location ii if 
%           estimation or forecasting of model ii succeded, otherwise 
%           false. If 'write' is not used an error will be thrown instead, 
%           so in this case this output will be true for all models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

    [inputs,varargin] = nb_model_generic.parseOptional(varargin{:});
    inputs            = nb_logger.openLoggerFile(inputs,obj);
    inputs.inGUI      = inGUI;
    obj               = obj(:);
    nobj              = numel(obj);
    names             = getModelNames(obj);

    if strcmpi(inGUI,'on')
        extra = nb_model_generic.groupIndexText(groupIndex);
        switch lower(type)
            case ''
                maxIter = 1;
            case 'estimate'
                maxIter = 2;
            case 'solve'
                maxIter = 3;
            otherwise
                maxIter = 4;
        end
        h      = nb_waitbar([],'Update...',maxIter,1);
        h.text = ['Updating data ' extra '...'];
    end

    if nobj > 1
        string = 'models are';
    else
        string = 'model is';
    end
    
    % Update the data
    %======================================================================
    valid = true(nobj,1);
    for ii = 1:nobj
        
        try
            % Here set.dataOrig is triggered!
            obj(ii).dataOrig = update(obj(ii).dataOrig,warningOn,inGUI);
        catch Err
            if strcmpi(warningOn,'on') && strcmpi(inGUI,'off')
                message = ['Could not update the data of model with name ' names{ii}];
                nb_logger.logging(nb_logger.WARN,inputs,message,Err);
            else
                message = ['Error while updating the data of model; ' names{ii} '::'];
                nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                if inputs.write
                    valid(ii) = false;
                else
                    if strcmpi(inGUI,'on')
                        delete(h);
                    end
                end
            end
        end
        
    end
    
    if isempty(type)
        if strcmpi(inGUI,'on')
            delete(h)
            nb_infoWindow('Data is updated')
        end
        return
    end
    
    if strcmpi(inGUI,'on')
        h.status = 1;
        h.text = ['Estimating model(s)' extra '...'];
    end
    
    % Estimate model
    %======================================================================
    %valid = isestimated(obj) & valid;
    try
        [obj(valid),success] = estimate(obj(valid),inputs);
    catch Err
        if strcmpi(inGUI,'on')
            delete(h);
        end
        nb_logger.logging(nb_logger.ERROR,inputs,'Fatal error::',Err);
        return
    end
    valid(valid) = valid(valid) & success;

    if strcmpi(type,'estimate')
        if strcmpi(inGUI,'on')
            nb_infoWindow(['Data is updated and the ' string ' is re-estimated'])
            delete(h);
        end
        return
    end
    
    if strcmpi(inGUI,'on')
        h.status = 2;
        h.text   = ['Solve model(s)' extra '...'];
    end

    % Solve model
    %======================================================================
    try
        obj(valid) = solveVector(obj(valid));
    catch Err
        if strcmpi(inGUI,'on')
            delete(h);
        end
        nb_logger.logging(nb_logger.ERROR,inputs,'Fatal error::',Err);
        return
    end
    
    if strcmpi(type,'solve')   
        if strcmpi(inGUI,'on')
            nb_infoWindow(['Data is updated and the ' string ' re-estimated and re-solved'])
            delete(h);
        end
        return
    end

    if strcmpi(inGUI,'on')
        h.status = 3;
        h.text   = ['Forecasting model(s)' extra '...'];
    end
    
    % Forecast model
    %======================================================================
    fcstInputs = struct([]);
    validObj   = obj(valid);
    nvobj      = numel(validObj);
    for ii = 1:nvobj
        
        fcst = validObj(ii).forecastOutput;
        if ~nb_isempty(fcst)
            
            % Get inputs stored
            inputsT                 = fcst.inputs;
            inputsT.nObj            = nvobj;
            inputsT.index           = ii;
            inputsT.startIndWarning = nb_parseOneOptional('startIndWarning',false,varargin{:});
            
            % Update the conditional data
            if isfield(inputsT,'condDB')
                if isa(inputsT.condDB,'nb_ts') || isa(inputsT.condDB,'nb_data')
                    try
                        % This may also update obj.options.data in the case
                        % of real-time data
                        [inputsT.condDB,obj] = getCondDB(obj,inputsT.condDB.userData{:});
                    catch Err
                        if strcmpi(warningOn,'on') && strcmpi(inGUI,'off')
                            message = ['Could not update the conditional data of model with name ' names{ii}];
                            nb_logger.logging(nb_logger.WARN,inputs,message,Err);
                        else
                            message = ['Error while updating the conditional data of model; ' names{ii} '::'];
                            nb_logger.logging(nb_logger.ERROR,inputs,message,Err);
                            if inputs.write
                                valid(ii) = false;
                            else
                                if strcmpi(inGUI,'on')
                                    delete(h);
                                end
                            end
                        end
                    end
                end
            end
            
            if ~isempty(inputsT.perc)
                inputsT.perc = nb_interpretPerc(inputsT.perc,true);
            end
            fcstInputs = nb_structdepcat(fcstInputs,inputsT);
            
        end
    end
    
    % Update the forecast
    inputs.inputs = fcstInputs;
    if any(valid)
        try
            [obj(valid),success] = forecast(obj(valid),fcst.nSteps,inputs);
        catch Err
            if strcmpi(inGUI,'on')
                delete(h);
            end
            nb_logger.logging(nb_logger.ERROR,inputs,'Fatal error::',Err);
            return
        end
        valid(valid) = valid(valid) & success;
    end
    
    if strcmpi(inGUI,'on')
        h.status = 4;
        if inputs.write
            if all(valid)
                nb_infoWindow(['Data is updated and the ' string ' re-estimated, re-solved and re-forecasted'])
            else
                nb_infoWindow(['Data is updated and the ' string ' re-estimated, re-solved and re-forecasted. '...
                               'The following models did produce an error; ' toString(names(~valid))])
            end
        else
            nb_infoWindow(['Data is updated and the ' string ' re-estimated, re-solved and re-forecasted'])
        end
        delete(h);
    end
    
    % Close written file
    nb_logger.closeLoggerFile(inputs);
    
end
