function cout = intersect(varargin)
% Syntax:
%
% cout = nb_date.intersect(varargin)
%
% Description:
%
% Get the intersection of dates.
% 
% Input:
% 
% - varargin : Each input must be a cellstr of dates.
% 
% Output:
% 
% - cout     : A cellstr of dates.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    N      = length(varargin);
    start  = cell(1,N);
    finish = cell(1,N);
    for ii = 1:N
        start{ii}  = varargin{ii}{1};
        finish{ii} = varargin{ii}{end};
    end
    start  = nb_date.getLatestDate(start);
    finish = nb_date.getEarliestDate(finish);
    cout   = start:finish;
    cout   = cout';

end
