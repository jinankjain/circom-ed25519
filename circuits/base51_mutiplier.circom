pragma circom 2.0.0;

include "../circomlib/circuits/bitify.circom";

/*
input = { //5 elements for base51
    "a" : [284209856297924, 531056621794364, 2126805311019171, 1709636005579803, 945553322657302],
    "b" : [2197108103261836, 1755545702020018, 1199444544775469, 460390194299554, 1429579441107769]
}
*/

template LessThanPower51() {
  signal input in;
  signal output out;

  component n2b = Num2Bits(51+1);

  n2b.in <== in+ (1<<51) - 2251799813685248;

  out <== 1-n2b.out[51];
}

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

    /*
    var carry = 0;
    for (var j=0; j<2*n-1; j++){
        product[j] <-- (sum[j]+carry)%2251799813685248;
        carry = (sum[j]+carry)\2251799813685248;
    }
    product[2*n-1] <-- carry;
    */
    
    carry[0] <== 0;
    for (var j=0; j<2*n-1; j++){
        product[j] <-- (sum[j]+carry[j])%2251799813685248;
        carry[j+1] <-- (sum[j]+carry[j])\2251799813685248;
        sum[j]+carry[j] === carry[j+1]*2251799813685248 + product[j]; //note: removing this line does not change the no of constraints
    }
    product[2*n-1] <-- carry[2*n-1];
    //sum[2*n-1] + carry[2*n-2] === carry[2*n-1]*2251799813685248 + product[2*n-1]; find an alternative here


    component lt[2*n];
    for(var i=0; i<2*n; i++) {
        lt[i] = LessThanPower51();
        lt[i].in <== product[i];
        lt[i].out === 1;
    }
}

template Main(n){
    signal input a[n];
    signal input b[n];
    signal output product[2*n];

    component multiply = multiply(n);
    for (var i=0; i<n; i++){
        multiply.a[i] <== a[i];
        multiply.b[i] <== b[i];
    }
    for (var j=0; j<2*n; j++){
        multiply.product[j] ==> product[j];
    }

}

component main = Main(5);