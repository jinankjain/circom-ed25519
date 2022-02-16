pragma circom 2.0.0;

include "lt.circom";

template adder(n){
    signal input a[n];
    signal input b[n];
    signal psum[n];
    signal carry[n+1];
    signal output sum[n+1];

    for (var i=0; i<n ; i++){
        psum[i] <== a[i] + b[i];
    }
    
    carry[0] <== 0;
    for (var i=0; i<n; i++){
        sum[i] <-- (psum[i]+carry[i])%2251799813685248;
        carry[i+1] <-- (psum[i]+carry[i])\2251799813685248;
        psum[i]+carry[i] === carry[i+1]*2251799813685248 + sum[i];
    }
    sum[n] <== carry[n];

    component lt[n+1];
    for(var i=0; i<n+1; i++) {
        lt[i] = LessThanPower51();
        lt[i].in <== sum[i];
        lt[i].out === 1;
    }
}

template adder_irregular(m,n){ //assume m>=n
    signal input a[m];
    signal input b[n];
    signal psum[m];
    signal carry[m+1];
    signal output sum[m+1];

    for (var i=0; i<n ; i++){
        psum[i] <== a[i] + b[i];
    }
    for (var i=n; i<m ; i++){
        psum[i] <== a[i];
    }
    carry[0] <== 0;
    for (var i=0; i<m; i++){
        sum[i] <-- (psum[i]+carry[i])%2251799813685248;
        carry[i+1] <-- (psum[i]+carry[i])\2251799813685248;
        psum[i]+carry[i] === carry[i+1]*2251799813685248 + sum[i];
    }
    sum[m] <== carry[m];

    component lt[m+1];
    for(var i=0; i<m+1; i++) {
        lt[i] = LessThanPower51();
        lt[i].in <== sum[i];
        lt[i].out === 1;
    }
}