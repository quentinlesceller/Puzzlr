/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

package main

import (
	"errors"
	"fmt"
	"golang.org/x/crypto/bcrypt"

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
	var username, firsthash string
	var err error

	if len(args) != 2 {
		return nil, errors.New("Incorrect number of arguments. Expecting 2")
	}

	username = args[0]
	firsthash = args[1]

	hash, err := bcrypt.GenerateFromPassword([]byte(firsthash), bcrypt.DefaultCost)
	if err != nil {
		panic(err)
	}

	err = stub.PutState(username, hash)
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
		if function == "delete" {
			return t.delete(stub, args)
		} else {
			return nil, errors.New("Invalid query function name. Expecting \"query\"")
		}
	}
	var username, result string // Entities

	if len(args) == 1 {
		username = args[0]
		// Check if user is registered
		// Get the state from the ledger
		state, err := stub.GetState(username)
		if err != nil {
			jsonResp := "{\"Error\":\"Failed to get state for " + username + "\"}"
			return []byte("isRegisteredFalse"), errors.New(jsonResp)
		} else if state == nil {
			result = "isRegisteredFalse"
		} else {
			result = "isRegisteredTrue"
		}
		return []byte(result), nil

	} else if len(args) == 2 {
		username = args[0]

		// Get the state from the ledger
		dbhashbytes, err := stub.GetState(username)
		if err != nil {
			jsonResp := "{\"Error\":\"Failed to get state for " + username + "\"}"
			return []byte("isRegisteredfalse"), errors.New(jsonResp)
		}

		if dbhashbytes == nil {
			jsonResp := "{\"Error\":\"Nil amount for " + username + "\"}"
			return []byte("isRegisteredfalse"), errors.New(jsonResp)
		}

		return dbhashbytes, nil
	} else {
		return nil, errors.New("Incorrect number of arguments. Expecting 2")
	}

}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
