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

      this.token.transfer(this.tokenSale.address, new BN(500000));
    });
  
    it('should create crowdsale with correct parameters', async function(){
        expect(await this.tokenSale.rate()).to.be.bignumber.equal(_rate);
        expect(await this.tokenSale.wallet()).to.be.equal(creator);
        expect(await this.tokenSale.token()).to.be.equal(this.token.address);
        expect(await this.token.balanceOf(this.tokenSale.address)).to.be.bignumber.equal(new BN(500000));
    });
  
    it('should accept payments', async function () {
      const investmentAmount = ether('.01');
      console.log(investmentAmount.toString());
      const expectedTokenAmount = investmentAmount.mul(_rate).div(new BN(10**15));

      console.log(_rate.toString());
      console.log(expectedTokenAmount.toString());

      let creatorBalance = await this.token.balanceOf(creator);
      console.log(creatorBalance.toString());
      let contractBalance = await this.token.balanceOf(this.tokenSale.address);
      console.log(contractBalance.toString());
  
      await this.tokenSale.buyTokens(investor, { value: investmentAmount, from: investor });
  
      expect(await this.token.balanceOf(investor)).to.be.bignumber.equal(expectedTokenAmount);
    });
  });