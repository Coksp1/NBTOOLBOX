function runDates = getRunDatesAsString(obj,format,freq)
% Syntax:
%
% runDates = getRunDatesAsString(obj)
% runDates = getRunDatesAsString(obj,format,freq)
%
% Description:
%
% Get the run dates as cellstr of the model.
% 
% Input:
% 
% - obj      : An object of class nb_SMARTModel.
% 
% - format   : > 'vintage' : 'yyyymmddhhnnss'
%              > 'default' : 'yyyy-mm-dd hh:nn:ss'
%
% - freq     : 'daily' or 'secondly' (default).
%
% Output:
% 
% - runDates : A cellstr array with the run dates.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen    

    if nargin < 3
        freq = 'secondly';
        if nargin < 2
            format = 'default';
        end
    end

    runDates = obj.runDates;
    if ~isempty(runDates)
        if strcmpi(format,'vintage')
            if size(runDates{1},2) == 8
                if strcmpi(freq,'secondly')
                    runDates = strcat(runDates,'000000');
                end
            else
                runDates = char(runDates);
                runDates = runDates(:,1:8);
                runDates = cellstr(runDates)';
            end
        else
            if size(runDates{1},2) == 8 && strcmpi(freq,'secondly')
                runDates = strcat(runDates,'000000');
            end
            runDates = char(runDates);
            if strcmpi(freq,'secondly')
                years    = cellstr(runDates(:,1:4));
                months   = cellstr(runDates(:,5:6));
                days     = cellstr(runDates(:,7:8));
                hours    = cellstr(runDates(:,9:10));
                minutes  = cellstr(runDates(:,11:12));
                seconds  = cellstr(runDates(:,13:14));
                runDates = strcat(years,'-',months,'-',days,{' '},hours,':',minutes,':',seconds)';
            else
                years   = cellstr(runDates(:,1:4));
                months  = cellstr(runDates(:,5:6));
                days    = cellstr(runDates(:,7:8));
                runDates = strcat(years,'-',months,'-',days)';
            end

        end
    end

end
