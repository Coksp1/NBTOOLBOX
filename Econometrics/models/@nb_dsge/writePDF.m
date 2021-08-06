function writePDF(obj,filename,type)
% Syntax:
% 
% writePDF(obj,filename)
% writePDF(obj,filename,type)
% 
% Description:
% 
% Write the equations of the model to PDF.
% 
% Input:
% 
% - obj      : An object of class nb_dsge.
% 
% - filename : The filename of the saved pdf file. As a one line char.
%              Extension is ignored.
% 
% - type     : Either 'names' or 'values'. Default is 'names'. If 'values'
%              is given the parameters will be substituted with their
%              values instead of their name.
%
% Examples:
% 
% obj.writePDF('test')
%
% See also:
% nb_dsge.writeTex, nb_model_generic.assignTexNames
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'names';
    end

    % Make it robust to the case where the extension is given.
    [path,filename] = fileparts(filename);
    if ~isempty(path)
        filename = [path,filesep,filename];
    end
    
    % Write tex file
    writeTex(obj,filename,type);

    % Write to pdf
    dos(['pdflatex ' filename '.tex ' filename '.pdf']);
    dos(['pdflatex ' filename '.tex ' filename '.pdf']);

    % Delete .tex file and other temporary files
    dos(['del ' filename '.tex']);
    dos(['del ' filename '.aux']);
    dos(['del ' filename '.log']);
    dos(['del ' filename '.nav']);
    dos(['del ' filename '.out']);
    dos(['del ' filename '.snm']);
    dos(['del ' filename '.toc']);
    dos(['del ' filename '.bbl']);
    
end
