function nb_printResults(res,name)
% Syntax:
%
% nb_printResults(res)
%
% Description:
%
% Print results in a window.
% 
% Input:
% 
% - res : A char
%
% - name : Name of figure window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Print the results in a new window for the user
    f = nb_guiFigure([],name,[50 40 120 30],'normal','on');
  
    nb_scrollbox(...
        'parent',               f,...
        'units',                'normal',...
        'position',             [0 0 1 1],...
        'background',           [1 1 1],...
        'horizontalAlignment',  'left',...
        'fontName',             'courier',...
        'string',               res);

    set(f,'visible','on');
    
end
