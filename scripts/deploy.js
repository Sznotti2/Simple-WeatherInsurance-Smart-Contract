async function main() {
	const [deployer] = await ethers.getSigners();
	console.log("Deployer:", deployer.address);

	const WeatherContract = await ethers.getContractFactory("WeatherContract");
	const weatherContract = await WeatherContract.deploy();

	console.log("Contract address:", weatherContract.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
