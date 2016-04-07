package main

import (
	"errors"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

// Chaincode Database of Username
type SimpleChaincode struct {
}

func (t *SimpleChaincode) init(stub *shim.ChaincodeStub) ([]byte, error) {
	return nil, nil
}

// Add a new user to the ledger.
func (t *SimpleChaincode) invoke(stub *shim.ChaincodeStub, args []string) ([]byte, error) {
	var username, publickey string
	var err error

	if len(args) != 2 {
		return nil, errors.New("Incorrect number of arguments. Expecting 2")
	}

	username = args[0]
	publickey = args[1]

	err = stub.PutState(username, []byte(publickey))
	if err != nil {
		return nil, err
	}

	return nil, nil
}

// Deletes a user from the ledger.
func (t *SimpleChaincode) delete(stub *shim.ChaincodeStub, args []string) ([]byte, error) {
	if len(args) != 1 {
		return nil, errors.New("Incorrect number of arguments. Expecting 1")
	}

	username := args[0]

	// Delete the key from the state in ledger
	err := stub.DelState(username)
	if err != nil {
		return nil, errors.New("Failed to delete state")
	}

	return nil, nil
}

// Run callback representing the invocation of a chaincode
// This chaincode manage user
func (t *SimpleChaincode) Run(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {

	// Handle different functions
	if function == "init" {
		// Initialize the entities and their asset holdings
		return t.init(stub)
	} else if function == "invoke" {
		// Transaction makes payment of X units from A to B
		return t.invoke(stub, args)
	} else if function == "delete" {
		// Deletes an entity from its state
		return t.delete(stub, args)
	}
	return nil, errors.New("Received unknown function invocation")
}

// Query callback representing the query of a chaincode
func (t *SimpleChaincode) Query(stub *shim.ChaincodeStub, function string, args []string) ([]byte, error) {
	if function != "query" {
		return nil, errors.New("Invalid query function name. Expecting \"query\"")
	}
	var username string // Entities
	var err error

	if len(args) != 1 {
		return nil, errors.New("Incorrect number of arguments. Expecting username to query")
	}

	username = args[0]

	// Get the state from the ledger
	publickeybytes, err := stub.GetState(username)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + username + "\"}"
		return nil, errors.New(jsonResp)
	}

	if publickeybytes == nil {
		jsonResp := "{\"Error\":\"Nil key for " + username + "\"}"
		return nil, errors.New(jsonResp)
	}

	jsonResp := "{\"Name\":\"" + username + "\",\"Amount\":\"" + string(publickeybytes) + "\"}"
	fmt.Printf("Query Response:%s\n", jsonResp)
	return publickeybytes, nil
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
