//! Currently this does nothing, but it is a template for a script that can be run in the Chainlink Functions environment.

// Retrive latitude and longitude from arguments
let lat = args[0];
let long = args[1];

// Check if one of them is missing
if (!lat || !long) {
    console.log("Latitude or longitude is missing, using defaults.")
    // Szeged
    lat = 46.253;
    long = 20.1482;
}

// Make an HTTP request to Open-Meteo API
const apiResponse = await Functions.makeHttpRequest({
    url: `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${long}&current=temperature_2m`
});

// Check error
if (apiResponse.error) {
    console.log("Error with API call");
    throw new Error("Request failed");
}

// Extract the temperature data
let temperature = apiResponse.data.current.temperature_2m;
// log the results
console.log(temperature);

// Return the temperature rounded and encoded as uint256
return Functions.encodeUint256(Math.round(temperature));
