const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

async function main() {
  const StormFactory = await hre.ethers.getContractFactory("StormV2");

  const stromToken = await upgrades.deployProxy(StormFactory);

  console.log("Storm token deployed to", stromToken.address);
}

 main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
