function cout = union(varargin)
% Syntax:
%
% cout = nb_date.union(varargin)
%
% Description:
%
% Get the union of dates.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    N      = length(varargin);
    start  = cell(1,N);
    finish = cell(1,N);
    for ii = 1:N
        start{ii}  = varargin{ii}{1};
        finish{ii} = varargin{ii}{end};
    end
    start  = nb_date.getEarliestDate(start);
    finish = nb_date.getLatestDate(finish);
    cout   = start:finish;
    cout   = cout';

end
