function preview(gui,~,~,language,extended)
% Syntax:
%
% preview(gui,hObject,event,language,extended)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        extended = false;
    end

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be previewed.')
        return
    end
    
    if extended
        gui.package.previewExtended(language,1);
    else
        gui.package.preview(language,1,gui.template);
    end

end
