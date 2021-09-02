// Helpers
const {expect} = require("chai");
const { BN, expectEvent, expectRevert, constants } = require('@openzeppelin/test-helpers');

// Contracts
const SimpleToken = artifacts.require("bsc/SimpleToken");

contract("SimpleToken", function([creator, other]){
    const _name = "SimpleToken";
    const _symb = "SIMP"
    const _supp = new BN('10000000000000000000000');

    beforeEach(async function(){
        this.token = await SimpleToken.new(_name, _sym, _supp, { from: creator });
    });

    it("Has total supply", async function(){
        // Use large integer comparisons
        expect(await this.token.totalSupply()).to.be.bignumber.equal(_supp);
    });

    it("Has a name", async function(){
        expect(await this.token.name()).to.be.equal(_name);
    });

    it('Has a symbol', async function () {
        expect(await this.token.symbol()).to.be.equal(_symb);
    });

    it('Assigns the initial total supply to the creator', async function () {
        expect(await this.token.balanceOf(creator)).to.be.bignumber.equal(TOTAL_SUPPLY);
    });
});