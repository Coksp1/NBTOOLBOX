function freq = getFreq(stringDate)
% Syntax:
%
% freq = nb_date.getFreq(stringDate)
%
% Description:
%
% Get the frequency of a string date, given that it is on the nb_ts
% date format. 
%       
% Input:
% 
% - stringDate : 
%         
%   Supported date formats:
% 
%   > yearly       : 'yyyy'
%
%   > semiannually : 'yyyySs'
%
%   > quarterly    : 'yyyyQq'
%
%   > monthly      : 'yyyyMm(m)'
%
%   > weekly       : 'yyyyWw(w)'
%
%   > daily        : 'yyyyMmDd(d)'
%         
% Output:
% 
% - freq       :
%
%   > yearly       : 1
%
%   > semiannually : 2
%
%   > quarterly    : 4
%
%   > monthly      : 12
%
%   > weekly       : 52
%
%   > daily        : 365
% 
% Examples:
%
% freq = nb_date.getFreq('2012'); % Will return 1
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    qfound = strfind(stringDate,'Q');
    if ~isempty(qfound)
        freq = 4;
    else
        sfound = strfind(stringDate,'S');
        if ~isempty(sfound)
            freq = 2;
        else
            wfound = strfind(stringDate,'W');
            if ~isempty(wfound)
                freq = 52;
            else
                dfound = strfind(stringDate,'D');
                mfound = strfind(stringDate,'M');
                if isempty(mfound) && isempty(dfound) 
                    freq = 1;
                elseif ~isempty(mfound) && isempty(dfound)
                    freq = 12;
                else
                    freq = 365;
                end
            end
        end
    end

end
