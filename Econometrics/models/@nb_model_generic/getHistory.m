function histData = getHistory(obj,vars,date,notSmoothed,type)
% Syntax:
%
% histData = getHistory(obj,vars,date,notSmoothed,type)
%
% Description:
%
% Get historical data
% 
% Input:
% 
% - obj         : A scalar nb_model_generic object
%
% - vars        : A cellstr with the variables to get. May include
%                 shocks/residuals. Only the variables found is returned, 
%                 i.e. no error is provided if not all variables are found.
%
% - date        : For recursivly estimated models, the residual and 
%                 smoothed estimates vary with the date of recursion, so  
%                 by this option you can get the residual and smoothed
%                 estimates of a given recursion.
%
%                 The same apply for real-time data.
% 
% - notSmoothed : Prevent getting history from smoothed estimates.
%
% - type        : Either 'smoothed' or 'updated'. Default is 'smoothed'.
%
% Output:
% 
% - histData : A nb_ts object with the historical data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        type = 'smoothed';
        if nargin < 4
            notSmoothed = false;
            if nargin < 3
                date = '';
            end
        end
    end
    if nargin < 2
        error([mfilename ':: The number of inputs must be at least 2.'])
    end
    if numel(obj)>1
        error([mfilename ':: This function only handles scalar nb_model_generic objects.'])
    end

    if isfield(obj.results,type) && ~notSmoothed
        
        % Get history from smoothed results instead for models estimated
        % by kalman filter methods
        estOpt    = obj.estOptions(end);
        histData1 = getFiltered(obj,type,false,false,'reporting','stored');
        indRemove = ismember(obj.options.data.variables,histData1.variables);
        data      = deleteVariables(obj.options.data,obj.options.data.variables(indRemove));
        histData1 = merge(histData1,data);
        if isnumeric(date)
            histData1 = histData1.window('','','',date);
        elseif ~isempty(date) && histData1.numberOfDatasets > 1
            startObj     = nb_date.toDate(date,obj.options.data.frequency);
            recStartDate = obj.options.data.startDate + (estOpt.recursive_estim_start_ind - 1);
            indRSD       = (startObj - recStartDate);
            histData1    = histData1.window('','','',indRSD);
        else
            histData1    = histData1.window('','','',histData1.numberOfDatasets);
        end
        %histData2  = nb_ts(estOpt.data,'',estOpt.dataStartDate,estOpt.dataVariables);
        %histData   = append(histData1,histData2);
        histData   = window(histData1,'','',vars);
        
    else   
        estOpt = obj.estOptions;
        if numel(estOpt) > 1 
            if isnumeric(date)
                estOpt = estOpt(date);
            else
                if ~estOpt(end).real_time_estim
                    % Missing method used, so we need to strip forecast
                    estOpt = estOpt(end);
                    if isfield(estOpt,'missingVariables')
                        [~,indM]                 = ismember(estOpt.missingVariables,estOpt.dataVariables);
                        data                     = estOpt.data(:,indM);
                        data(estOpt.missingData) = nan;
                        estOpt.data(:,indM)      = data;
                    end
                else
                    if isempty(date)
                        estOpt = estOpt(end);
                    else
                        % Real-time forecast, so we need to find the
                        % correct vintage of the historical data
                        startObj  = nb_date.toDate(date,obj.options.data.frequency);
                        startInd  = (startObj - obj.options.data.startDate) + 1;
                        endEstInd = [estOpt.estim_end_ind] + 1;
                        indRec    = startInd == endEstInd;
                        estOpt    = estOpt(indRec);
                    end
                end
            end
        else
            if isa(obj,'nb_mfvar')
                if obj.estOptions.estim_end_ind > size(obj.estOptions.data,1)
                    % If a nb_mfvar model is filtered on a updated dataset,
                    % the data stored at obj.estOptions.data may not be updated
                    obj.estOptions.data          = double(obj.options.data);
                    obj.estOptions.dataVariables = obj.options.data.variables;
                end
            end
        end
        data       = estOpt.data;
        dVars      = estOpt.dataVariables;
        startD     = estOpt.dataStartDate;
        [ind,indV] = ismember(vars,dVars);
        indV       = indV(ind);
        histData   = nb_ts(data(:,indV),'',startD,vars(ind));

        % Check if the missing vars are shocks
        vars = vars(~ind);
        if ~isempty(vars)
            
            if isa(obj,'nb_var')
                if isIdentified(obj)
                    res = getIdentifiedResidual(obj);
                else
                    res = getResidual(obj);
                end
            else
                res = getResidual(obj);
            end
            if ~isempty(date)
                startObj     = nb_date.toDate(date,obj.options.data.frequency);
                recStart     = estOpt.recursive_estim_start_ind;
                recStartDate = obj.options.data.startDate + (recStart - 1);
                indRSD       = (startObj - recStartDate);
                res          = res.window('','','',indRSD);
            else
                res          = res.window('','','',res.numberOfDatasets);
            end
            resVar = res.variables;
            ind    = ismember(resVar,vars);
            if ~isempty(resVar(ind))
                res      = window(res,'','',resVar(ind));
                histData = merge(histData,res);
            end
            ind  = ismember(vars,resVar);
            vars = vars(~ind);
        end
        
        % Check for deterministic variables
%         if ~isempty(vars)
%             
%             det  = {'Constant','Time-trend'};
%             data = [];
%             ind  = false(1,2);
%             if any(strcmp('Constant',vars))
%                 data   = ones(histData.numberOfObservations,1);
%                 ind(1) = true;
%             end
%             if any(strcmp('Time-trend',vars))
%                 data   = [data,transpose(1:histData.numberOfObservations)];
%                 ind(2) = true;
%             end
%             detData  = nb_ts(data,'',histData.startDate,det(ind));
%             histData = merge(histData,detData);
%             ind      = ismember(lower(vars),det);
%             vars     = vars(~ind);
%             
%         end
        
        % Check if the missing vars are time-varying parameters
        if isa(obj,'nb_tvp')
            ind  = ismember(vars,histData.variables);
            vars = vars(~ind);
            if ~isempty(vars)
                [~,~,hMean] = plotTimeVarying(obj);
                if ~isempty(date)
                    startObj     = nb_date.toDate(date,obj.options.data.frequency);
                    recStart     = estOpt.recursive_estim_start_ind;
                    recStartDate = obj.options.data.startDate + (recStart - 1);
                    indRSD       = (startObj - recStartDate);
                    hMean        = hMean.window('','','',indRSD);
                else
                    hMean        = hMean.window('','','',res.numberOfDatasets);
                end
                hVar = hMean.variables;
                ind  = ismember(hVar,vars);
                if ~isempty(hVar(ind))
                    hMean    = window(hMean,'','',hVar(ind));
                    histData = merge(histData,hMean);
                end
            end
        end

    end
    
end
