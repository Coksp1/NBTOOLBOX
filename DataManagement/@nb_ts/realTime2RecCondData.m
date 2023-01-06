function out = realTime2RecCondData(obj,nSteps,freq,nowcast,vintages)
% Syntax:
%
% out = realTime2RecCondData(obj,nSteps,freq,nowcast,vintages)
%
% Description:
%
% Takes real time data and converts it into recursive conditional data,
% with the number of steps of forecast that you want. 
% 
% Input:
% 
% - obj      : A nb_ts object.
%
% - nSteps   : The number of steps that you want to include in your
%              recursive dataset.  
%
% - freq     : The frequency of your data. Must be either 1, 2, 4, 12 or
%              365.
%
% - nowcast  : Either 0 or 1. If true you will include todays estimate as 
%              your first forecast. Default is true. 
% 
% - vintages : Give false if the dataNames property do not store the
%              vintage dates as is the case for data returned by 
%              nb_fetchRealTimeFromFame. Be aware that this assumes that
%              each new page only give one and only one new observation.
%
%              Give 2 if the dataNames property store the end date of
%              history for each vintage (instead of a vintage). This is 
%              the case if the nb_fetchRealTime is used.
%
% Output:
% 
% - out   : A nb_data object 
%
% See also:
% nb_fetchRealTime, nb_fetchRealTimeFromFame
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        vintages = true;
        if nargin < 4
            nowcast = true;
        end
    end
    
    vintages       = double(vintages);
    isupdateable   = obj.isUpdateable();
    obj.updateable = 0;
    nVar           = length(obj.variables);
    if vintages > 0
    
        dataNamEst = obj.dataNames;
        if vintages == 1 % nb_fetchRealTimeFromFame
            dates = nb_date.vintage2Date(dataNamEst,freq);
        else % nb_fetchRealTime
            dates = nb_date.cell2Date(dataNamEst,freq);
        end
        allDates    = dates(1):dates(end);
        allDatesObj = transpose(nb_date.cell2Date(allDates,freq));
        rec         = zeros(nSteps,nVar,length(allDates));
        nHistory    = length(allDates);
        locDates    = ismember(allDatesObj,dates);
        ii          = 1;
        s           = 1;  
        for jj = 1:nHistory

            if locDates(jj) == 1
                start       = dates(ii) + double(~nowcast);
                finish      = dates(ii) + nSteps - 1 + double(~nowcast);
                rec(:,:,jj) = double(obj.window(start,finish,{},ii));
                ii          = ii + 1;
                s           = jj;
            else
                jump        = jj - s;
                start       = dates(ii) + jump + double(~nowcast);
                finish      = dates(ii) + jump + nSteps - 1 + double(~nowcast);
                rec(:,:,jj) = double(obj.window(start,finish,{},ii-1));
            end

        end
        dNames = toString(allDatesObj + 1); % Start of conditional information
        
    else
        
        mSteps = nSteps - 1;
        rec    = zeros(nSteps,nVar,obj.numberOfDatasets);
        dNames = cell(1,obj.numberOfDatasets);
        for jj = 1:obj.numberOfDatasets
            objT        = window(obj,'','',{},jj);
            endDate     = getRealEndDate(objT,'nb_date');
            dNames{jj}  = toString(endDate);
            rec(:,:,jj) = double(obj.window(endDate-mSteps,endDate,{},jj));
        end
        
    end
    
    out                = nb_data(rec,'',1,obj.variables,obj.sorted);
    out.localVariables = obj.localVariables;
    out.dataNames      = dNames;
    obj.updateable     = isupdateable;
    if obj.isUpdateable()        
        obj   = obj.addOperation(@realTime2RecCondData,{nSteps,freq,nowcast,vintages});
        links = obj.links;
        out   = out.setLinks(links);
    end
    
end
