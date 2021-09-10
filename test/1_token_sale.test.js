// Helpers
const {expect} = require("chai");
const { BN, ether } = require('@openzeppelin/test-helpers');
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");

// Contracts
const Token = artifacts.require("bsc/tokens/BEP20");
const TokenSale = artifacts.require("bsc/token-sales/TokenSale");

// Start test block
contract('TokenSale', function ([ creator, investor ]) {

    const _name = 'SimpleToken';
    const _symbol = 'SIMP';
    const _supply = new BN(1000000);
    const _rate = new BN(1);
    const _deci = new BN(9);

    beforeEach(async function(){
      this.token = await Token.new(_name, _symbol, _supply, _deci, {from: creator});
      this.tokenSale = await TokenSale.new(_rate, creator, this.token.address, {from: creator});
    });
  
    it('should create crowdsale with correct parameters', async function(){
        
        expect(await this.tokenSale.rate()).to.be.bignumber.equal(_rate);
        expect(await this.tokenSale.wallet()).to.be.equal(creator);
        expect(await this.tokenSale.token()).to.be.equal(this.token.address);
    });
  
    it('should accept payments', async function () {
      const investmentAmount = ether('1');
      const expectedTokenAmount = _rate.mul(investmentAmount);
  
      await this.tokenSale.buyTokens(investor, { value: investmentAmount, from: investor });
  
      expect(await this.token.balanceOf(investor)).to.be.bignumber.equal(expectedTokenAmount);
    });
  });