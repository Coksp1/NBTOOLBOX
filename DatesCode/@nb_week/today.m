function obj = today(dayOfWeek)
% Syntax:
%
% obj = nb_week.today()
% obj = nb_week.today(dayOfWeek)
%
% Description:
%
% Get the current week as a nb_week object. 
%
% Input:
%
% - dayOfWeek : The weekday the given week represents when 
%               converted to a day. (1-7 (Monday-Sunday)). Default
%               is 7 (Sunday).
%
% Output:
% 
% obj : An object of class nb_week.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        dayOfWeek = [];
    end

    c   = clock;
    y   = str2double(sprintf('%.0f',c(1)));
    m   = sprintf('%.0f',c(2)+100);
    m   = str2double(m(2:3));
    d   = sprintf('%.0f',c(3)+100);
    d   = str2double(d(2:3));
    d   = nb_day(d,m,y);
    obj = d.getWeek(dayOfWeek);
    
end

