function [estPar,fval,Hessian,err] = nb_callOptimizer(optimizer,fh,init,lb,ub,opt,message,varargin)
% Syntax:
%
% [estPar,fval,Hessian] = ...
%     nb_callOptimizer(optimizer,fh,init,lb,ub,opt,message,varargin)
% [estPar,fval,Hessian,err] = ...
%     nb_callOptimizer(optimizer,fh,init,lb,ub,opt,message,varargin)
%
% Description:
%
% Generic function to call different optimizers on a specific job.
% 
% Input:
% 
% - optimizer : A one line char with the optimizer to use. Go to see also
%               section for a list of the supported optimizers.
%
% - fh        : A function handle with the function to minimize.
%
% - init      : Initial values on the parameters. As a nPar x 1 double.
%
% - lb        : Lower bound on the parameters. These may need to finite
%               for some optimizers! As a nPar x 1 double.
%
% - ub        : Upper bound on the parameters. These may need to finite
%               for some optimizers! As a nPar x 1 double.
%
% - opt       : A struct with the optimization options. See 
%               nb_getDefaultOptimset.
%
% - message   : Extra message given when some error happend during
%               estimation. May be set to ''.
%
% Optional input:
%
% - 'Aeq'     : Apply linear equality constraints. For more see the 
%               documentation of the Aeq input to the fmincon function.
%               Only supported when optimizer is set to 'fmincon'.
%
% - 'Beq'     : Apply linear equality constraints. For more see the  
%               documentation of the Aeq input to the fmincon function.
%               Only supported when optimizer is set to 'fmincon'.
%
% - 'NONLCON' : Apply non-linear constraints. For more see the
%               documentation of the constraints property of the nb_abc
%               class or the NONLCON input to the fmincon function.
%               Only supported when optimizer is set to 'nb_abc' or 
%               'fmincon'.
%
% - varargin  : Optional inputs given to the function handle fh when being
%               evaluated.
% 
% Output:
% 
% - estPar    : The values of the parameters that minimizes the function.
%               As a nPar x 1 double.
%
% - fval      : Value of the function at the minimum. As a scalar double.
%
% - Hessian   : Estimate of the Hessian at the found minimum.
%
% - err       : Provide this output to return error instead of throwing it
%               inside this function.
%
% See also:
% nb_abc, nb_fmin, nb_pso, fmincon, fminunc, fminsearch, bee_gate  
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c)  2019, Norges Bank

    % Parse constraint options
    [Aeq,varargin]     = nb_parseOneOptional('Aeq',[],varargin{:});
    [Beq,varargin]     = nb_parseOneOptional('Beq',[],varargin{:});
    [NONLCON,varargin] = nb_parseOneOptional('NONLCON',[],varargin{:});

    % Call selected optimizer
    Hessian = [];
    err     = '';
    if strcmpi(optimizer,'nb_fmin')
        [estPar,fval,exitflag,Hessian] = nb_fmin.call(fh,init,lb,ub,opt,varargin{:});
    elseif strcmpi(optimizer,'fmincon')
        [estPar,fval,exitflag,~,~,~,Hessian] = fmincon(fh,init,[],[],Aeq,Beq,lb,ub,NONLCON,opt,varargin{:});
    elseif strcmpi(optimizer,'fminunc')
        [estPar,fval,exitflag,~,~,Hessian] = fminunc(fh,init,opt,varargin{:});
    elseif strcmpi(optimizer,'fminsearch')
        [estPar,fval,exitflag] = fminsearch(fh,init,opt,varargin{:});
    elseif strcmpi(optimizer,'bee_gate')
        [estPar,fval,exitflag,Hessian] = bee_gate(fh,init,lb,ub,opt,varargin{:});
    elseif strcmpi(optimizer,'nb_abc')
        [estPar,fval,exitflag,Hessian] = nb_abc.call(fh,init,lb,ub,opt,NONLCON,varargin{:});    
    elseif strcmpi(optimizer,'nb_pso')
        [estPar,fval,exitflag] = nb_pso(fh,init,lb,ub,opt,varargin{:});  
    elseif strcmpi(optimizer,'csminwel')
        [fval,estPar,~,~,~,~,exitflag] = csminwel(fh,init,eye(size(init,1)),[] ,opt.TolFun,opt.MaxIter,varargin{:});
    else
        [estPar,fval,exitflag] = feval(optimizer,fh,init,opt,varargin{:});
    end  
    message = nb_interpretExitFlag(exitflag,optimizer,message);
    if ~isempty(message)
        if nargout > 3
            err     = message;
            Hessian = [];
            return
        else
            messageState = getenv('optimizerMessageState');
            if strcmpi(messageState,'true')
                warning('nb_interpretExitFlag:warning',[mfilename ':: ' message])
            else
                error([mfilename ':: ' message])
            end
        end
    end

    % Find Hessian if not already found
    if nargout > 2
        if isempty(Hessian)
            Hessian = nb_hessian(@(x)fh(x,varargin{:}),estPar);
        end
    end
    
end
