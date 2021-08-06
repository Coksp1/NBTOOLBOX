classdef (Abstract) nb_lineAnnotation < handle 
% Superclasses:
%
% handle
%
% Subclasses:
% 
% nb_curlyBrace, nb_drawLine, nb_drawPatch, nb_regressLine,
% nb_textArrow, nb_textBox, nb_arrow
%     
% Description:
%     
% A abstract superclass for all annotation objects with line and/or 
% markers to scale.
%     
% Constructor:
%     
%     No constructor
%
% Properties:
% 
%   No properties 
%
% See also:
% nb_curlyBrace, nb_drawLine, nb_drawPatch, nb_regressLine,
% nb_textArrow, nb_textBox, nb_arrow
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %==============================================================
    % Properties of the class 
    %==============================================================
    properties (Hidden=true)
        
        returnNonScaled = false;
           
    end
    
end
