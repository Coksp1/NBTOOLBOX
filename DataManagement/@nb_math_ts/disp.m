function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Display object (On the commandline)
% 
% Input:
%
% obj : An object of class nb_math_ts
%
% Output:
%
% The object display on the command line. (When not ending the 
% command with an semicolon)
%
% Examples:
%
% obj
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    dates     = obj.startDate:obj.endDate;
    displayed = cell(obj.dim1,obj.dim2 + 1,obj.dim3);
    for ii = 1:obj.dim3
        displayed(:,:,ii)  = [dates, num2cell(obj.data(:,:,ii))];
    end

    disp(displayed);

end
