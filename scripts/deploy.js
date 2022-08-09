const hre = require("hardhat");

async function main() {

  const partNFT = await hre.ethers.getContractFactory("FranctionalNFT");
  const FranctionalNFT = await partNFT.deploy();
  await FranctionalNFT.deployed();
  console.log("FranctionalNFT deployed to:", FranctionalNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log("This is error");
    console.error(error);
    process.exit(1);
  });