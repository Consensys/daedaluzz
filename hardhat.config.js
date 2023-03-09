require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        version: "0.8.19",
        settings: {
            optimizer: {
                enabled: false,
                runs: 200
            }
        }
    },
    networks: {
        hardhat: {
            chainId: 1,
            allowUnlimitedContractSize: true,
        },
    },
};