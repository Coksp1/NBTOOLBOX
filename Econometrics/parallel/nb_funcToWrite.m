function w = nb_funcToWrite(name,gui)
% Syntax:
%
% w = nb_funcToWrite(name,gui)
%
% Description:
%
% Get handle to a function that can communicate with a file when running 
% in parallel. See 
% 
% Input:
% 
% - name : Name of file to write to. As a string.
% 
% - gui  : Give 'gui' to place the file in the nb_userpath('gui') folder.
%
% Output:
% 
% - w    : A WorkerObjWrapper object.
%
% Example:
%
%          w = nb_funcToWrite('test','gui'); 
%          parfor ii = 1:10
%              fprintf(w.Value,'Some text');
%          end
%          clear w;
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        gui = '';
    end

    p = nb_userpath(gui);
    if exist(p,'dir') ~= 7
        mkdir(nb_userpath(gui));
    end
    h = @() fopen([p,'\',name,sprintf('_%d.txt',labindex)],'wt');
    w = WorkerObjWrapper(h,{},@fclose);
    
end
