function obj = reIndex(obj,date)
% Syntax:
%
% obj = reIndex(obj,date)
%
% Description:
% 
% Reindex the data of the object to a new date. It is also possible 
% to reindex the timeseries to a date with lower frequency. E.g.
% reindex quarterly data to be on average 100 in a given year.
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% - date      : The date at which the data should be reindexed to. 
%               (Reindexed to 100)
%               
% Output:
% 
% - obj       : An object of class nb_math_ts where all the objects
%               timeseries are reindexed to 100 at the given date
% 
% Examples:
% 
% obj = reIndex(obj,'2012Q2')
%
% Written by Kenneth S. Paulsen     

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
            switch obj.startDate.frequency 
                case 2
                    date  = date.getHalfYear();
                    extra = 1;
                case 4
                    date = date.getQuarter();
                    extra = 3;
                case 12
                    date = date.getMonth();
                    extra = 11;
                case 365
                    date = date.getDay();
                    if date.leapYear
                        extra = 365;
                    else
                        extra = 364;
                    end
            end

            period          = date - obj.startDate + 1;
            indexPeriods    = period:period + extra;
            try
                indexPeriodData = nanmean(obj.data(indexPeriods,:,:),1);
            catch 
                error('nb_math_ts:reIndex:outsideBounds',[mfilename ':: You cannot index to date which is not part of the objects window!'])
            end
            factor          = 100./indexPeriodData;
            obj.data        = obj.data.*repmat(factor,obj.dim1,1);

        end

    else

        indexPeriod     = date - obj.startDate + 1;
        try
           indexPeriodData = obj.data(indexPeriod,:,:);
        catch %#ok<CTCH>
            error('nb_math_ts:reIndex:outsideBounds',[mfilename ':: You cannot index to date which is not part of the objects window!'])
        end
        factor          = 100./indexPeriodData;
        obj.data        = obj.data.*repmat(factor,obj.dim1,1);

    end

end
