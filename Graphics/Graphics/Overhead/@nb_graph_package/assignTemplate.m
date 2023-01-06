function obj = assignTemplate(obj,template)
% Syntax:
%
% obj = assignTemplate(obj,template)
%
% Description:
%
% Assign the extended template to the pacakge.
%
% See also:
% nb_graph_package.writeSeparateExtended, nb_graph_package.writePDFExtended
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj = copy(obj); % We copy the object to prevent these settings to be permanent!
    for ii = 1:length(obj.graphs)
        for jj = 1:length(obj.graphs{ii}.plotter)
            templateThis = template;
            if not(jj == 1 && length(obj.graphs{ii}.plotter) > 1)
                obj.graphs{ii}.plotter(jj).tooltipEng = obj.graphs{ii}.tooltipEng;
                obj.graphs{ii}.plotter(jj).tooltipNor = obj.graphs{ii}.tooltipNor;
            end
            obj.graphs{ii}.plotter(jj).template   = struct('extended',templateThis);  
        end
    end

end
