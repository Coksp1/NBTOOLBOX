function diff = nb_dateminus(date1,date2)
% Syntax:
%
% diff = nb_dateminus(date1,date2)
% 
% Description:
%
% This function calculates how many quarters or months there is 
% between two dates (given as strings).
% 
% Inputs:
% 
% - date1 : Must be on one of the following date formats: 
%
%           > 'yyyyQq', e.g. '2011Q1'
%
%           > 'yyyyMm(m)', e.g. '2011M1'
%
%           > 'yyyy', e.g. 2011
%
% - date2 : Must be on one of the following date formats: 
%
%           > 'yyyyQq', e.g. '2011Q1'
%
%           > 'yyyyMm(m)', e.g. '2011M1'
%
%           > 'yyyy', e.g. 2011
% 
% Output:
% 
% - diff : Number of quarters/months/years between date1 and date2 
%          (date1 minus date2)
% 
% Examples:
% 
% diff = nb_dateminus('2012Q4','2012Q1');
% diff = nb_dateminus('2012M4','2012M1');
% diff = nb_dateminus('2014','2012');
%
% See also: 
% nb_quarter, nb_month, nb_year
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    date1 = nb_date.date2freq(date1);
    date2 = nb_date.date2freq(date2);
    diff  = date1 - date2;

end



