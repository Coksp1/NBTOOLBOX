function writePDF(obj,filename)
% Syntax:
% 
% writePDF(obj,filename)
% 
% Description:
% 
% Write the equations to PDF
% 
% Input:
% 
% - obj      : An object of class nb_eq2Latex.
% 
% - filename : The filename of the saved pdf file. As a one line char.
%              Extension is ignored.
% 
% Examples:
% 
% obj.writePDF('test')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Make it robust to the case where the extension is given.
    [path,filename] = fileparts(filename);
    if ~isempty(path)
        filename = [path,filesep,filename];
    end
    
    % Write tex file
    writeTex(obj,filename);

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
