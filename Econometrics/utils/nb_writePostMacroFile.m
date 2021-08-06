function nb_writePostMacroFile(parsedFile,filename)
% Syntax:
%
% nb_writePostMacroFile(parsedFile,filename)
%
% Description:
%
% Write post macro processor model file to a file with extension nbm file.
% 
% Input:
% 
% - parsedFile : The parsed model as a N x 3 cell.
% 
% - filename   : File to write the model file to. Extension will be
%                automatically set to .nbm.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [path,name] = fileparts(filename);
    filename    = fullfile(path,[name '.nbm']);
    nb_cellstr2file(parsedFile(:,1),filename,true);

end
