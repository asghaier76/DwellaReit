import { ethers, upgrades } from "hardhat";

async function main() {
//   const currentTimestampInSeconds = Math.round(Date.now() / 1000);
//   const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
//   const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

//   const lockedAmount = ethers.utils.parseEther("1");
  const DR = await ethers.getContractFactory("DR");
  const drProxy = await upgrades.deployProxy(DR, ['0x32f79322A6e0e629f2968145DBb513312bdC4806'], {initializer: "__DR_init"});
  await drProxy.deployed();
  console.log("DR deployed to:", drProxy.address); 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
