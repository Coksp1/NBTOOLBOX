function obj = easterDummy(obj,greedy)
% Syntax:
%
% obj = easterDummy(obj,greedy)
%
% Description: 
%
% A seasonal dummy for easter. It utilizes the eastermethod to estimate 
% when easter occurs every year. 
% 
% Input:
% 
% - obj    : An object of class nb_ts.
%
% - greedy : Logical. If true this method will only return a dummy for the 
%            month when Easter Sunday occurs, otherwise it will return
%            a dummy for the months where the easter week occurs (i.e.
%            may overlap different months). Default is true.             
% 
% Output:
% 
% - obj    : An object of class nb_ts.
%
% Examples:
%
%   Generate random data:
%   data  = nb_ts.rand('2012M1',10,3)
%   data1 = easterDummy(data,1)
%   data2 = easterDummy(data,0)
%
% See also:
% easter
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        greedy = true;
    end

    start  = obj.startDate;
    finish = obj.endDate;
    tSpan  = start:finish;
    freq   = obj.frequency;
    
    years  = start.getYear:finish.getYear;
    years  = str2num(char(years)); %#ok<ST2NM>
    
    easterDates = nb_easter(years);
    if greedy
        
        easterDummyDates = cell(size(easterDates,1),1);
        for ii = 1:size(easterDates,1)
            
           % Convert to nb_day
           d = nb_day(easterDates{ii,:});
           
           % Get corresponding period, depends on frequency!
           switch freq
               case 1
                   date = d.getYear;
               case 2
                   date = d.getHalfYear;
               case 4
                   date = d.getQuarter;
               case 12
                   date = d.getMonth;
               case 52
                   date = d.getWeek;
               case 365
                   date = d;
           end
           
           % Store date
           easterDummyDates{ii} = toString(date);
           
        end
        
    else
        
        easterDummyDates = cell(size(easterDates,1),2);
        for ii = 1:size(easterDates,1)
            
           % Convert to nb_day
           d = nb_day(easterDates{ii,:});
           d = d + 1;
           s = d - 9;
           
           % Get corresponding period, depends on frequency!
           switch freq
               case 1
                   date1 = s.getYear;
                   date2 = date1;
               case 2
                   date1 = s.getHalfYear;
                   date2 = date1;
               case 4
                   date1 = s.getQuarter;
                   date2 = d.getQuarter;
               case 12
                   date2 = d.getMonth;
                   date1 = s.getMonth;
               case 52
                   date1 = s.getWeek;
                   date2 = d.getWeek;
               case 365
                   date1 = s;
                   date2 = d;
           end
           
           % Store date
           easterDummyDates{ii,1} = toString(date1);
           easterDummyDates{ii,2} = toString(date2);
           
        end
        easterDummyDates = easterDummyDates(:);
        
    end
    
    % Find locations of dummies
    ind = ismember(tSpan,easterDummyDates);
    ind = double(ind);
    ind = ind(:,:,ones(1,obj.numberOfDatasets));

    % Secure that dummy stops at the same time as the latest of the other
    % series
    isNaN      = all(isnan(obj.data),2);
    ind(isNaN) = nan;
    
    % Add to variables and data
    obj.variables = [obj.variables, 'easterDummy'];
    obj.data      = [obj.data, ind];

    % Sort if needed
    if obj.sorted
         [obj.variables,ind] = sort(obj.variables);
         obj.data            = obj.data(:,ind,:);
    end
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@easterDummy,{greedy});
        
    end
    
end
