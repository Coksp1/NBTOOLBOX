classdef nb_reIndexGUI < nb_methodGUI
% Description:
%
% Open up the re indexation (time-series) dialog window.
%
% Superclasses:
%
% nb_methodGUI, handle
%
% Constructor:
%
%   gui = nb_reIndexGUI(parent,data)
% 
%   Input:
%
%   - parent     : As an object of class nb_GUI.
%
%   - data       : As an object of class nb_ts.
% 
%   Output:
% 
%   - gui        : An object of class nb_reIndexGUI.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties(Access=protected,Hidden=true)
        
        edit1         = [];
        edit2         = [];
        edit3         = [];
        figureHandle  = [];
        list1         = [];
        oldDate       = nb_date;
        oldObs        = [];
        
    end
    
    methods
        
        function gui = nb_reIndexGUI(parent,data)
           
            gui = gui@nb_methodGUI(parent,data);
            if isa(data,'nb_ts')
                gui.oldDate = data.startDate;
            else
                gui.oldObs = data.startObs;
            end
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = calculateCallback(varargin)
        
        varargout = dateChangeCallback(varargin)
        
    end
    
    methods(Static=true)
       
        function [newDate,message] = interpretDate(DB,string)

            message = '';
            ind     = strfind(string,'%#');
            if isempty(ind)
                try
                    newDate = nb_date.date2freq(string);
                catch %#ok<CTCH>
                    message = ['The provided date is on a wrong date format; ''' string '''.'];
                    return
                end

            else
                dateT = nb_localVariables(DB.localVariables,string);
                try
                    newDate = nb_date.date2freq(dateT);
                catch %#ok<CTCH>
                    if strcmpi(dateT,string)
                        message = ['Undefined local variable ''' string '''.'];
                    else
                        message = ['The provided date is on a wrong date format; ''' dateT ''', which is defined by the local variable ''' string '''.'];
                    end
                    return
                end
            end

        end
        
    end
    
end
