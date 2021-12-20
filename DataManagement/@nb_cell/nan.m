function obj = nan(rows,columns,pages)
% Syntax:
%
% obj = nb_cell.nan(rows,columns)
% obj = nb_cell.nan(rows,columns,pages)
%
% Description:
%
% Create an nb_cell object with all elements set to nan.
% 
% Input:
% 
% - rows  : Number of rows of the nb_cell object.
% 
% - vars  : Number of columns of the nb_cell object.
%
% - pages : Number of pages of the nb_cell object.
%
% Output:
% 
% - obj   : An nb_cell object. 
%
% See also:
% nb_cell
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        pages = 1;
        if nargin < 2
            columns = 1;
            if nargin < 1
                rows = 1;
            end
        end
    end
    
    % Create nb_cell object with nan
    obj = nb_cell(num2cell(nan(rows,columns,pages)),'');

end
