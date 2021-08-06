function nb_closeWaitbar5()
% Syntax:
%
% nb_closeWaitBar()
%
% Description:
%
% Close wait bar produced by a nb_waibar5 class.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    fig = findobj('type','figure','tag','nb_waitbar5');
    gui = get(fig,'userData');
    if iscell(gui)
        delete(gui{1});
    else
        delete(gui);
    end
    
end
