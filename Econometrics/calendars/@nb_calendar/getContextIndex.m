function [indC,locC] = getContextIndex(forecastContexts,contexts)
% Syntax:
%
% [indC,locC] = nb_calendar.getContextIndex(forecastContexts,calendar)
%
% Description:
%
% Get index of the contexts that match a set of calendar dates.
% 
% Input:
% 
% - forecastContexts : A N x 1 or 1 x N double with the contexts.
%
% - contexts         : A 1 x M or M x 1 double with the calendar dates.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(contexts)
        indC = [];
        locC = true(1,0);
        return
    end
    
    % Make robust to different frequencies on context dates
    forecastContextsStr1 = num2str(forecastContexts(1));
    contextsStr1         = num2str(contexts(1));
    diffLength           = size(forecastContextsStr1,2) - size(contextsStr1,2);
    if diffLength > 0
        contextsStr = num2str(contexts);
        if diffLength == 6
            contextsStr = strcat(contextsStr,'235959');
        elseif diffLength == 4
            contextsStr = strcat(contextsStr,'2359');
        else
           error(['The date format ' contextsStr1 ' is not supported']) 
        end
        contexts    = str2num(contextsStr); %#ok<ST2NM>
    elseif diffLength < 0
        forecastContextsStr = num2str(forecastContexts);
        forecastContextsStr = strcat(forecastContextsStr,repmat('0',[1,-diffLength]));
        forecastContexts    = str2num(forecastContextsStr); %#ok<ST2NM>
    end
        
    % Return matching indexes
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
