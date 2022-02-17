const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");

const wasm_tester = require("circom_tester").wasm;

describe("base 51 multiplier test",()=>{
    describe("when performing chuncked multiply  on two 200 bits numbers",()=>{
        it("should multiply them correctly", async()=>{
            const cir = wasm_tester(path.join(__dirname,"circuits","mult_irregular_base51.circom"));
            const a = BigInt(2**200)-BigInt(19);
            const b = BigInt(2**200)-BigInt(27);
            const chunk1 = utils.chunkBigInt(a);
            const chunk2 = utils.chunkBigInt(b);

            const witness = await (await cir).calculateWitness({"a":chunk1,"b":chunk2},true);
            const expected = utils.chunkBigInt(a*b);
            
            assert.ok(witness.slice(1,9).every((u, i)=>{
                return u === expected[i];
            }));
        });
    });
});