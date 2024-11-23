function date = nb_dateplus(datein,added)
% Syntax:
%
% date = nb_dateplus(datein,plus)
%
% Description:
% 
% You can specify a date and get the date "plus" period(s) ahead. 
% 
% Input:
% 
% - datein : A date string on one of the following formats
% 
%            > 'yyyyQq', e.g. '2011Q1'.
% 
%            > 'yyyyMm', e.g. '2011M1'.
% 
%            > 'yyyy', e.g. '2011'
%
% - added  : An integer with the number of added months, quarters
%             or years ahead
%
% Output:
%
% date      : A date string at the same date format as the input, 
%             but with the added periods.
%     
% Example of use of function:
%     
% dateString = dateplus('2011Q1',1);      % '2011Q2'
% dateString = dateplus('2011Q1',-1)      % '2010Q4'
% 
% See also: 
% nb_quarter, nb_month, nb_year
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    datein = nb_date.date2freq(datein);
    date   = toString(datein + added);

end
