pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";

template LessThanPower(base) {
  signal input in;
  signal output out;

  out <-- 1 - ((in >> base) > 0);
  out * (out - 1) === 0;
}

template LessThanPower51() {
  signal input in;
  signal output out;

  out <-- 1 - ((in >> 51) > 0);
  out * (out - 1) === 0;
}

template LessThanPower52() {
  signal input in;
  signal output out;

  out <-- 1 - ((in >> 52) > 0);
  out * (out - 1) === 0;
}

template LessThanOptimizedUpto51Bits() {
  signal input in[2];
  signal output out;

  component lt1 = LessThanPower51();
  lt1.in <== in[0];

  component lt2 = LessThanPower51();
  lt2.in <== in[1];

  out <-- in[0] < in[1];
  out * (out - 1) === 0;
}

template LessThanOptimizedUpto52Bits() {
  signal input in[2];
  signal output out;

  component lt1 = LessThanPower52();
  lt1.in <== in[0];

  component lt2 = LessThanPower52();
  lt2.in <== in[1];

  out <-- in[0] < in[1];
  out * (out - 1) === 0;
}
