// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract WeatherContract is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    // Router address - Hardcoded for Sepolia
    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    // donID - Hardcoded for Sepolia
    bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    // JavaScript source code
    string source =
        "let lat = args[0];"
        "let long = args[1];"
        "if (!lat || !long) {"
        "    lat = 46.253;"
        "    long = 20.1482;"
        "}"
        "const apiResponse = await Functions.makeHttpRequest({ url: `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${long}&current=temperature_2m` });"
        "return Functions.encodeUint256(Math.round(apiResponse.data.current.temperature_2m));";

    //Callback gas limit
    uint32 gasLimit = 300000;

    // state variable to store the temperature
    uint256 public temp;

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        uint256 temp,
        bytes response,
        bytes err
    );

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    /**
     * @notice Sends an HTTP request for character information
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    // Request sent to the Chainlink Functions network (Distributed Oracle Network)
    // The Oracle nodes make the HTTP request to the Open Meteo API
    // The response is sent back after consensus is reached

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        s_lastError = err;
        temp = abi.decode(response, (uint256)); // Decode the response to get the temperature

        //! Log the response (hardhat console.log)
        console.log("Temperature: %o", temp);

        // Emit an event to log the response
        emit Response(requestId, temp, s_lastResponse, s_lastError);
    }

    //TODO: remove in production
    function testFulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) external onlyOwner {
        // Közvetlen meghívása a callback függvénynek
        fulfillRequest(requestId, response, err);
    }
}
