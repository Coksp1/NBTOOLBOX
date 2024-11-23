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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        dayOfWeek = [];
    end

    d   = nb_day.today();
    obj = d.getWeek(dayOfWeek);
    
end

