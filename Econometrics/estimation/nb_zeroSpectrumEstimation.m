function [lambda,gamma,bandWidth] = nb_zeroSpectrumEstimation(u,kernel,bandWidth,bandWithCrit)
% Syntax:
%
% [lambda,gamma,bandWidth] = nb_zeroSpectrumEstimation(residual,...
%               freqZeroSpectrumEstimator,bandWidth,bandWithCrit)
%
% Description:
%
% Estimation of frequency zero spectrum.
% 
% Input:
%
% - u             : Residual from regression nobs x 1 double.
%
% - kernel        : Either:
%
%                     > 'bartlett'  : Bartlett kernel function.
%                                     Default.
%
%                     > 'parzen'    : Parzen kernel function.
%
%                     > 'quadratic' : Quadratic Spectral kernel
%                                     function.
%
% - bandWidth    : The selected band width of the frequency zero
%                  spectrum estimation. Default is 3.
%
% - bandWithCrit : Band with selection criterion. Either:
%
%                     > 'nw'   : Newey-West selection method. 
%                                Default.
%
%                     > 'a'    : Andrews selection method. AR(1)
%                                specification.
%
%                     > ''     : Manually set by the bandWidth
%                                input.
%
% Output:
% 
% - lambda    : Freq zero spectrum. As a double.
%
% - gamma     : Autocorrelation. As a 1 x bandWidth double.
%
% - bandWidth : Selected band width.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    T = size(u,1);
    if ~isempty(bandWithCrit)
        bandWidth = findBandWith(kernel,u,bandWithCrit);
        if isnan(bandWidth)
            bandWidth = T^(1/3);
        end
    end
   
    % Get the gammas 
    if bandWidth > length(u)
        uLag      = nb_mlag(u,length(u) - 1);
        bandWidth = length(u);
    else
        uLag = nb_mlag(u,bandWidth - 1);
    end

    uLag              = [u,uLag];
    uLag(isnan(uLag)) = 0;
    gamma             = u'*uLag/T;
    
    % Get the lambda
    if strcmpi(kernel,'arols') 
        
        error([mfilename ':: ''arols'' is not yet supported.'])
        
    else
        
       switch lower(kernel) 
           
           case 'bartlett'
               K = @nb_bartlettKernel;
           case 'parzen'
               K = @nb_parzenKernel;
           case 'quadratic'
               K = @nb_quadraticSpectralKernel;
           otherwise
               error([mfilename ':: The kernel ' kernel ' is not supported.'])
       end
              
       x      = 1:(bandWidth - 1);
       x      = x/bandWidth; 
       lambda = gamma(1) + 2*K(x)*gamma(2:end)';
        
    end

end

%==================================================================
% SUB
%==================================================================
function bandWidth = findBandWith(kernel,u,bandWithCrit)
% Automatic band width selction

    T = size(u,1);

    switch lower(kernel) 
           
       case 'bartlett'
           n  = ceil(4*(T/100)^(2/9));
           q  = 1;
           cy = 1.1447;
       case 'parzen'
           n  = ceil(4*(T/100)^(4/25));
           q  = 2;
           cy = 2.6614;
       case 'quadratic'
           n  = ceil(4*(T/100)^(2/25));
           q  = 2;
           cy = 1.3221;
       otherwise
           error([mfilename ':: The kernel ' kernel ' is not supported.'])
    end
    
    switch lower(bandWithCrit)
        
        case 'nw'
            
            % Newey West (1994)
            
            % Get the gammas 
            uLead         = nb_mlead(u,n);
            uLag          = nb_mlag(u,n);
            uC            = [uLead,u,uLag];
            uC(isnan(uC)) = 0;
            gamma         = u'*uC/T;               
            
            % Find the estimated optimal band width
            s0        = sum(gamma,2);
            j         = (-n:n).^q;
            sq        = j*gamma';
            bandWidth = ceil(cy*((sq/s0)^2*T)^(1/(2*q + 1)));
            
        case 'a'
            
            % Estimate the AR(1) model of the residual
            y   = u(2:end);
            X   = nb_lag(u);
            X   = X(2:end);
            rho = nb_ols(y,X);
            
            % Andrews (1991) AR(1) specification
            if q == 1
                alpha = 4*rho^2/((1 - rho)^2*(1 + rho)^2); 
            else
                alpha = 4*rho^2/((1 - rho)^4);
            end
            
            % Find the estimated optimal band width
            bandWidth = ceil(cy*(alpha*T)^(1/(2*q + 1)));
            
        otherwise
            
            error([mfilename ':: This function does not support band width selection criterion ' bandWidthCrit])
    end

end
