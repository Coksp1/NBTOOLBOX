function nb_confirmWindowTextArea(message,callbackfuncNo,callbackfuncYes,...
                          nameOfWindow,buttonNo,buttonYes)
% Syntax:
%
% nb_confirmWindowTextArea(message,callbackfuncNo,callbackfuncYes,...
%   nameOfWindow,buttonNo,buttonYes)
%
% Description:
%
% A window for printing confirmation messages.
%
% Possible answers is yes and no by default.
% 
% Input:
% 
% - message         : The question to ask
%
% - callbackfuncNo  : The callback function handle to be called if 
%                     answering no. Can also be a cell.
%
% - callbackfuncYes : The callback function handle to be called if 
%                     answering yes. Can also be a cell.
%
% - nameOfWindow    : Name to provide the window. Default is 'Warning'
%
% - buttonNo        : Text displayed on the "no" button.
%
% - buttonYes       : Text displayed on the "yes" button.
% 
% Output:
% 
% - ret     : 1 if answer is yes, otherwise 0. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        buttonNo = 'No';
        if nargin < 5
            buttonYes = 'Yes';
            if nargin < 4
                nameOfWindow = 'Warning';
            end
        end
    end

    % Create the window
    f = nb_guiFigure([],nameOfWindow,[40,15,500,300],'modal','off',[],'uifigure');

    % Make main grid
    grid             = uigridlayout(f,[2,1],'Scrollable','off');
    grid.RowHeight   = {'1x',22};
    grid.ColumnWidth = {'1x'};
    
    % Print question message
    uitextarea(grid,'Value',message);

    % Make sub grid
    subGrid             = uigridlayout(grid,[1,5],'Scrollable','off');
    subGrid.Padding     = [0,0,0,0];
    subGrid.RowHeight   = {'1x'};
    subGrid.ColumnWidth = {'1x','1x','1x','1x','1x'};

    % Push buttons to give an answer
    bNo = uibutton(subGrid,'Text',buttonNo,'ButtonPushedFcn',callbackfuncNo);
    bNo.Layout.Column = 2;

    bYes = uibutton(subGrid,'Text',buttonYes,'ButtonPushedFcn',callbackfuncYes);
    bYes.Layout.Column = 4;
            
    % Make it visible.
    set(f,'Visible','on');             
    
end
