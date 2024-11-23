function obj = initialize(rows,cols)
% Syntax:
%
% obj = nb_term.initialize(rows,cols)
%
% Description:
%
% Initialize vector of nb_term objects.
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj(rows,cols) = nb_equation();

end
