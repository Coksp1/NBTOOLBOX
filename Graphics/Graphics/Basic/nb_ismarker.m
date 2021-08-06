function ret = nb_ismarker(in,log)
% Syntax:
%
% ret = nb_ismarker(in)
%
% Description:
%
% Test if an input is a valid marker property.
% 
% Input:
% 
% - in  : Any input.
% 
% - log :  True if we allow for cellstr.
%
% Output:
% 
% - ret : true if in is a valid marker property.
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if nargin == 1
        log = 0;
    end
    ret = false;
    mrk = {'o','x','+','*','s','d','.','^','<','>','v','p','h', ...
           'none','square','diamond','pentagram','hexagram'};
    if nb_isOneLineChar(in)
        if any(strcmpi(mrk,in))
            ret = true;
        end
    elseif iscellstr(in)
       if ~log
           error([mfilename ':: To allow for cellstr as input, log must'...
                            ' be set to true.'])
       end
       if all(ismember(lower(in),mrk))
           ret = true;
       end
    end
end
