function wrapCallback(gui,~,~)
% Syntax:
%
% wrapCallback(obj,~,~)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_getUIControlValue(gui.figureTitleWrapping,'logical')
        string = '*) Use // to force line break.';
    else
        string = '';
    end
    set(gui.wrapInfo,'string',string);

end
