function obj = stripFcstFromRealTime(obj,type)
% Syntax:
%
% obj = stripFcstFromRealTime(obj,type)
%
% Description:
%
% Remove conditional information from a real-time dataset
% 
% Caution : It is assumed that each page give rise to a new histroical
%           observation, i.e. the dataNames property must not increase by
%           more than one period when it is traversed.
%
% Input:
% 
% - obj  : An object of class nb_ts. The dataNames property must either
%          store the vintages or the end of history dates.
%
% - type : Give 1 if the dataNames property stores vintages, otherwise use 
%          2 if it stores the end of history dates. Default is 2:
% 
% Output:
% 
% - obj : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 2;
    end

    freq  = obj.frequency;
    dataD = obj.data;
    if type == 1 % nb_fetchRealTimeFromFame
        dates = nb_date.vintage2Date(obj.dataNames,freq);
    else % nb_fetchRealTime
        dates = nb_date.cell2Date(obj.dataNames,freq);
    end
    nHistory = length(dates);
    for jj = 1:nHistory
        start                 = (dates(jj) - obj.startDate) + 2;
        dataD(start:end,:,jj) = nan;
    end
    obj.data = dataD;
    
    if obj.isUpdateable()        
        obj = obj.addOperation(@stripFcstFromRealTime,{type});
    end

end
