function sourceType = getSource(obj,type)
% Syntax:
%
% sourceType = getSource(obj)
% sourceType = getSource(obj,type)
%
% Description:
%
% Get source type.
% 
% Input:
% 
% - obj        : An object of class nb_dataSource.
%
% - type       : Give 'program' to get the general source. Default is to 
%                give the spesific type of source.
% 
% Output:
% 
% - sourceType : A one line char with the source.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nb_isempty(obj.links)
        sourceType = 'data';
        return
    end
    
    if nargin < 2
        type = '';
    end

    subLinks = obj.links.subLinks;
    if numel(subLinks) > 1
        sourceTypes = {subLinks.sourceType};
        sourceTypes = unique(sourceTypes);
        if length(sourceTypes) > 1 
            sourceType = 'combined';
            return
        else
            sourceType = sourceTypes{1};
        end
    else
        sourceType = subLinks.sourceType;
    end
    
    if strcmpi(type,'program')
        
        switch lower(sourceType)
            case {'db','realdb','releasedb','nbrealdb','nbreleasedb'}
                sourceType = 'fame';
            case {'mat'}
                sourceType = 'mat';
            case {'xls','xlsmp'}
                sourceType = 'xls';
        end
        
    end
              
end
