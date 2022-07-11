require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-etherscan')
require("dotenv").config()


const RINKEBY_RPC_URL =
    process.env.RINKEBY_RPC_URL || "https://eth-rinkeby.alchemyapi.io/v2/your-api-key"

const PRIVATE_KEY = process.env.PRIVATE_KEY

module.exports = {

  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },

    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      saveDeployments: true,
      chainId: 4,
    },
  },
  etherscan:{
    apiKey:process.env.API_KEY
  },
  solidity: "0.8.9",
};
