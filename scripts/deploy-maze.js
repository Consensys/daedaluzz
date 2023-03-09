const hre = require("hardhat");

async function main() {
    const maze = await hre.ethers.getContractFactory("Maze");
    const contract = await maze.deploy();
    const deployedContract = await contract.deployed();
    console.log(
        `Deployed at: ${contract.address}`
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});