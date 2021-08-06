%% Create base terms

% Numbers
n0  = nb_num(0);
n1  = nb_num(1);
nPi = nb_num(pi);
n05 = nb_num(0.5);
nm1 = nb_num(-1);
n2  = nb_num(2);

% Bases
x = nb_base('x');
y = nb_base('y');
i = nb_base('i');
I = nb_base('I');

% Equations
ePlus   = nb_term.split('x+y');
eTimes  = nb_term.split('x*y');
eDiv    = nb_term.split('x/y');
eDivRev = nb_term.split('y/x');
ePow    = nb_term.split('x^y');

%% Plus

clc

ep1  = n1 + n0
ep2  = n0 + x
ep3  = x + y
ep4  = nPi + x
ep5  = ePlus + x
ep6  = ePlus + y
ep7  = eTimes + x
ep8  = eTimes + x*y
ep9  = eDiv + x
ep10 = eDiv + eDivRev
ep11 = x + x

%% Minus

clc

em1  = n1 - n0
em2  = n0 - x
em3  = x - y
em4  = nPi - x
em5  = x - n0 
em6  = x - x
em7  = ePlus - x
em8  = ePlus - y
em9  = eTimes - x
em10 = eTimes - x*y
em11 = eDiv - x
em12 = eDiv - eDivRev
em13 = x - x

%% Times

clc

et1  = n1 * n0
et2  = n0 * x
et3  = n1 * x
et4  = x * y
et5  = nPi * x
et6  = x * nPi
et7  = x * n0 
et8  = nm1 * x 
et9  = ePlus * x
et10 = ePlus * y
et11 = eTimes * x
et12 = eTimes * x*y
et13 = eDiv * x
et14 = eDiv * y
et15 = eDiv * eDivRev
et16 = x * x
et17 = ePlus * ePlus
et18 = eTimes * ePlus 
et19 = ePlus * eTimes 
et20 = x ^ (y-1) * x ^ y
et21 = x ^ (y-1) / x ^ y

%% Division

clc

ed1  = n0 / n1
ed2  = n1 / n0
ed3  = n0 / x
ed4  = n1 / x
ed5  = x / y
ed6  = nPi / x
ed7  = x / nPi
ed8  = x / n0 
ed9  = ePlus / x
ed10 = ePlus / y
ed11 = eTimes / x
ed12 = eTimes / (x*y)
ed13 = eTimes / x*y
ed14 = eDiv / x
ed15 = eDiv / y
ed16 = eDiv / eDiv
ed17 = eDiv / eDivRev
ed18 = x / x
ed19 = eDiv / ePlus
ed20 = ePlus / eDiv

%% Power

clc

epo1  = n0 ^ n1
epo2  = n1 ^ n0
epo3  = n0 ^ x
epo4  = n1 ^ x
epo5  = x ^ y
epo6  = nPi ^ x
epo7  = x ^ nPi
epo8  = x ^ n0 
epo9  = x ^ nm1 ^ nm1 
epo10 = x ^ ePlus
epo11 = (x ^ ePlus)*y
epo12 = (x ^ (ePlus/x))*y
epo13 = x ^ eTimes
epo14 = n05 ^ eTimes
epo15 = eTimes ^ n05
epo16 = ePlus ^ n05
epo17 = eTimes ^ x
epo18 = ePlus ^ x
epo19 = x ^ nm1 * x
epo20 = n2 ^ x * n2
epo21 = x ^ (x^y)
epo22 = (x ^ x)^y
epo23 = (x ^ x)^y^ePlus

%% Sqrt -> x^0.5

clc

es1  = sqrt(n1)
es2  = sqrt(n0)
es3  = sqrt(nPi)
es4  = sqrt(nm1)
es5  = sqrt(x)
es6  = sqrt(ePlus)
es7  = sqrt(eTimes)
es8  = sqrt(eDivRev) 
es9  = sqrt(ePow)
es10 = sqrt(sqrt(x))

%% Log

clc

