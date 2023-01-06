function nb_clearall(closeFig)
% Syntax:
%
% nb_clearall()
% nb_clearall(false)
%
% Description:
%
% Clear all variables, close all figures and clear command window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        closeFig = true;
    end

    if closeFig
        close all
    end
    evalin('base','clear all');
    evalin('base','clear classes');
    evalin('base','clear all');
    clc
    
end
