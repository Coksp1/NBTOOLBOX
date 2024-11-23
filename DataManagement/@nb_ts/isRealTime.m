function ret = isRealTime(obj)
% Syntax:
%
% ret = isRealTime(obj)
%
% Description:
%
% Is the dataset representing linked real-time data?
% 
% Input:
% 
% - obj : An object of class nb_ts.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = false;
    if ~isUpdateable(obj)
        return
    end
    sublinks = obj.links.subLinks;
    if any(strcmpi('realdb',{sublinks.sourceType})) || any(strcmpi('nbrealdb',{sublinks.sourceType})) || any(strcmpi('xlsmp',{sublinks.sourceType}))
        ret = true;
    end

end
