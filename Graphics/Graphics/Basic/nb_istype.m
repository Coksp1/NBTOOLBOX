function ret = nb_istype(in,log)
% Syntax:
%
% ret = nb_istype(in)
%
% Description:
%
% Test if an input is a valid type property.
% 
% Input:
% 
% - in : Any input
% 
% Output:
% 
% - ret : true if in is a valid type property.
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if nargin == 1
        log = 0;
    end
    ret   = false;
    types = {'line','grouped','stacked','area'};
    
    if nb_isOneLineChar(in)
         ret = any(strcmpi(types,value));
    elseif iscellstr(in)
        if ~log
            error([mfilename ':: To allow for cellstring as input, '...
                'log must be set to true.'])
        end
        retT = zeros(length(in),1);
        for ii = 1:length(in)
            retT(ii) = any(strcmpi(types,in(ii)));
        end
        if all(retT)
            ret=true;
        end
    else
        ret = any(strcmpi(types,value));
    end
           
end
