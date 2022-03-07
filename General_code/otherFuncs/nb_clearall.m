function nb_clearall()
% Syntax:
%
% nb_clearall()
%
% Description:
%
% Clear all variables, close all figures and clear command window.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    close all
    evalin('base','clear all');
    evalin('base','clear classes');
    evalin('base','clear all');
    clc
    
end
