require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: "0.8.28",
	defaultNetwork: "hardhat",
	networks: {
		hardhat: {
			chainId: 31337,
			forking: {
				url: "https://eth-sepolia.g.alchemy.com/v2/HGqw_avxkO6PIRIbEQkAV6Oqanno3UoZ",
			}
		},
	}
};
