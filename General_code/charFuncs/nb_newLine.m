function nl = nb_newLine(num)
% Syntax:
%
% nl = nb_newLine
% nl = nb_newLine(num)
%
% Description:
%
% Returns the new line character, same as char(10). Same as newline, but 
% added to be robust to different versions of MATLAB. The num input is
% also added compared to newline.
% 
% Input:
%
% - num : The number of new line characters to make. Default is 1.
%
% Output:
% 
% - nl  : A one line char with the new line characters.
% 
% See also:
% newline
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nl = char(10); %#ok<CHARTEN>    
    if nargin > 0
        if ~nb_isScalarInteger(num)
            error([mfilename ':: The num input must be an integer greater than 0.'])
        end
        if num < 1
            error([mfilename ':: The num input must be an integer greater than 0.'])
        end
        nl = nl(:,ones(1,num));
    end

end
