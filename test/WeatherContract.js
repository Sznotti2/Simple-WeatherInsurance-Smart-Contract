const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("WeatherContract", function () {
	async function deployWeatherContractFixture() {
		const [owner] = await ethers.getSigners();
		const WeatherContractFactory = await ethers.getContractFactory("WeatherContract");
		const weatherContract = await WeatherContractFactory.deploy();
		return { weatherContract, owner };
	}

	describe("Oracle Callback Simulation", function () {
		it("should update temperature after testFulfillRequest", async function () {
			const { weatherContract } = await loadFixture(deployWeatherContractFixture);

			// Dummy adatok a szimulációhoz:
			const dummyRequestId = await weatherContract.s_lastRequestId();
			const dummyTemp = 25; // Példa: 25°C
			// A dummy hőmérsékletet ABI kódoljuk
			const dummyResponse = new ethers.AbiCoder().encode(["uint256"], [dummyTemp]);
			const dummyError = "0x"; // üres hiba

			// Hívjuk a fejlesztői tesztfüggvényt, ami szimulálja az oracle callback-et
			const tx = await weatherContract.testFulfillRequest(dummyRequestId, dummyResponse, dummyError);
			await tx.wait();

			// Ellenőrizzük, hogy a temp változó frissült
			expect(await weatherContract.temp()).to.equal(dummyTemp);
		});
	});
});
