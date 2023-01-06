function obj = rand(rows,columns,pages,dist)
% Syntax:
%
% obj = nb_cell.rand(rows,columns)
% obj = nb_cell.rand(rows,columns,pages)
% obj = nb_cell.rand(rows,columns,pages,dist)
%
% Description:
%
% Create a random nb_cell object
% 
% Input:
% 
% - rows  : Number of rows of the nb_cell object.
% 
% - vars  : Number of columns of the nb_cell object.
%
% - pages : Number of pages of the random nb_cell object.
%
% - dist  : A nb_distribution object to draw from.
%
% Output:
% 
% - obj   : An nb_cell object. 
%
% Examples:
%
% obj = nb_cell.rand(2,2);
% obj = nb_cell.rand(2,2,10,nb_distribution('type','normal'));
%
% See also:
% nb_cell
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        dist = nb_distribution('type', 'uniform');
        if nargin < 3
            pages = 1;
            if nargin < 2
                columns = 1;
                if nargin < 1
                    rows = 1;
                end
            end
        end
    end
    
    % Generate random data
    data = dist.random(rows, columns*pages);
    data = reshape(data, rows, columns, pages);
    
    % Return random nb_cell object
    obj = nb_cell(num2cell(data),'');

end
