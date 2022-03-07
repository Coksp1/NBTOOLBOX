function [ret,date] = nb_isDate(in)
% Syntax:
%
% [ret,date] = nb_isDate(in)
%
% Description:
%
% Check if any type of input is a date as a one line char or a nb_date
% object.
% 
% Input:
% 
% - in : Any input.
% 
% Output:
% 
% - ret  : true or false
%
% - date : An object of class nb_date.
%
% See also:
% nb_date, nb_date.date2freq
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = true;
    try
        date = nb_date.date2freq(in);
    catch
        date = [];
        ret  = false;
    end
    
end
