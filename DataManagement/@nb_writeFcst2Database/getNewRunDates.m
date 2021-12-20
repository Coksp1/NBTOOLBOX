function newRunDates = getNewRunDates(obj,fetchedRunDates,format)
% Syntax:
%
% newRunDates = getNewRunDates(obj,fetchedRunDates,format)
%
% Description:
%
% Get the new run dates not saved to the database.
% 
% Input:
% 
% - obj             : An object of class nb_writeFcst2Database.
%
% - fetchedRunDates : The run dates implied by the data source.
% 
% - format          : > 'vintage' : 'yyyymmdd', 'yyyymmddhhnn' or 
%                                   'yyyymmddhhnnss'
%                     > 'default' : 'yyyy-mm-dd', 'yyyy-mm-dd hh:nn' or 
%                                   'yyyy-mm-dd hh:nn:ss'
%
% Output:
% 
% - newRunDates     : The new run dates to update the model at.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        format = 'vintage';
    end

    switch size(fetchedRunDates{1},2) 
        case 8
            freq = 'daily';
        case 12
            freq = 'minutly';
        case 14
            freq = 'secondly';
    end
    
    runDatesDone = getRunDatesAsString(obj,format,freq);
    ind2Run      = ~ismember(fetchedRunDates, runDatesDone);
    newRunDates  = fetchedRunDates(ind2Run);

end
