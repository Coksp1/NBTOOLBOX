function lineWidth = nb_scaleLineWidth(obj,lineWidth)
% Syntax:
%
% lineWidth = nb_scaleLineWidth(obj,lineWidth)
%
% Description:
%
% Scale a line width property.
% 
% Input:
% 
% - obj       : An object of class nb_plotHandle
% 
% - lineWidth : The value of a property that represent the width of some 
%               type of line. As a double.
%
% Output:
% 
% - lineWidth : The scaled or non-scaled line width.
%
% See also:
% nb_axes.scaleLineWidth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isprop(obj,'returnNonScaled')
        if obj.returnNonScaled
            return
        end
    end

    % Get parent nb_axes object
    notFound = true;
    parent   = obj.parent;
    while notFound   
        if ishandle(obj.parent)
            return
        elseif isa(parent,'nb_axes')
            notFound = false;
        else
            try
                parent = parent.parent;
            catch %#ok<CTCH>
                return
            end
        end
    end
        
    if parent.scaleLineWidth  
        scale = [];
        if isprop(parent,'scaleFactor')
            scale = parent.scaleFactor;
        end
        if isempty(scale)
            height = parent.position(4);
            scale  = height/0.8;
        end
        lineWidth = lineWidth*scale;
    end

end
