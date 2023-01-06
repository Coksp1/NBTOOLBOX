function bool = nb_isLogical(x)
% Syntax:
%
% ret = nb_isLogical(x)
%
% Description:
%
% Test if x is a logical scalar. MATLAB <true> and <false> will both 
% return true. As will 0 or 1 even if given as a double.
% 
% Input:
% 
% - x    : Any type
% 
% Output:
% 
% - bool : true or false.
%
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    try % If we encounter an error, its definitely not logical..!
        bool = true;
        if ~isscalar(x)
            bool = false;
        else
            if ~islogical(x) && ~ismember(x,[0,1])
                bool = false;
            end
        end
    catch
        bool = false;
    end

end
