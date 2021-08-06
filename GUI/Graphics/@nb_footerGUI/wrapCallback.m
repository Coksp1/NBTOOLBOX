function wrapCallback(gui,~,~)
% Syntax:
%
% wrapCallback(obj,~,~)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nb_getUIControlValue(gui.footerWrapping,'logical')
        string = '*) Use // to force line break.';
    else
        string = '';
    end
    set(gui.wrapInfo,'string',string);

end
