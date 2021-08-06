%% Declare some variables and parameters

var1 = nb_eq2Latex('var1');
var2 = nb_eq2Latex('var2');
var3 = nb_eq2Latex('var3');
var4 = nb_eq2Latex('var4');
var5 = nb_eq2Latex('v_{t+1}');

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
eq3 = normcdf(var1+var2*var2,2,3.5)
eq4 = normpdf(var1+var1*var2,2,3.5)

%% Equations

eq1  = var1*var2*var1^2
eq2  = exp(-var1)
eq3  = exp(log(var1^2))
eq4  = sqrt(var1/var1*var2 + var1^var3 - var4/var1)
eq5  = var4/var1
eq6  = exp(var1+var2) == 0
eq7  = exp(var1+var2) >= 0
eq8  = exp(var1+var2) <= 0
eq9  = exp(var1+var2) ~= 0
eq10 = exp(var1+var2) > 0
eq11 = exp(var1+var2) < 0
eq12 = var5 * var4

%% Write equations to PDF

eqs  = [eq1,eq2,eq3,eq4,eq5,eq6,eq7,eq8,eq9,eq10,eq11];
% code = writeTex(eqs,'test');
writePDF(eqs,'test')

%% Write equations to PDF

expr  = {
'var1*var2*var1^2'
'exp(-var1)'
'exp(log(var1^2))'
'sqrt(var1/var1*var2 + var1^var3 - var4/var1)'
'var4/var1'
'exp(var1+var2)'
};
eqs = nb_eq2Latex.parse(expr);
% code = writeTex(eqs,'test');
writePDF(eqs,'test')

%% Write equations to PDF

expr  = {
'alpha*beta^kappa'
'sqrt(2*pi)*theta^kappa'
};
eqs = nb_eq2Latex.parse(expr,...
    'vars',{'alpha','beta','kappa','pi','theta'},...
    'latexVars',{'\alpha','\beta','\kappa','\pi','\theta'});
writePDF(eqs,'test2')
