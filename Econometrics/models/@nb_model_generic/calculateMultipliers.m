function mult = calculateMultipliers(obj,varargin)
% Syntax:
%
% mult = calculateMultiplers(obj,varargin)
%
% Description:
%
% Calculate multiplier using the formula (3) page 11 of "Clearing Up the
% Fiscal Multiplier Morass" (2015) by Leeper, Traum and Walker.
%
% Caution: This function assumes that the variables given to the variables
%          input is delta_Y and delta_G not Y and G of the formula (3)!
% 
% Input:
% 
% - obj        : An object of class nb_dsge.
%
% Optional input:
%
% - 'variables'  : A cellstr with the variables to produce the multipliers
%                  of. Must be provided!
%
% - 'instrument' : A one line char with the name of the instrument. 
%                  Must be provided!
%
% - 'rate'       : A one line char with the name of the interest rate to 
%                  use calculate the net present value. Must be provided!
%
% - 'shocks'     : A cellstr with the shocks to produce the multipliers
%                  of. Must be provided!
% 
% - 'gross'      : Give false if the rate input is the net interest rate.
%                  Default is true, i.e. that the rate input is the gross
%                  interest rate.
%
% - 'perc'       : Error band percentiles. As a 1 x nPerc double.
%                  E.g. [0.3,0.5,0.7,0.9]. If empty all the simulation will
%                  be returned.
% 
% - rest         : Use the 'replic' option to produce error bands.
%
% Output:
% 
% - mult       : A nShocks x nVars x nSim (nPerc) nb_cs object. Use the 
%                double method on this output to convert it to a double 
%                matrix.
%
% See also:
% nb_model_generic.irf, nb_calcMultiplier
%
% Written by Kenneth Sæterhagen Paulsen
 
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Parse optional inputs
    [variables,varargin]  = nb_parseOneOptional('variables',[],varargin{:});
    if isempty(variables)
        error([mfilename ': The variables input must be given (and not empty).'])
    end
    if ~iscellstr(variables)
        error([mfilename ': The variables input must be a cellstr.'])
    end
    
    [instrument,varargin]  = nb_parseOneOptional('instrument',[],varargin{:});
    if isempty(instrument)
        error([mfilename ': The instrument input must be given (and not empty).'])
    end
    if ~nb_isOneLineChar(instrument)
        error([mfilename ': The instrument input must be a one line char.'])
    end
    
    [rate,varargin]  = nb_parseOneOptional('rate',[],varargin{:});
    if isempty(rate)
        error([mfilename ': The rate input must be given (and not empty).'])
    end
    if ~nb_isOneLineChar(rate)
        error([mfilename ': The rate input must be a one line char.'])
    end
    
    [shocks,varargin]  = nb_parseOneOptional('shocks',[],varargin{:});
    if isempty(shocks)
        error([mfilename ': The shocks input must be given (and not empty).'])
    end
    if ~iscellstr(shocks)
        error([mfilename ': The shocks input must be a cellstr.'])
    end
    
    [perc,varargin]  = nb_parseOneOptional('perc',[],varargin{:});
    [gross,varargin] = nb_parseOneOptional('gross',true,varargin{:});
    if any(ismember({'variables','shocks'},varargin(1:2:end)))
        error([mfilename ':: The ''variables'' and ''shocks'' optional input is not allowed!'])
    end
    
    % Produce the IRFs 
    inputs           = ['variables',{[variables,rate,instrument]},'shocks',{shocks},varargin];
    [irfs,irfsBands] = irf(obj,inputs{:});

    % Calculate the present value multipliers
    nShocks = length(shocks);
    nVars   = length(variables);
    if ~isempty(irfsBands)
        
        nSim = irfsBands.(shocks{1}).numberOfDatasets;
        mult = nan(nShocks,nVars,nSim);
        for ii = 1:nShocks
            irfS         = irfsBands.(shocks{ii});
            dx           = getVariable(irfS,variables);
            dy           = getVariable(irfS,instrument);
            r            = getVariable(irfS,rate);
            mult(ii,:,:) = nb_calcMultiplier(dx,dy,r,gross);
        end
        
        mult = nb_cs(mult,'Simulation',shocks,variables);
        if ~isempty(perc)
            perc = nb_interpretPerc(perc,false);
            mult = percentiles(mult,perc);
        end
        
    else
        
        mult = nan(nShocks,nVars);
        for ii = 1:nShocks
            irfS       = irfs.(shocks{ii});
            dx         = getVariable(irfS,variables);
            dy         = getVariable(irfS,instrument);
            r          = getVariable(irfS,rate);
            mult(ii,:) = nb_calcMultiplier(dx,dy,r,gross);
        end
        mult = nb_cs(mult,'',shocks,variables);
        
    end
    
end
