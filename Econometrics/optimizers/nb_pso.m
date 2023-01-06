function [x,fval,exitflag] = nb_pso(fh,init,lb,ub,options,varargin)
% Syntax:
%
% [x,fval,exitflag] = nb_pso(fh,init,lb,ub,options,varargin)
%
% Description:
%
% Find the minimum of a function using Particle Swarm Optimization.
%
% This is a wrapper function of the pso.do function made by S. Samuel Chen.
%
% This makes it possible to add optional input arguments to the optimizer
% function, which is not possible to do in pso.do.
% 
% Input:
% 
% - fh       : The objective to minimize. As a function handle.
%
% - init     : The initial values of the optimization. Default is zero. 
%              As a  n x 1 double.
%
% - lb       : The lower bound on the x values. Set it to -inf for the   
%              elements in x that is not constrained. Default is to set it 
%              to -inf for all elements. As a n x 1 double.
%
% - ub       : The upper bound on the x values. Set it to inf for the   
%              elements in x that is not constrained. Default is to set it 
%              to inf for all elements. As a n x 1 double.
%
% - options  : See the pso.optimset method for more on this input.
% 
% Optional inputs:
%
% - varargin : Optional number of inputs given to the objective when it is
%              called during the minimization algorithm.
%
% Output:
% 
% - x        : The point at the found minimum, as a n x 1 double.
%
% - fval     : The value of the objective at the found minimum, as a 
%              scalar double. 
%
% - exitflag : See the dcumentation of the exitFlag property of  
%              the pso.do class.
%
% Examples:
%
% g  = @(x)-sin(x);
% x1 = nb_pso(g,1)
% x2 = nb_pso(g,-3)
% x3 = nb_pso(g,-3,-4,4)
%
% opt.Display = 'final';
% x4          = nb_pso(g,-3,-4,4,opt)
%
% See also:
% pso.do, pso.optimset, fmincon, fminunc, fminsearch, bee_gate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(varargin)
        inputs  = varargin;
        fHandle = @(x)funcWrapper(x,fh,inputs);
    else
        fHandle = fh;
    end
    
    if nargin < 5
        options = nb_getDefaultOptimset(struct(),'nb_pso');
        if nargin < 4
            ub = [];
            if nargin < 3
                lb = [];
            end
        end
    else
        if nb_isempty(options)
            options = nb_getDefaultOptimset(struct(),'nb_pso');
        else
            default = nb_getDefaultOptimset(struct(),'nb_pso');
            options = nb_structcat(options,default,'first');
        end
    end
    
    if strcmpi(options.Display,'iter')
        if isempty(options.OutputFcn)
           displayer         = nb_optimizerDisplayer('notifyStep',1);
           options.OutputFcn = getOutputFunction(displayer);
        end
    else 
        if isempty(options.OutputFcn)
           displayer         = nb_optimizerDisplayer('notifyStep',inf);
           options.OutputFcn = getOutputFunction(displayer);
        end
    end
    
    [x,fval,exitflag] = pso.do(fHandle,length(init),[],[],[],[],lb,ub,[],options);

end

function fval = funcWrapper(x,fHandle,inputs)
    fval = fHandle(x,inputs{:});
end
