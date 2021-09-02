// Helpers
const {expect} = require("chai");
const { BN, expectEvent, expectRevert, constants } = require('@openzeppelin/test-helpers');

// Contracts
const SimpleToken = artifacts.require("bsc/SimpleToken");
const TokenSale = artifacts.require("bsc/TokenSale");

// Start test block
contract('TokenSale', function ([ creator, investor, wallet ]) {

    const NAME = 'SimpleToken';
    const SYMBOL = 'SIMP';
    const TOTAL_SUPPLY = new BN('10000000000000000000000');
    const RATE = new BN(10);
  
    beforeEach(async function () {
      this.token = await SimpleToken.new(NAME, SYMBOL, TOTAL_SUPPLY, { from: creator });
      this.crowdsale = await SimpleCrowdsale.new(RATE, wallet, this.token.address);
      this.token.transfer(this.crowdsale.address, await this.token.totalSupply());
    });
  
    it('should create crowdsale with correct parameters', async function () {
      expect(await this.crowdsale.rate()).to.be.bignumber.equal(RATE);
      expect(await this.crowdsale.wallet()).to.be.equal(wallet);
      expect(await this.crowdsale.token()).to.be.equal(this.token.address);
    });
  
    it('should accept payments', async function () {
      const investmentAmount = ether('1');
      const expectedTokenAmount = RATE.mul(investmentAmount);
  
      await this.crowdsale.buyTokens(investor, { value: investmentAmount, from: investor });
  
      expect(await this.token.balanceOf(investor)).to.be.bignumber.equal(expectedTokenAmount);
    });
  });