function writeSeparateExtended(obj,folder,language,format,index,gui,includeFigureNumber,skipConfirmation)
% Syntax:
% 
% writeSeparateExtended(obj,folder,language,format,index,gui,...
%   includeFigureNumber)
% 
% Description:
% 
% Save the graph package to files. Each graph will be save with the name of
% the assign identifier. See the nb_graph_package.add for more on the 
% identifiers. Tooltip, excel title and footer will be added to the graph.
% 
% Input:
% 
% - obj      : An object of class nb_graph_package
% 
% - folder   : The folder to save the graphs to.
% 
% - language : The language as a string, 'english' or 
%              {'norsk'}. Will also be appended the save names.
%     
% - format   : The file format to save the graph to. See the nb_saveas
%              function for the supported formats. Default is 'pdf'.
% 
% - index    : Either a 1 x numGraphs logical or empty. Set the matching 
%              element of a graph to false to skip printing the specific
%              graph. Default is empty, i.e. to print all graphs of the 
%              package.
%
% - gui      : true or false
%
% - includeFigureNumber : Include figure number in file names. Default
%                         is false.
%
% - skipConfirmation : Skip the confirmation window and go straight to
%                      writing or not. Default is false.
%
% Examples:
%
% obj.writeSeparate('test', 'english', 'pdf');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    if nargin < 8
        skipConfirmation = false;
        if nargin < 7
            includeFigureNumber = false;
            if nargin < 6
                gui = 0;
                if nargin < 5
                    index = [];
                    if nargin < 4
                        format = 'pdf';
                        if nargin<3
                            language = '';
                        end
                    end
                end
            end
        end
    end
    
    template = nb_graph_package.getExtendedTemplate();
    obj      = assignTemplate(obj,template);
    writeSeparate(obj,folder,language,format,index,gui,'extended',includeFigureNumber,false,skipConfirmation)

end
