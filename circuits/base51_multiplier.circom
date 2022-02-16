pragma circom 2.0.0;

include "lt.circom";

/*
input = { //5 elements for base51
    "a" : [284209856297924, 531056621794364, 2126805311019171, 1709636005579803, 945553322657302],
    "b" : [2197108103261836, 1755545702020018, 1199444544775469, 460390194299554, 1429579441107769]
}
*/
/*
template LessThanPower51() {
  signal input in;
  signal output out;

  component n2b = Num2Bits(51+1);
  n2b.in <== in+ (1<<51) - 2251799813685248;
  out <== 1-n2b.out[51];
}*/

template multiply(n){ //base 2**51 multiplier
    signal input a[n];
    signal input b[n];
    signal pp[n][2*n-1];
    signal sum[2*n-1];
    signal carry[2*n];
    signal output product[2*n];

    for (var i=0; i<n; i++){
        for (var j=0; j<2*n-1; j++){
            if (j<i){
                pp[i][j] <== 0;
            }
            else if (j>=i && j<=n-1+i){
                pp[i][j] <== a[j-i]*b[i];
            }
            else {
                pp[i][j] <== 0;
            }
        }
    }

    var vsum = 0;
    for (var j=0; j<2*n-1; j++){
        vsum = 0;
        for (var i=0; i<n; i++){
            vsum = vsum + pp[i][j];
        }
        sum[j] <== vsum;
    }
    
    carry[0] <== 0;
    for (var j=0; j<2*n-1; j++){
        product[j] <-- (sum[j]+carry[j])%2251799813685248;
        carry[j+1] <-- (sum[j]+carry[j])\2251799813685248;
        //!! doubt: why removing this line does not change the no of constraints?
        sum[j]+carry[j] === carry[j+1]*2251799813685248 + product[j];
    }
    product[2*n-1] <== carry[2*n-1];


    component lt[2*n];
    for(var i=0; i<2*n; i++) {
        lt[i] = LessThanPower51();
        lt[i].in <== product[i];
        lt[i].out === 1;
    }
}

template multiply_irregular(m, n){ //base 2**51 irregular multiplier
    signal input a[m];
    signal input b[n];
    signal pp[n][m+n-1];
    signal sum[m+n-1];
    signal carry[m+n];
    signal output product[m+n];

    for (var i=0; i<n; i++){
        for (var j=0; j<m+n-1; j++){
            if (j<i){
                pp[i][j] <== 0;
            }
            else if (j>=i && j<=m-1+i){
                pp[i][j] <== a[j-i]*b[i];
            }
            else {
                pp[i][j] <== 0;
            }
        }
    }

    var vsum = 0;
    for (var j=0; j<m+n-1; j++){
        vsum = 0;
        for (var i=0; i<n; i++){
            vsum = vsum + pp[i][j];
        }
        sum[j] <== vsum;
    }
    
    carry[0] <== 0;
    for (var j=0; j<m+n-1; j++){
        product[j] <-- (sum[j]+carry[j])%2251799813685248;
        carry[j+1] <-- (sum[j]+carry[j])\2251799813685248;
         //!! doubt: why removing this line does not change the number of constraints?
        sum[j]+carry[j] === carry[j+1]*2251799813685248 + product[j];
    }
    product[m+n-1] <== carry[m+n-1];


    component lt[m+n];
    for(var i=0; i<m+n; i++) {
        lt[i] = LessThanPower51();
        lt[i].in <== product[i];
        lt[i].out === 1;
    }
}
