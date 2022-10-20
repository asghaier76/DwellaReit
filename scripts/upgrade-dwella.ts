import { ethers, upgrades } from "hardhat";

async function main() {
  const CONTRACT_ADDRESS = '';
  const DwellaProxyUpgrade = await ethers.getContractFactory("BoxV2");
  const dwellaProxyUpgrade = await upgrades.upgradeProxy(CONTRACT_ADDRESS, DwellaProxyUpgrade);
  console.log("DwellaProxy upgraded to: " + dwellaProxyUpgrade.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
