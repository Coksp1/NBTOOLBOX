classdef nb_x12CensusGUI < nb_methodGUI
% Description:
%
% Creating a GUI for doing seasonally adjustments
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_unitRootGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI.
%
%   - data   : The data that you want to use the unit root method on.
%
%   Output:
%   
%   - gui    : The handle of the gui object, as a nb_x12CensusGUI object.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        edit1
        edit2
        edit3
        edit4
        list1
        pop1
        pop2
        pop3
        rb1
        rb2
        rb3
        rball
        
    end

    methods
        
        function gui = nb_x12CensusGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            
            if data.frequency ~= 12 && data.frequency ~= 4
                nb_errorWindow('Only data with monthly or quarterly frequency can be seasonally adjusted.')
                return
            elseif data.numberOfDatasets > 1
                nb_errorWindow(['This method only supports one paged datasets. Is ' int2str(data.numberOfDatasets) '.'])
                return
            elseif data.numberOfObservations < 3*data.frequency
                nb_errorWindow(['This method cannot handle time-series with length of less than 3 years. The length is ' int2str(ceil(data.numberOfObservations/data.frequency)) ' years.'])
                return    
            end
            
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin)
        varargout = adjustCallback(varargin)
        varargout = allCallback(varargin)
        
    end
    
end

