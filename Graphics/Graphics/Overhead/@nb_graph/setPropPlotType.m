function setPropPlotType(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropPlotType(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the plotType property of the nb_graph subclasses. This method 
% is used by the set method of nb_graph to set plotType and do 
% additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object that is a subclass of nb_graph
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                   'plotType' for expected behavior). 
%
% - propertyValue : Value to set the plotType property to.
%
% Output:
%
% No actual output, but the input object plotType property will have 
% been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    oldPlotType        = obj.(propertyName);
    obj.(propertyName) = lower(propertyValue);
    
    resetFormatting = false;
    if any(strcmpi(oldPlotType,{'scatter','candle'}))
        if ~strcmpi(propertyValue,oldPlotType)
            resetFormatting = true;
        end
    elseif any(strcmpi(propertyValue,{'scatter','candle'}))
        if ~strcmpi(propertyValue,oldPlotType)
            resetFormatting = true;
        end
    end

    if resetFormatting
        ann = obj.annotation;
        if ~iscell(ann)
            ann = {ann};
        end

        ind = cellfun(@(x)isa(x,'nb_plotLabels'),ann);
        ann = ann(ind);
        for ii = 1:length(ann)
            if isvalid(ann{ii})
                set(ann{ii},...
                    'formatCells',   {},...
                    'formatColumns', {},...
                    'formatRows',    {});
            end
        end
    end     

end
