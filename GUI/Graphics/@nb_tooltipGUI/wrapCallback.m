function wrapCallback(gui,~,~)
% Syntax:
%
% wrapCallback(obj,~,~)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nb_getUIControlValue(gui.tooltipWrapping,'logical')
        string = '*) Use // to force line break.';
    else
        string = '';
    end
    set(gui.wrapInfo,'string',string);

end
