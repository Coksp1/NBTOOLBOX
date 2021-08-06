function path = nb_folder()
% Syntax:
%
% path = nb_folder()
%
% Description:
%
% Get the current path of NB toolbox.
% 
% Output:
% 
% - path : A one line char with the current path of NB toolbox.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    path = mfilename('fullpath');
    path = fileparts(path);

end
