function ret = nb_islineStyle(in,allowCell)
% Syntax:
%
% ret = nb_islineStyle(in,allowCell)
%
% Description:
%
% Test if an input is a valid lineStyle property.
% 
% Input:
% 
% - in        : Any input
% 
% - allowCell :  True if we allow for cellstring.
%
% Output:
% 
% - ret : true if in is a valid lineStyle property.
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    if nargin == 1
        allowCell = 0;
    end
    ret    = false;
    styles = {'-','--',':','-.','none'};
    if nb_isOneLineChar(in)
        if any(strcmp(styles,in))
            ret = true;
        end
    elseif iscellstr(in)
        if ~allowCell
           error([mfilename ':: To allow for cellstring as input, allowCell must be set to true.'])
        end
        retT = zeros(length(in),1);
        for ii = 1:length(in)
            retT(ii) = any(strcmp(styles,in(ii)));
        end
        if all(retT)
            ret = true;
        end
    end
end
