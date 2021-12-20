function states = getStatesOfBreakPoint(parser,sDate,eDate)
% Syntax:
%
% states = nb_dsge.getStatesOfBreakPoint(parser,sDate,eDate)
%
% Description:
%
% Get the states vector given a estimation (filtering) period.
% 
% Input:
% 
% - parser : See the nb_dsge.parser property.
% 
% - sDate  : The start date of the estimation (filtering). As a char or a
%            nb_date object.
%
% - eDate  : The end date of the estimation (filtering). As a char or a
%            nb_date object.
% Output:
% 
% - states : A nPeriods vector of the states at each period of the
%            estimation (filtering).
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(sDate,'nb_date')
        sDate = nb_date.date2freq(sDate);
    end
    if ~isa(eDate,'nb_date')
        eDate = nb_date.date2freq(eDate);
    end
    fDates = sDate:eDate;
    dates  = {parser.breakPoints.date};
    dates  = cellfun(@toString,dates,'uniformOutput',false);
    states = ones(length(fDates),1);
    for ii = 1:length(dates)
        ind = find(strcmp(dates{ii},fDates),1);
        if ~isempty(ind)
            states(ind:end) = ii + 1;
        end
    end
    
end
