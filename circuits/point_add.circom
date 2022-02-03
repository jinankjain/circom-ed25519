pragma circom 2.0.0;

//INCLUDE APPROPRIATE ADD, SUBTRACT AND MULTIPLY TEMPLATES
include "../binary-ops/binmulfast.circom";
include "../binary-ops/binsub.circom";
include "../binary-ops/binadd.circom";
include "../binary-ops/modulus.circom";


template point_add(nBits){

    //Points are represented as tuples (X, Y, Z, T) of extended coordinates, with x = X/Z, y = Y/Z, x*y = T/Z

    var constant_2d[255] = [1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0];
    var i;

    signal input P[4][nBits];
    signal input Q[4][nBits];
    signal output R[4][nBits];

    signal A[255];
    signal B[255];
    signal C[255];
    signal D[255];

    component a_sub_p = BinSub(nBits);
    component a_sub_q = BinSub(nBits);
    component a_mul = BinMulFast(nBits,nBits);
    component a_modulo = ModulusWith25519(2*nBits);

    for(i=0;i<nBits;i++){
        a_sub_p.in[0][i] <== P[1][i];
        a_sub_p.in[1][i] <== P[0][i];
        a_sub_q.in[0][i] <== Q[1][i];
        a_sub_q.in[1][i] <== Q[0][i];
    }

    for(i=0;i<nBits;i++){
        a_mul.in1[i] <== a_sub_p.out[i];
        a_mul.in2[i] <== a_sub_q.out[i];
    }

    for(i=0;i<2*nBits;i++){
        a_modulo.a[i] <== a_mul.out[i];
    }

    for(i=0;i<255;i++){
        A[i] <== a_modulo.out[i];
    }

    component b_add_p = BinAdd(nBits);
    component b_add_q = BinAdd(nBits);
    component b_mul = BinMulFast(nBits+1,nBits+1);
    component b_modulo = ModulusWith25519(2*nBits+2);

    for(i=0;i<nBits;i++){
        b_add_p.in[0][i] <== P[1][i];
        b_add_p.in[1][i] <== P[0][i];
        b_add_q.in[0][i] <== Q[1][i];
        b_add_q.in[1][i] <== Q[0][i];
    }

    for(i=0;i<nBits+1;i++){
        b_mul.in1[i] <== b_add_p.out[i];
        b_mul.in2[i] <== b_add_q.out[i];
    }

    for(i=0;i<2*nBits+2;i++){
        b_modulo.a[i] <== b_mul.out[i];
    }

    for(i=0;i<255;i++){
        B[i] <== b_modulo.out[i];
    }

    component c_mul = BinMulFast(nBits,nBits);
    component c_mul_2d = BinMulFast(255,2*nBits);
    component c_modulo = ModulusWith25519(2*nBits+255);

    for(i=0;i<nBits;i++){
        c_mul.in1[i] <== P[3][i];
        c_mul.in2[i] <== Q[3][i];
    }

    for(i=0;i<255;i++){
        c_mul_2d.in1[i] <== constant_2d[i];
    }

    for(i=0;i<2*nBits;i++){
        c_mul_2d.in2[i] <== c_mul.out[i];
    }

    for(i=0;i<2*nBits+255;i++){
        c_modulo.a[i] <== c_mul_2d.out[i];
    }

    for(i=0;i<255;i++){
        C[i] <== c_modulo.out[i];
    }

    component d_mul = BinMulFast(nBits,nBits);
    component d_modulo = ModulusWith25519(2*nBits+1);

    for(i=0;i<nBits;i++){
        d_mul.in1[i] <== P[2][i];
        d_mul.in2[i] <== Q[2][i];
    }

    d_modulo.a[0] <== 0;

    for(i=1;i<2*nBits+1;i++){
        d_modulo.a[i] <== d_mul.out[i-1];
    }

    for(i=0;i<255;i++){
        D[i] <== d_modulo.out[i];
    }

    component e_sub = BinSub(255);
    component f_sub = BinSub(255);
    component g_add = BinAdd(255);
    component h_add = BinAdd(255);
    
    for(i=0;i<255;i++){
        e_sub.in[0][i] <== B[i];
        e_sub.in[1][i] <== A[i];
        f_sub.in[0][i] <== D[i];
        f_sub.in[1][i] <== C[i];
        g_add.in[0][i] <== D[i];
        g_add.in[1][i] <== C[i];
        h_add.in[0][i] <== B[i];
        h_add.in[1][i] <== A[i];    
    }

    component final_mul1 = BinMulFast(255,255);
    component final_mul2 = BinMulFast(256,256);
    component final_mul3 = BinMulFast(255,256);
    component final_mul4 = BinMulFast(255,256);

    for(i=0;i<255;i++){
        final_mul1.in1[i] <== e_sub.out[i];
        final_mul1.in2[i] <== f_sub.out[i];
        final_mul3.in1[i] <== f_sub.out[i];
        final_mul4.in1[i] <== e_sub.out[i];
    }

    for(i=0;i<256;i++){
        final_mul2.in1[i] <== g_add.out[i];
        final_mul2.in2[i] <== h_add.out[i];
        final_mul3.in2[i] <== g_add.out[i];
        final_mul4.in2[i] <== h_add.out[i];
    }

    component final_modulo1 = ModulusWith25519(510);
    component final_modulo2 = ModulusWith25519(512);
    component final_modulo3 = ModulusWith25519(511);
    component final_modulo4 = ModulusWith25519(511);

    for(i=0;i<510;i++){
        final_modulo1.a[i] <== final_mul1.out[i];
    }

    for(i=0;i<512;i++){
        final_modulo2.a[i] <== final_mul2.out[i];
    }

    for(i=0;i<511;i++){
        final_modulo3.a[i] <== final_mul3.out[i];
        final_modulo4.a[i] <== final_mul4.out[i];
    }
    
    for(i=0;i<255;i++){
        R[0][i] <== final_modulo1.out[i];
        R[1][i] <== final_modulo2.out[i];
        R[2][i] <== final_modulo3.out[i];
        R[3][i] <== final_modulo4.out[i];    
    }

    
}
component main = point_add(255);   
