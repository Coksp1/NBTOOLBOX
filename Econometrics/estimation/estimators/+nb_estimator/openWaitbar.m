function [h,doDelete] = openWaitbar(options,iter,recursive)
% Syntax:
%
% [h,doDelete] = nb_estimator.openWaitbar(options,iter)
%
% Description:
%
% Open up waitbar for recursive estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        recursive = true;
    end

    if isfield(options,'waitbarHandle')
        
        h = options.waitbarHandle;
        if ~ischar(h) % May be set to 'none'
            if ~isempty(iter) && iter ~= 1 && recursive
                h.maxIterations3 = iter;
                h.text3          = 'Starting...'; 
            end
            doDelete = false;
        else
            h = [];
        end
        
    else
        
        doDelete = true;
        if recursive
            
            if ~isempty(iter) && iter == 1
                visible = 'off'; % Don't display waitbar if only one iteration!
            else
                visible = 'on'; 
            end
            
            if isfield(options,'index')
                h = nb_waitbar5([],['Recursive Estimation of Model '  int2str(options.index) ' of ' int2str(options.nObj) ],true,false,visible);
            else
                h = nb_waitbar5([],'Recursive Estimation',true,false,visible);
            end
            h.maxIterations3 = iter;
            h.text3 = 'Starting...'; 
            
        else
            
            if isfield(options,'index')
                h = nb_waitbar5([],['Estimation of Model '  int2str(options.index) ' of ' int2str(options.nObj) ],true,false);
            else
                h = nb_waitbar5([],'Estimation',true,false);
            end
            
        end
    end
    
end

