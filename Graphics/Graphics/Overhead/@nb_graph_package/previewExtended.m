function previewExtended(obj,language,gui)
% Syntax:
% 
% previewExtended(obj,language,gui)
% 
% Description:
% 
% Preview of the graph package.
% 
% Input:
% 
% - obj      : An object of class nb_graph_package
% 
% - language : The language as a string, 'english' or {'norsk'}
%  
% - gui      : true or false
%
% Examples:
%
% obj.previewExtended('english');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<3
        gui = 0;
        if nargin < 2
            language = 'norsk';
        end
    end
    writePDFExtended(obj,'',language,gui);

end
