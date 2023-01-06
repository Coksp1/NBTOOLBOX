function returned = nb_sameDateFormat(date1,date2)
% Syntax:
%
% returned = nb_sameDateFormat(date1,date2)
% 
% Description
%
% Compares two string, and test if the dates are of the same 
% frequency. Return true if the two dates have the same frequency.
% The following date formats are supported by this function:
%
% - Daily         : 'yyyyMm(m)Dd(dd)'
%
% - Weekly        : 'yyyyW(w)'
%
% - Monthly       : 'yyyyMm(m)'
%
% - Quarterly     : 'yyyyQq'
%
% - Semiannually  : 'yyyySs'
%
% - Yearly        : 'yyyy' 
%
% Input:
%
% - date1    : A string with the date.
%
% - date2    : A string with the date.
%
% Output:
%
% - returned : Logical. 1 if both dates have same frequency, 
%              otherwise 0.
%
% Examples:
%
% returned = nb_sameDateFormat('2013Q4','2012Q1'); % true
%
% See also: 
%
% nb_date.date2freq
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [~,frequency1] = nb_date.date2freq(date1);
    [~,frequency2] = nb_date.date2freq(date2);
    returned       = frequency1 == frequency2;

end
