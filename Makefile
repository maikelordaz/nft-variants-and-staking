-include .env

.PHONY: all test clean install snapshot anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build coverage

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install foundry-rs/forge-std@v1.9.2 --no-commit && forge install OpenZeppelin/openzeppelin-contracts@v5.0.2 --no-commit && forge install dmfxyz/murky --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

coverage :; forge coverage

snapshot :; forge snapshot

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Generate Merkle Tree input file
generate :; forge script script/GenerateInput.s.sol:GenerateInput

# Make Merkle Root and Proofs
makeMerkle :; forge script script/MakeMerkle.s.sol:MakeMerkle