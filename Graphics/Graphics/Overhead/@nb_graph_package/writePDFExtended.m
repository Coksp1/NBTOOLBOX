function writePDFExtended(obj,saveName,language,gui)
% Syntax:
% 
% writePDFExtended(obj,saveName,language,gui)
% 
% Description:
% 
% Save the graph package to a pdf file with more information on the graphs.
% 
% Input:
% 
% - obj           : An object of class nb_graph_package
% 
% - saveName      : The name of the pdf file as a string. If empty no file
%                   is made.
% 
% - language      : The language as a string, 'english' or 
%                   {'norsk'}
%     
% - gui           : true or false
%
% Examples:
%
% obj.writePDFExtended('test', 'english');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<4
        gui = 0;
        if nargin<3
            language = '';
        end
    end
    
    template = nb_graph_package.getExtendedTemplate();
    obj      = assignTemplate(obj,template);
    writePDF(obj,saveName,language,gui,'extended');

end
