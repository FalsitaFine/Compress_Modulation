function [jaco] = jacobin(x,a,c,t,n)
switch n
    case 2
        jaco = [ (exp(-(c + x)/t)*(c + x)^2)/t^2, (a*exp(-(c + x)/t)*(2*c + 2*x))/t^2 - (a*exp(-(c + x)/t)*(c + x)^2)/t^3, (a*exp(-(c + x)/t)*(c + x)^3)/t^4 - (2*a*exp(-(c + x)/t)*(c + x)^2)/t^3];
    case 3
        jaco = [ (exp(-(c + x)/t)*(c + x)^3)/t^3, (3*a*exp(-(c + x)/t)*(c + x)^2)/t^3 - (a*exp(-(c + x)/t)*(c + x)^3)/t^4, (a*exp(-(c + x)/t)*(c + x)^4)/t^5 - (3*a*exp(-(c + x)/t)*(c + x)^3)/t^4];
    case 4
        jaco = [ (exp(-(c + x)/t)*(c + x)^4)/t^4, (4*a*exp(-(c + x)/t)*(c + x)^3)/t^4 - (a*exp(-(c + x)/t)*(c + x)^4)/t^5, (a*exp(-(c + x)/t)*(c + x)^5)/t^6 - (4*a*exp(-(c + x)/t)*(c + x)^4)/t^5];
    case 5
        jaco = [ (exp(-(c + x)/t)*(c + x)^5)/t^5, (5*a*exp(-(c + x)/t)*(c + x)^4)/t^5 - (a*exp(-(c + x)/t)*(c + x)^5)/t^6, (a*exp(-(c + x)/t)*(c + x)^6)/t^7 - (5*a*exp(-(c + x)/t)*(c + x)^5)/t^6];
    case 6
        jaco = [ (exp(-(c + x)/t)*(c + x)^6)/t^6, (6*a*exp(-(c + x)/t)*(c + x)^5)/t^6 - (a*exp(-(c + x)/t)*(c + x)^6)/t^7, (a*exp(-(c + x)/t)*(c + x)^7)/t^8 - (6*a*exp(-(c + x)/t)*(c + x)^6)/t^7];
    case 7
        jaco = [ (exp(-(c + x)/t)*(c + x)^7)/t^7, (7*a*exp(-(c + x)/t)*(c + x)^6)/t^7 - (a*exp(-(c + x)/t)*(c + x)^7)/t^8, (a*exp(-(c + x)/t)*(c + x)^8)/t^9 - (7*a*exp(-(c + x)/t)*(c + x)^7)/t^8];
    case 8
        jaco = [ (exp(-(c + x)/t)*(c + x)^8)/t^8, (8*a*exp(-(c + x)/t)*(c + x)^7)/t^8 - (a*exp(-(c + x)/t)*(c + x)^8)/t^9, (a*exp(-(c + x)/t)*(c + x)^9)/t^10 - (8*a*exp(-(c + x)/t)*(c + x)^8)/t^9];
 
end