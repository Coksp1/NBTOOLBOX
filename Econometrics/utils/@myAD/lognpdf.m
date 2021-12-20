function x = lognpdf(x,m,k)
% Syntax:
%
% x = lognpdf(x,m,k)
%
% Description:
%
% Log normal pdf.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x.derivatives = valXder(lognormal_deriv(x.values(:),m,k), x.derivatives);
    x.values      = nb_distribution.lognormal_pdf(x.values,m,k);
    
end

function x = lognormal_deriv(x,m,k)
    t = exp(-0.5*((x - m)./k).^2)/sqrt(2*pi*k^2);
    x = -(1/x)*((log(x) - m)/k)*t;
end
