function h = nb_fileToWrite(name,gui)
% Syntax:
%
% h = nb_fileToWrite(name)
%
% Description:
%
% Get handle to a file to communicate with when running in parallel
% 
% Input:
% 
% - name : Name of file to write to. As a string.
% 
% - gui  : Give 'gui' to place the file in the nb_userpath('gui') folder.
%
% Output:
% 
% - h    : A file identifier object. See fopen.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        gui = '';
    end

    p     = nb_userpath(gui);
    fname = [p,'\' name];
    h     = fopen(fname,'a+');

end
