classdef nb_numbering < handle
% Syntax:
%     
% obj = nb_numbering(start,chapter,language)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% A class for numbering graphs used in the nb_graph_package class.
%     
% Constructor:
%     
%     obj = nb_numbering(start,chapter,language)
%     
%     Input:
% 
%     - start     : The start number of the numbering of the 
%                   figures. Must be a double.
% 
%     - chapter   : The chapter of the graph numbering
% 
%     - language  : The language of the graph numbering.
%
%                   > 'norwegian' : 'Figur 1.1' or 'Figure 1.1a'.
%
%                   > 'english'   : 'Chart 1.1' or 'Chart 1.1a'.
%
%     - bigLetter : Logical that indicates if "number" should be given by
%                   letters or numbers.
%     
%     Output
% 
%     - obj       : An object of class nb_numbering
%     
%     Examples:
% 
%     obj = nb_numbering(1,1,'norwegian',false)
%     
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Give 1 the numbering should be don with a big letter 
        % instead of an number. I.e. 'Figur 1.A' or 'Chart 1.A', instead 
        % of 'Figure 1.1' or 'Chart 1.1'.
        bigLetter       = 0;
        
        % The chapter of the graph numbering. As a double.
        chapter         = [];
        
        % Indicator of letter counting. Set to 0 if the new 
        % graphs should be numbered with letters instead of 
        % normal numbering. I.e. 1a, 1b,... Otherwise 1. 
        counter         = 0;
        
        % The language of the graph numbering. As  a string.
        language        = 'english';
        
        % The current letter of the graph numbering. As a 
        % double.
        letter          = 65;
        
        % The current graph number. As a double.
        number          = [];
        
    end
    
    methods
        
        function obj = nb_numbering(start,chapter,language,bigLetter)
            
            if nargin < 4
                bigLetter = false;
            end
            obj.bigLetter = bigLetter;
            
            if isscalar(chapter) || isempty(chapter)
                obj.chapter  = chapter;
            else
                error([mfilename ':: The chapter input must be a scalar with the chapter of the graph numbering, or empty.'])
            end
            
            if isscalar(start)
                obj.number  = start;
            else
                error([mfilename ':: The start input must be a scalar with the start number of the graph numbering.'])
            end
            
            if ischar(language)
                obj.language  = language;
            else
                error([mfilename ':: The language input must be a string with the lanaguage of the graph numbering.'])
            end
            
        end
        
        varargout = plus(varargin)
            
        varargout = hold(varargin)

        varargout = char(varargin)

        varargout = charData(varargin)
        
    end
    
end
        
