function s = getSourceList(obj)
% Syntax:
%
% s = getSourceList(obj)
%
% Description:
%
% Get the source list of the object.
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
%
% - s   : List of sources, as a cellstr. Will return {} if the object is 
%         not updatable.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~obj.updateable 
        s = {};
        return
    end

    % Get the stored links of the object
    links       = obj.links;
    
    % Get the information for the different sources
    nSources = size(links.subLinks,2);
    s        = cell(1,nSources);
    for ii = 1:nSources
       
        subL = links.subLinks(1,ii);
        if ischar(subL.source)
            s{ii} = subL.source;
        elseif iscell(subL.source) && numel(subL.source)
            s{ii} = subL.source{1,1};
        else
            s{ii} = ['private' int2str(ii)]; 
        end
        
    end
    
end
