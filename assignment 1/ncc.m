%define ncc function (normalized cross-corelation)
%PRECONDITION: images must be of equal size
function y = ncc(A, B)    
    C = normxcorr2(A, B);
    y = mean2(C);
end