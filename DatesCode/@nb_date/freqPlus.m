function obj = freqPlus(obj,~,~)
% Syntax:
%
% obj = freqPlus(obj,incr,freq)
%
% Description:
%
% Plus the number of periods of another (lower) frequency.
%
% E.g. dayNextYear = freqPlus(day,1,1);
% 
% Input:
% 
% - obj     : An object of class nb_date.
%
% - periods : A scalar integer with the periods to add.
%
% - freq    : The frequency of the periods argument.
% 
% Output:
% 
% - ob      : An object of class nb_date.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    error([mfilename ':: This method is not implemented for the class ' class(obj)]);

end
