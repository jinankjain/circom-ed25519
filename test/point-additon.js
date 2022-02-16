const chai = require("chai");
const path = require("path");
const assert = require("assert");
const utils = require("./utils");

const wasm_tester = require("circom_tester").wasm;

describe("Point Addition test on ed25519", ()=>{
    describe("when performing point addition on the EC of 255 bits ",()=>{
        it("should add them correctly ", async() =>{
            const cir = await wasm_tester(path.join(__dirname,"circuits","point-addition.circom"));
            const P = [15112221349535400772501151409588531511454012693041857206046113283949847762202n, 46316835694926478169428394003475163141307993866256225615783033603165251855960n, 1n, 46827403850823179245072216630277197565144205554125654976674165829533817101731n];
            const Q = [15112221349535400772501151409588531511454012693041857206046113283949847762202n, 46316835694926478169428394003475163141307993866256225615783033603165251855960n, 1n, 46827403850823179245072216630277197565144205554125654976674165829533817101731n];

            const padP = [];
            const padQ = [];
            for( let i=0;i<P.length;i++){
                padP.push(utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(P[i]%BigInt(2**255))),255));
                padQ.push(utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(Q[i]%BigInt(2**255))),255));
            } 
           

        
            padP[0].pop();
            padP[1].pop();
            padP[3].pop();
            padQ[0].pop();
            padQ[1].pop();
            padQ[3].pop();
            
            const witness = await cir.calculateWitness({"P":padP,"Q":padQ},true);

            const res  = utils.point_add(P,Q);
            for(let i=0;i<4;i++){
                res[i] = res[i]%BigInt(2**255);
            }
            
            const resBuf = [];
            for(let i=0;i<4;i++){
                resBuf.push(utils.pad(utils.buffer2bits(utils.bigIntToLEBuffer(res[i])),255));
            }

            assert.ok(witness.slice(1, 4).every((u, i)=>{
                for(let i=0;i<255;i++){
                    return u[i] === resBuf[255];
                }
            }));
             
           

            
            

        });
    });
});