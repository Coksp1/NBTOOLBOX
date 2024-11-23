function ret = nb_isRGB(in,moreRows)
% Syntax:
%
% ret = nb_isRGB(in)
% ret = nb_isRGB(in,moreRows)
%
% Description:
%
% Test if the input in is a RGB color.
% 
% Input:
% 
% - in       : The value to be evaluated. 
% 
% - moreRows : Give true to also tolerate a N x 3 RGB color matrix for 
%              N > 1. Default is false.
%
% Output:
% 
% - ret      : Logical. Returns true if the input is a RGB color. 
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        moreRows = false;
    end
    
    if ~moreRows
        if size(in,1) > 1
            ret = false;
            return
        end
    end

    ret = false;
    if isnumeric(in)
        if size(in,2) == 3
            inVec = in(:);
            if all(inVec <= 1 & inVec >= 0)
                ret = true;
            end
        end
    end
    
end
