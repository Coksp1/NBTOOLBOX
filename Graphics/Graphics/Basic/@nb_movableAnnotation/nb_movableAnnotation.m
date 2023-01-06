classdef (Abstract) nb_movableAnnotation < handle
% Superclasses:
%
% handle
%
% Description:
%     
% A abstract class for all classes that are movable. I.e. when plot in a 
% nb_figure object, the nb_figure object will trigger mouseClick and 
% mouseMove events when hold over one of these objects.
%     
% Constructor:
%     
%     No constructor
%
% See also:
% nb_arrow, nb_textArrow, nb_curlyBrace, nb_legend
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Access=protected,Hidden=true)
        
        % The type of the selection when the user want to resize or
        % move the arrow. Either 'start','end' or 'move'.
        selectionType = '';
        
        % The start point when the object is moved. As a 2x2 double.
        % The first row gives the start point in figure/panel units,
        % while the second row gives the start point in axes units.
        startPoint    = [0 0; 0 0];
        
    end
    
    events
       
        annotationMoved
        
    end
    
end
