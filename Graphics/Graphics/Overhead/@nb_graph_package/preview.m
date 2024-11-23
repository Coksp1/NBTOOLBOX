function preview(obj,language,gui,template)
% Syntax:
% 
% preview(obj,language,gui,template)
% 
% Description:
% 
% Preview of the graph package.
% 
% Input:
% 
% - obj           : An object of class nb_graph_package
% 
% - language      : The language as a string, 'english' or 
%                   {'norsk'}
%  
% - gui           : true or false
%
% - template      : A one line char with the applied template. Default is
%                   'current', i.e. do specific template.
%
% Examples:
%
% obj.preview('english');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        template = 'current';
        if nargin<3
            gui = 0;
            if nargin < 2
                language = 'norsk';
            end
        end
    end
    writePDF(obj,'',language,gui,template);

end
