function [indC,locC] = getContextIndex(forecastContexts,contexts)
% Syntax:
%
% [index,isMatch] = nb_calendar.getContextIndex(contexts,calendar)
%
% Description:
%
% Get index of the contexts that match a set of calendar dates.
% 
% Input:
% 
% - contexts : A N x 1 or 1 x N double with the contexts.
%
% - calendar : A 1 x M or M x 1 double with the calendar dates.
% 
% Output:
% 
% - indC    : A 1 x Q index of the contexts that match a set of calendar 
%             dates. Here Q <= M, and is only lower if some of the calendar
%             dates does not match with any contexts.
%
% - locC    : A 1 x M logical. A element is true, if the calendar dates
%             found a matching context.
%
% See also:
% nb_calendar.doOneModel, nb_modelDataSource.update
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(contexts)
        indC = [];
        locC = true(1,0);
        return
    end
    indC = nan(1,size(contexts,1));
    for ii = 1:size(contexts,1)
        ind   = forecastContexts <= contexts(ii);
        found = find(ind,1,'last');
        if ~isempty(found)
            indC(ii) = found;
        end 
    end
    locC = ~isnan(indC);
    indC = indC(locC);

end
