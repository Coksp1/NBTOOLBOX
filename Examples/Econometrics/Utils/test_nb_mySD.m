%% Declare some variables and parameters

var1 = nb_mySD('var1');
var2 = nb_mySD('var2');
var3 = nb_mySD('var3');
var4 = nb_mySD('var4');
p    = nb_param({'p','q','r'});

%% Plus

eq1 = 2 + var1
eq2 = var1 + var2
eq3 = var1 + 2

%% Minus

eq1 = 2 - var1
eq2 = var1 - var2
eq3 = var1 - 2
eq4 = var1 - (var2 + var3)
eq5 = -var1

%% Times

eq1  = 1*var1
eq2  = var1*1
eq3  = var1*2
eq4  = 2 + 2*var1
eq5  = var1*var2
eq6  = (var1 + var2)*var1
eq7  = 1*(var1^2)
eq8  = 2*(var1 + var2^3)
eq9  = var1*var2*var1
eq10 = var1*var2*var3
eq11 = var1*(var1 + var2^3)

%% Divide

eq1 = 1/var1
eq2 = var1/1
eq3 = var1/2
eq4 = 2 + 2/var1
eq5 = var1/var2
eq6 = (var1 + var2)/var1
eq7 = 1/(var1^2)
eq8 = 2/(var1 + var2^3)

%% Power

eq1 = 1^var1
eq2 = var1^1
eq3 = var1^2
eq4 = 2 + 2^var1
eq5 = var1^var2
eq6 = var1^var2*var1

%% Square root

eq1 = sqrt(var1)
eq2 = sqrt(var1 + var2)
eq3 = sqrt((var1 + var2))
eq4 = sqrt((var1 + var2)*var3)

%% Exponential

eq1 = exp(var1)
eq2 = exp(var1 + var2)
eq3 = exp((var1 + var2))
eq4 = exp((var1 + var2)*var3)
eq5 = var1*exp(4)

%% Natural logarithm

eq1 = log(var1)
eq2 = log(var1 + var2)
eq3 = log((var1 + var2))
eq4 = log((var1 + var2)*var3)
eq5 = var1*log(4)

%% Distributions

eq1 = logncdf(var1+var1*var2,2,3.5)
eq2 = lognpdf(var1+var1*var2,2,3.5)
eq3 = normcdf(var1+var1*var2,2,3.5)
eq4 = normpdf(var1+var1*var2,2,3.5)

%% Equations

eq1 = var1*var2*var1^2
eq2 = exp(-var1)
eq3 = exp(log(var1^2))
eq4 = sqrt(var1/var1*var2 + var1^var3 - var4/var1)
eq5 = var4/var1

%% Parentheses 

str = nb_mySD.addPar('x',true)
str = nb_mySD.addPar('x',false)
str = nb_mySD.addPar('x+1',true)
str = nb_mySD.addPar('x+1',false)
str = nb_mySD.addPar('(x+1)*(y-1)',true)
str = nb_mySD.addPar('(x+1)*(y-1)',false)
str = nb_mySD.addPar('(x+1)^y',true)
str = nb_mySD.addPar('(x+1)^y',false)
str = nb_mySD.addPar('(var1 + var2)',true)
str = nb_mySD.addPar('(var1 + var2)',false)
str = nb_mySD.addPar('(var1 + var2)*var1',true)
str = nb_mySD.addPar('(var1 + var2)*var1',false)
str = nb_mySD.addPar('var1*(var1 + var2)',true)
str = nb_mySD.addPar('var1*(var1 + var2)',false)
str = nb_mySD.addPar('log(var1)',true)
str = nb_mySD.addPar('log(var1)',false)

%% Plus (nb_param)

eq1 = p(1) + var1
eq2 = p(2) + p(1)
eq3 = p(1) + 'test'
eq4 = p(1) + 0
eq5 = 0 + (p(1) + p(2))
eq6 = 0 + p(1) - p(2)

%% Minus (nb_param)

eq1 = p(1) - var1
eq2 = p(2) - p(1)
eq3 = p(1) - 'test'
eq4 = p(1) - 0
eq5 = 0 - (p(1) - p(2))
eq6 = 0 - p(1) - p(2)

%% Times (nb_param)

eq1 = p(1)*var1
eq2 = p(2)*p(1)
eq3 = p(1)*'test'
eq4 = p(1)*2
eq5 = 3*(p(1) - p(2))
eq6 = 2*p(1) - p(2)
eq7 = 2*p(1)*var1
eq8 = var1*p(1)

%% Divide (nb_param)

eq1 = p(1)/var1
eq2 = p(2)/p(1)
eq3 = p(1)/'test'
eq4 = p(1)/2
eq5 = 3/(p(1) - p(2))
eq6 = 2/p(1) - p(2)
eq7 = 2/p(1)*var1
eq8 = var1/p(1)

%% Power (nb_param)

eq1 = p(1)^var1
eq2 = p(2)^p(1)
eq3 = p(1)^'test'
eq4 = p(1)^2
eq5 = 3^(p(1) - p(2))
eq6 = 2^p(1) - p(2)
eq7 = 2^p(1)*var1
eq8 = var1^p(1)

%% Square root

eq1 = sqrt(p(1))
eq2 = sqrt(p(1)*p(2) + p(3))
eq3 = sqrt(var1*p(1))

%% Exponential

eq1 = exp(p(1))
eq2 = exp(p(1)*p(2) + p(3))
eq3 = exp(var1*p(1))

%% Natural logarithm

eq1 = log(p(1))
eq2 = log(p(1)*p(2) + p(3))
eq3 = log(var1*p(1))

%% Distributions

eq1 = logncdf(var1,p(1),p(2))
eq2 = lognpdf(var1,p(1),p(2))
eq3 = normcdf(var1,p(1),p(2))
eq4 = normpdf(var1,p(1),p(2))

%% Max operator

eq1 = max(var1,var1^2)
eq2 = max(var1^2,p(1))
eq3 = max(7 - var1,2)
eq4 = max(7 - var1,var2 - 3)

%% Min operator

eq1 = min(var1,var1^2)
eq2 = min(var1^2,p(1))
eq3 = min(7 - var1,2)
eq4 = min(7 - var1,var2 - 3)

%% Construct vector of nb_mySD and nb_param

func = @(x)x(1)*x(2);
comb = [var1,p(1)];
eq1  = func(comb)

%% Evaluate derivatives

func                = @(x,y)x*y;
[fH,I,J,V,jac]      = nb_doSymbolic(func,{'x','y'},{},[2,1]);
func                = @(x,y,p)x*y^p; % Parameters at the end!
[fH2,I2,J2,V2,jac2] = nb_doSymbolic(func,{'x','y'},{'p'},[2,1],0.5);
