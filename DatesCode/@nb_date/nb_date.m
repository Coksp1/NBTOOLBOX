classdef nb_date
% Description:
%
% The superclass of all the different dates at different 
% frequencies
%
% This class also includes some static functions which are general 
% for all date frequencies.
%
% Subclasses: 
%
% nb_day, nb_week, nb_month, nb_quarter, nb_semiAnnual nb_year   
% 
% Constructor:
%    
%   obj = nb_date % Constructs an empty date object
%
%   Input:
% 
%   No inputs
% 
%   Output:
% 
%   No outputs
% 
%   Examples:
%
%   obj = nb_date; 
% 
% See also:
% nb_year, nb_semiAnnual, nb_quarter, nb_month, nb_week, nb_day
%
% Written by Kenneth S. Paulsen    

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The base year. 2000.
        baseYear  = 2000;
        
        % The day which the weekly date represents when converted 
        % to or from a weekly frequency. Default is 1, which is sunday.
        dayOfWeek = 1;
        
        % Indicator for leap year. 1 if leap year.
        leapYear  = [];
        
    end
    
    %==============================================================
    % Some abstract methods of the nb_date class 
    % (No constructor exist)
    %==============================================================
    methods
        
        varargout = colon(varargin)
        varargout = isempty(varargin)
        varargout = isEqualFreq(varargin)
        varargout = isLeapYear(varargin)
        varargout = toString(varargin)
        
    end
    
    %==============================================================
    % Static methods of the class
    %==============================================================
    methods(Static=true)
        
        varargout = date2freq(varargin)
        varargout = fromxlsDates2freq(varargin)
        varargout = format2string(varargin)
        varargout = getFreq(varargin)
        varargout = getFrequencyAsInteger(varargin)
        varargout = getFrequencyAsString(varargin)
        varargout = initialize(varargin)
        varargout = isDate(varargin)
        varargout = toDate(varargin)  
        varargout = today(varargin)
        varargout = getEarliestDate(varargin)
        varargout = getLatestDate(varargin)
        varargout = union(varargin)
        varargout = intersect(varargin)
        varargout = toFormat(varargin)
        varargout = vintage2Date(varargin)
        varargout = cell2Date(varargin)
        varargout = max(varargin)
        varargout = min(varargin)
        
    end
    
end
