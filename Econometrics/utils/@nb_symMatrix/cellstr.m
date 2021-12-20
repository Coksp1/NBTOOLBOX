function c = cellstr(obj)
% Syntax:
%
% c = cellstr(obj)
%
% Description:
%
% Display object (In the command window)
% 
% Input:
%
% - obj : An object of class nb_symMatrix.
%
% Output:
%
% The object displayed on the command line.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    c = cellstr(obj.symbols);

end
