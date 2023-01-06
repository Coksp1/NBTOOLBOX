function out = nb_stateDates(startYear,endYear,d,freq,laglead)
% Syntax:
%
% out = nb_stateDates(startYear,endYear,d,freq)
%
% Description: 
%
% A function to find the release date of variables, given that there is a
% general rule (day number) which the variable is released. The function
% controls for Norwegian holidays. If the release date (given by the rule)
% is on a holiday and/or weekend, it will return the day which is closest.
% 
% Input:
%
% - startYear : As an nb_date object or as a string.
%
% - endYear   : As an nb_date object or as a string.
%
% - d         : The day number where the state variable is published. As a
%               double. 
%
% - freq      : The frequency of the observations you want. Either 4 or 12.
%               As a double.
%
% - laglead   : (Optional) Sets the lag/lead interval of the test.
% 
% Output:
% 
% - out       : A numPeriods*1 nb_day object. 
%
% Examples:
%
%  out = nb_stateDates('2010','2018',10,12)
%
%  out = nb_stateDates('2010','2018',10,4)
%
%  out = nb_stateDates(nb_year('2010'),nb_day('2018M1D10'),10,4)
%
% See also:
% nb_easter
%
% Written by Tobias Ingebrigtsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        laglead = 10;
        
    end
    if isa(startYear,'nb_date') && ~isa(startYear,'nb_year')
        startYear = startYear.getYear;
        startYear = startYear.toString;
    elseif isa(startYear,'nb_year')
        startYear = startYear.toString;
    elseif ~nb_isOneLineChar(startYear)
        error([mfilename ':: Wrong input format. The start date'...
              ' must be either a nb_date object or a string. '])
          
    end
    if isa(endYear,'nb_date') && ~isa(endYear,'nb_year')
        endYear = endYear.getYear;
        endYear = endYear.toString;
    elseif isa(endYear,'nb_year')
        endYear = endYear.toString;
    elseif ~nb_isOneLineChar(endYear)
        error([mfilename ':: Wrong input format. The end date'...
              ' must be either a nb_date object or a string. '])
          
    end
       
    startDate = nb_month([startYear,'M1']);
    endDate   = nb_month([endYear,'M12']);
    Start     = nb_year(startYear);
    End       = nb_year(endYear);
    t         = (endDate-startDate) + 1;
    dates     = startDate:endDate;
    easterD   = nb_easter( str2double(Start.toString):str2double(End.toString) );
    periods                = (End - Start) + 1; 
    easterDates(1,periods) = nb_day();
    for ii = 1:periods
        easterDates(ii) = nb_day(easterD{ii}); 
        
    end
    easter1   = easterDates - 3;   % Skjærtorsdag
    easter2   = easterDates - 2;   % Langfredag
    easter3   = easterDates + 1;   % Andre påskedag
    kristiHim = easterDates + 39;  % Kristi Himmelfartsdag
    pinse1    = easterDates + 50;  % Første pinsedag
    pinse2    = pinse1 + 1;        % Andre pinsedag
    holidays  = [kristiHim, pinse1, pinse2, easter1, easter2, easter3];
    dDates(1,length(dates)) = nb_day();
    augm                    = laglead*2+1;
    vecD(augm,1)            = nb_day();
    datesOut(augm,1)        = nb_day();
    for ii = 1:t    
       dDates(ii)         = nb_day([dates{ii},'D1']) + (d - 1);
       vecD(:,1)          = vec(dDates(ii)-laglead,dDates(ii)+laglead); 
       logVec             = sum(vecD.weekday' == [7,1],2);   % Weekends
       dLog               = ismember(vecD,holidays);         % Holidays
       logVec             = logVec+dLog;
       logVec(logVec > 1) = 1;
       [ ~, index]        = min(abs(find(~logVec)-laglead-1));
       indD               = find(~logVec);
       datesOut(ii)       = vecD(indD(index));
       
    end
    switch freq 
        case 4
            out = datesOut(4:3:end);
        case 12
            out = datesOut;
            
    end

end