el1  = log(n1)
el2  = log(n0)
el3  = log(nPi)
el4  = log(nm1)
el5  = log(x)
el6  = log(ePlus)
el7  = log(eTimes)
el8  = log(eDivRev) 
el9  = log(ePow)
el10 = log(sqrt(x))
el12 = log(eTimes) + x
el13 = log(eTimes) + log(x)
el14 = log(eTimes) * log(x)
el15 = log(eDiv) + log(y)
el16 = log(y) ^ x
el17 = log(eDiv) ^ log(y)
el18 = log(exp(x))

%% Exponential

clc

el1  = exp(n1)
el2  = exp(n0)
el3  = exp(nPi)
el4  = exp(nm1)
el5  = exp(x)
el6  = exp(ePlus)
el7  = exp(eTimes)
el8  = exp(eDivRev) 
el9  = exp(ePow)
el10 = exp(sqrt(x))
el12 = exp(eTimes) + x
el13 = exp(eTimes) + exp(x)
el14 = exp(eTimes) * exp(x)
el15 = exp(eDiv) + exp(y)
el16 = exp(y) ^ x
el17 = exp(eDiv) ^ exp(y)
el18 = exp(log(x))
el19 = exp(eDiv) * exp(x)

%% General functions
% E.g: logncdf, lognpdf, normcdf, normpdf or steady_state

clc

en1 = normpdf(n2,n0,n1)
en2 = normpdf(x,n0,n1)
en3 = normpdf(x,n0,n1*nPi)
en4 = normpdf(x,n0,eTimes)
en5 = normpdf(x,n0,n1) + y
en6 = normpdf(x,n0,n1) + normpdf(x,n0,n1)

%% Interpret equations using nb_term.split

clc

ei1  = nb_term.split('x+y')
ei2  = nb_term.split('x-y')
ei3  = nb_term.split('x*y')
ei4  = nb_term.split('x/y')
ei5  = nb_term.split('x^y')
ei6  = nb_term.split('exp(x)')
ei7  = nb_term.split('exp(x)+2')
ei8  = nb_term.split('2+y')
ei9  = nb_term.split('4+1')
ei10 = nb_term.split('exp(2)')
ei11 = nb_term.split('normpdf(x)')
ei12 = nb_term.split('normpdf(x,0,1) + normpdf(x,0,1)')
ei13 = nb_term.split('normpdf(x,0,1) + normpdf(x,0,2)')
ei14 = nb_term.split('(1-y)*x + y*x')
ei15 = nb_term.split('x/y*(1-x/x)')
ei16 = nb_term.split('(1)*gap(y)')
ei17 = nb_term.split('(exp(a).*(k.^alpha))*a/(exp(a).*(k.^alpha))')
ei18 = nb_term.split('(exp(a).*(alpha.*k.^(alpha-1)))*k/(exp(a).*(k.^alpha))')

%% More advanced equations

clc

beta = nb_base('beta');
r    = nb_base('r');
c    = nb_base('c');
dc   = nb_base('dc');
dp   = nb_base('dp');
p    = nb_base('p');
y    = nb_base('y');
e1   = (beta*(1+r))*c;
e2   = beta*r*c;
eq1  = e1/e1
eq2  = e1/e1^2
eq3  = e1/e1^beta
eq4  = e2/e1
eq5  = e2/e1^2
eq6  = e2/e1^beta
eq7  = e2*e1
eq8  = steady_state(r)*steady_state(c)/(steady_state(r).*steady_state(c))
eq9  = ((beta.*c)./y)*r
eq10 = (((beta.*(1+r)).*c)./y)
eq11 = eq9/eq10
eq12 = (-(((beta.*(1+r)).*c)./y.^2))*y/(((beta.*(1+r)).*c)./y)
eq13 = y - ((beta*(c*dc)))/((p*dp)*c)
eq14 = y-((p/(p+(-1)))*((1+(-(1/p)))*c)) 


%% Special methods

u   = unique([r,c,beta,r])
uni = union([r,c,beta,r],[r,c])
int = intersect([r,c,beta,r],[r,c])

