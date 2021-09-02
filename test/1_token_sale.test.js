// Helpers
const {expect} = require("chai");
const { BN, expectEvent, expectRevert, constants } = require('@openzeppelin/test-helpers');

// Contracts
const Token = artifacts.require("bsc/tokens/BEP20");
const TokenSale = artifacts.require("bsc/token-sales/TokenSale");

// Start test block
contract('TokenSale', function ([ creator, investor, wallet ]) {

    const NAME = 'SimpleToken';
    const SYMBOL = 'SIMP';
    const TOTAL_SUPPLY = new BN('10000000000000000000000');
    const RATE = new BN(10);
  
    beforeEach(async function () {
      this.token = await Token.new(NAME, SYMBOL, TOTAL_SUPPLY, { from: creator });
      this.tokenSale = await TokenSale.new(RATE, wallet, this.token.address);
      this.token.transfer(this.crowdsale.address, await this.token.totalSupply());
    });
  
    it('should create crowdsale with correct parameters', async function () {
      expect(await this.tokenSale.rate()).to.be.bignumber.equal(RATE);
      expect(await this.tokenSale.wallet()).to.be.equal(wallet);
      expect(await this.tokenSale.token()).to.be.equal(this.token.address);
    });
  
    it('should accept payments', async function () {
      const investmentAmount = ether('1');
      const expectedTokenAmount = RATE.mul(investmentAmount);
  
      await this.tokenSale.buyTokens(investor, { value: investmentAmount, from: investor });
  
      expect(await this.token.balanceOf(investor)).to.be.bignumber.equal(expectedTokenAmount);
    });
  });