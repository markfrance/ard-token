const ARDropToken = artifacts.require("ARDropToken");

module.exports = function(deployer) {
  const _name = "AR Drop";
  const _symbol = "ARD";
  const _decimals = 18;
  const _supply = 100000000;
  deployer.deploy(ARDropToken, _name, _symbol, _decimals, _supply);
};
