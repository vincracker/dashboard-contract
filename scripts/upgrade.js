const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

const PROXY = "0x631F88cb188cBb3976295c46a2dC3AC869FbF7c4";

async function main() {
  const StormFactoryV2 = await hre.ethers.getContractFactory("StormV2");

  // await upgrades.upgradeProxy(PROXY,StormFactoryV2);
  // console.log("Token upgraded!")

  const instance = StormFactoryV2.attach(PROXY);
  const list = await instance.getFrozenList();
  console.log(list);

}

 main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
