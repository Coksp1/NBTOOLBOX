classdef (Abstract) nb_textAnnotation < nb_annotation  
% Superclasses:
%
% nb_annotation, handle
%
% Subclasses:
% 
% nb_strategyInterval, nb_barAnnotation, nb_textArrow,
% nb_textBox
%     
% Description:
%     
% A abstract superclass for all annotation objects with text.
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
% nb_strategyInterval, nb_barAnnotation, nb_textarrow,
% nb_textBox
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %==============================================================
    % Properties of the class 
    %==============================================================
    properties
        
        % Name of the font to use. Must be a string. Default is
        % 'arial'.
        fontName            = 'arial';
        
        % Sets the font size in the units given by the font units 
        % property. Must be a scalar. Default is 12.
        fontSize            = 12;
        
        % {'points'} | 'normalized' | 'inches' | 'centimeters' |
        %  'pixels'
        % 
        % Font size units. MATLAB uses this property to determine  
        % the units used by the fontSize property.
        % 
        % normalized - Interpret FontSize as a fraction of the 
        % height of the parent axes. When you resize the axes,
        % MATLAB modifies the screen fontSize accordingly.
        % 
        % pixels, inches, centimeters, and points: 
        % Absolute units. 1 point = 1/72 inch.
        fontUnits           = 'points';
        
        % Weight of text characters. {'normal'} | 'bold' | 'light' 
        % | 'demi'
        fontWeight          = 'normal';
        
        % Indicate if the font when fontUnits is set to 'normalized'
        % should be normalized to the axes ('axes') or to the
        % figure ('figure'), i.e. the default axes position 
        % [0.1 0.1 0.8 0.8].
        normalized          = 'figure';
           
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    
    methods (Access=protected,Hidden=true)
         
        %{
        -----------------------------------------------------------
        Set the font size properties, given the fontUnits property
        
        This method is called each time the fontUnits property is 
        set
        -----------------------------------------------------------
        %}
        function setFontSize(obj,oldFontUnits)
            
            normalizeFactor = 0.002911226571376; 

            switch lower(oldFontUnits)
                
                case 'points'
            
                    switch lower(obj.fontUnits)
                        case 'points'
                            % Do nothing
                        case 'normalized'
                            obj.fontSize   = obj.fontSize*normalizeFactor;
                        case 'inches'
                            obj.fontSize   = obj.fontSize/72;
                        case 'centimeters'
                            obj.fontSize   = obj.fontSize*2.54/72;
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
                case 'normalized'
                   
                    switch lower(obj.fontUnits)
                        case 'points'
                            obj.fontSize   = obj.fontSize/normalizeFactor;
                        case 'normalized'
                            % Do nothing
                        case 'inches'
                            obj.fontSize   = (obj.fontSize/normalizeFactor)/72;
                        case 'centimeters'
                            obj.fontSize   = (obj.fontSize/normalizeFactor)*2.54/72;
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
                case 'inches'
                    
                    switch lower(obj.fontUnits)
                        case 'points'
                            obj.fontSize   = obj.fontSize*72;
                        case 'normalized'
                            obj.fontSize   = (obj.fontSize*72)*normalizeFactor;
                        case 'inches'
                            % Do nothing
                        case 'centimeters'
                            obj.fontSize   = obj.fontSize*2.54;
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
                case 'centimeters' 
                    
                    switch lower(obj.fontUnits)
                        case 'points'
                            obj.fontSize   = (obj.fontSize/2.54)*72;
                        case 'normalized'
                            obj.fontSize   = ((obj.fontSize/2.54)*72)*normalizeFactor;
                        case 'inches'
                            obj.fontSize   = obj.fontSize/2.54;
                        case 'centimeters'
                            % Do nothing
                        otherwise
                            error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
                    end
                    
            end
            
        end
        
    end
    
end
