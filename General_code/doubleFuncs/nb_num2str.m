function s = nb_num2str(d,precision)
% Syntax:
%
% s = nb_num2str(d,precision)
%
% Description:
%
% Convert a scalar double to string. If precision is a string this function
% do the same as the num2str function by MATLAB, if on the other hand it is
% a integer it does not collapse big numbers to e^(something). E.g. 
%
% num2str(6000.354,2) = 6e+03
% nb_num2str(6000.354,2) = 6000.35
% 
% Input:
% 
% - d         : Scalar double. 
% 
% - precision : A char (see num2str) or an integer with the number of
%               decimals to include.
%
% Output:
% 
% - s : A char
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isnumeric(d)
        error([mfilename ':: d must be a scalar double'])
    end
    
    if nargin<2
        precision = [];
    end
    if isempty(precision)
        s = num2str(d);
        return
    end

    if ischar(precision)
        s = num2str(d,precision);
    else
        precisionT = ['%.' int2str(precision) 'f '];
        s          = num2str(d,precisionT);
        if ~isscalar(s)
            s = cellstr(s);
            s = regexprep(s,'[.]*0+$',''); 
            s = char(s);
        end
    end

end
