function disp(obj)
% Syntax:
%
% disp(obj)
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    disp(nb_createLinkToClass(obj));
    disp(' ')
    disp(cellstr(obj.symbols));

end
