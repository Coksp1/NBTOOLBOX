function actual = getActualLowFreq(obj,variable,freq,release,dates,nSteps)
% Syntax:
%
% actual = getActualLowFreq(obj,variable,freq,release,dates,nSteps)
%
% Description:
%
% Get the actual data of a low frequency variable to for example 
% compare forecast to.
% 
% Input:
% 
% - obj     : An object of class nb_mfvar
%
% - variable : The variable to get the actual data on.
%
% - freq    : The low frequency to fetch.
%
% - release : The releaseto return, empty or 0 will return the final 
%             (default). 
% 
% - dates   : A 1 x nDates cellstr array with the dates for where to split  
%             the history. 
%
% - nSteps  : The number of steps of each split. Default is 1.
%
% Output:
% 
% - actual  : A nb_ts object with the wanted release, or if nargin > 3
%             a nb_data object with size nSteps x nVars x nDates.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: The obj input must be a scalar nb_mfvar object.'])
    end

    actual = window(obj.options.data,'','',variable);
    actual = convert(actual,freq);
    if actual.numberOfDatasets > 1
        % We have real time data
        if isempty(release) || release == 0
            actual = actual(:,:,end);
        else
            if isRealTime(actual)
                actual = release(actual,release);
            else
                actual = getRelease(actual,release);
            end
        end
    end
    
    if nargin > 4
        if nargin < 6
            nSteps = 1;
        end
        nDates   = length(dates);
        splitted = nan(nSteps,1,nDates);
        for ii = 1:nDates
            date   = nb_date.toDate(dates{ii},actual.frequency);
            start  = date - actual.startDate + 1;
            finish = start + nSteps - 1;
            if start < 1
                if finish > 0
                    start  = 1;
                else
                    continue
                end 
            elseif finish > actual.numberOfObservations
                finish = actual.numberOfObservations;
                if start > actual.numberOfObservations
                    continue
                end
            end
            nStepsThis                  = finish - start + 1;
            splitted(1:nStepsThis,:,ii) = actual.data(start:finish,:);
            
        end
        actual = nb_data(splitted,'',1,actual.variables);
        
    end

end
