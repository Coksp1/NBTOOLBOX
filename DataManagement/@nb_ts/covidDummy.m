function obj = covidDummy(obj,covidDummyDates)
% Syntax:
%
% obj = covidDummy(obj)
% obj = covidDummy(obj,covidDummyDates)
%
% Description: 
%
% A dummy for the covid-19 episode. 
% 
% Input:
% 
% - obj             : An object of class nb_ts.           
% 
% - covidDummyDates : A cellstr with the dates of the covid-19 crisis.
%                     Default is the period 16.03.2020 - 31.12.2021. 
%                     Hint: Use nb_month(3,2020):nb_month(12,2021).
%
% Output:
% 
% - obj : An object of class nb_ts.
%
% Examples:
%
%   Generate random data:
%   data  = nb_ts.rand('2018Q1',12,3)
%   data  = covidDummy(data)
%   dataM = nb_ts.rand('2018M1',36,3)
%   dataM = covidDummy(dataM)
%   dataW = nb_ts.rand('2020W1',40,3)
%   dataW = covidDummy(dataW)
%
% See also:
% nb_covidDummyNames, nb_covidDates
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    start  = obj.startDate;
    finish = obj.endDate;
    tSpan  = start:finish;
    freq   = obj.frequency;
    
    % The covid dates
    if nargin < 2
        [covidDummyDates,drop] = nb_covidDates(freq);
        covidDummyDates        = toString(covidDummyDates);
    else
        drop = 0;
        if isa(covidDummyDates,'nb_date')
            if covidDummyDates(1).frequency ~= obj.frequency
                error('The covidDummyDates input is on the wrong frequency.')
            end
            covidDummyDates = toString(covidDummyDates);
        elseif ~iscellstr(covidDummyDates)
            error('The covidDummyDates input must be a cellstr if provided.')
        end
    end
    
    % Find locations of dummies
    nDummies = length(covidDummyDates);
    dummies  = zeros(obj.numberOfObservations,nDummies);
    for ii = 1:nDummies - drop
        ind           = strcmp(covidDummyDates{ii},tSpan);
        dummies(:,ii) = double(ind);
    end
    dummies = dummies(:,:,ones(1,obj.numberOfDatasets));
    
    % Secure that dummy stops at the same time as the latest of the other
    % series 
    isNaN = all(isnan(obj.data),2);
    for ii = 1:obj.numberOfDatasets
        last = find(~isNaN(:,:,ii),1,'last');
        if ~isempty(last)
            dummies(last+1:end,:,ii) = nan;
        end
    end
    
    % Add to variables and data
    obj.variables = [obj.variables, nb_appendIndexes('covidDummy',1:nDummies)'];
    obj.data      = [obj.data, dummies];

    % Sort if needed
    if obj.sorted
         [obj.variables,ind] = sort(obj.variables);
         obj.data            = obj.data(:,ind,:);
    end
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@covidDummy,{covidDummyDates});
        
    end
    
end
