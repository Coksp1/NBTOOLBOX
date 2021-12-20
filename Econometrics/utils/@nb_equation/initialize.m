function obj = initialize(rows,cols)
% Syntax:
%
% obj = nb_equation.initialize(rows,cols)
%
% Description:
%
% Initialize vector of nb_equation objects.
% 
% Input:
% 
% - rows : Number of rows. As a scalar integer.
%
% - cols : Number of columns. As a scalar integer.
% 
% Output:
% 
% - obj  : A rows x cols nb_term object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj(rows,cols) = nb_equation();

end
