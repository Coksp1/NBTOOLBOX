function obj = reIndex(obj,date,value)
% Syntax:
%
% obj = reIndex(obj,date)
% obj = reIndex(obj,date,value)
%
% Description:
% 
% Reindex the data of the object to a new date. It is also possible 
% to reindex the timeseries to a date with lower frequency. E.g.
% reindex quarterly data to be on average 100 in a given year.
% 
% Input:
% 
% - obj   : An object of class nb_math_ts
% 
% - date  : The date at which the data should be reindexed to.
%
% - value : The value to re-index the data to. Default is 100    
%               
% Output:
% 
% - obj   : An object of class nb_math_ts where all the timeseries 
%           are reindexed to value at the given date.
% 
% Examples:
% 
% obj = reIndex(obj,'2012Q2')
%
% Written by Kenneth S. Paulsen     

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        value = 100;
    end

    if ischar(date)
        date = nb_date.date2freq(date);
    elseif isa(date,'nb_date')
        % Do nothing
    elseif isnumeric(date)
        date = nb_year(date);
    else 
        error([mfilename ':: the ''startDate'' input must either be a string or an integer.'])
    end

    if date.frequency ~= obj.startDate.frequency

        if date.frequency > obj.startDate.frequency
            error([mfilename ':: It is not possible to re index to a date with higher frequency than the frequency of the object.'])
        else
            % Here we re index to a date with lower frequency 
            % (avarage indexation)
            dateHigh = convert(date,obj.startDate.frequency);
            if obj.startDate.frequency < 52
                extra = obj.startDate.frequency/date.frequency - 1;
            elseif obj.startDate.frequency == 52
                extra = getNumberOfWeeks(date) - 1;
            else 
                extra = getNumberOfDays(date) - 1;
            end
            
            period       = dateHigh - obj.startDate + 1;
            indexPeriods = period:period + extra;
            try
                indexPeriodData = mean(obj.data(indexPeriods,:,:),1,'omitnan');
            catch 
                error('nb_math_ts:reIndex:outsideBounds',[mfilename ':: You cannot index to date which is not part of the objects window!'])
            end
            factor   = value./indexPeriodData;
            obj.data = obj.data.*repmat(factor,obj.dim1,1);

        end

    else

        indexPeriod = date - obj.startDate + 1;
        try
           indexPeriodData = obj.data(indexPeriod,:,:);
        catch %#ok<CTCH>
            error('nb_math_ts:reIndex:outsideBounds',[mfilename ':: You cannot index to date which is not part of the objects window!'])
        end
        factor   = value./indexPeriodData;
        obj.data = obj.data.*repmat(factor,obj.dim1,1);

    end

end
