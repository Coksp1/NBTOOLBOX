function obj = reIndex(obj,date,baseValue)
% Syntax:
%
% obj = reIndex(obj,date,baseValue)
%
% Description:
% 
% Reindex the data of the object to a new date. It is also possible 
% to reindex the timeseries to a date with lower frequency. E.g.
% reindex quarterly data to be on average 100 in a given year.
% 
% Input:
% 
% - obj       : An object of class nb_ts
% 
% - date      : The date at which the data should be reindexed to. 
%               (Reindexed to baseValue, default is 100)
%               
% - baseValue : A number to re-index the series to. Dafault is 100.
%
% Output:
% 
% - obj       : An object of class nb_ts where all the objects
%               timeseries are reindexed to 100 at the given date
% 
% Examples:
% 
% obj = reIndex(obj,'2012Q2')
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        baseValue = 100;
    end

    dateT = interpretDateInputFlex(obj,date);
    if dateT.frequency ~= obj.startDate.frequency

        if dateT.frequency > obj.startDate.frequency
            error('nb_ts:reIndex:toHighDateFrequency',[mfilename ':: It is not possible to re index to a date with higher frequency than the frequency of the object.'])
        else
            % Here we re index to a date with lower frequency 
            % (average indexation)
            switch obj.startDate.frequency 
                case 2
                    dateT  = dateT.getHalfYear();
                    extra = 1;
                case 4
                    dateT = dateT.getQuarter();
                    extra = 3;
                case 12
                    dateT = dateT.getMonth();
                    extra = 11;
                case 365
                    dateT = dateT.getDay();
                    if dateT.leapYear
                        extra = 365;
                    else
                        extra = 364;
                    end
            end

            period       = dateT - obj.startDate + 1;
            indexPeriods = period:period + extra;
            try
                indexPeriodData = mean(obj.data(indexPeriods,:,:),1);
            catch  %#ok<CTCH>
                error('nb_ts:reIndex:outsideBounds',[mfilename ':: You cannot index to date which is not part of the objects window!'])
            end
            factor   = baseValue./indexPeriodData;
            obj.data = obj.data.*repmat(factor,[obj.numberOfObservations,1,1]);

        end

    else

        indexPeriod = dateT - obj.startDate + 1;
        try
            indexPeriodData = obj.data(indexPeriod,:,:);
        catch %#ok<CTCH>
            error('nb_math_ts:reIndex:outsideBounds',[mfilename ':: You cannot index to date which is not part of the objects window!'])
        end
        factor          = baseValue./indexPeriodData;
        obj.data        = obj.data.*repmat(factor,[obj.numberOfObservations,1,1]);

    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@reIndex,{date,baseValue});
        
    end

end

%==================================================================
function date = interpretDateInputFlex(obj,date)

    if nb_isempty(obj.localVariables)
        date = nb_date.date2freq(date);
    else
        if ischar(date)
            found = strfind(date,'%#');
            if isempty(found)
                date = nb_date.date2freq(date,obj.frequency);
            else
                date = nb_localVariables(obj.localVariables,date);
                date = nb_date.date2freq(date);
            end
        else
            date = nb_date.date2freq(date);
        end
    end
        
end
