<p style="font-size:14px" align="right">
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
<a href="https://discord.gg/EY35ZzXY" target="_blank">Join our discord <img src="https://user-images.githubusercontent.com/50621007/176236430-53b0f4de-41ff-41f7-92a1-4233890a90c8.png" width="30"/></a>
<a href="https://kjnodes.com/" target="_blank">Visit our website <img src="https://user-images.githubusercontent.com/50621007/168689709-7e537ca6-b6b8-4adc-9bd0-186ea4ea4aed.png" width="30"/></a>
</p>

<p style="font-size:14px" align="right">
<a href="https://hetzner.cloud/?ref=y8pQKS2nNy7i" target="_blank">Deploy your VPS using our referral link to get 20€ bonus <img src="https://user-images.githubusercontent.com/50621007/174612278-11716b2a-d662-487e-8085-3686278dd869.png" width="30"/></a>
</p>

<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/176226900-aae9149d-a186-4fd5-a9aa-fc3ce8b082b3.png">
</p>

# How to transfer tokens between Ethereum and substrate wallets

## Create Polkadot.js wallet
To create polkadot wallet:
1. Download and install [Browser Extension](https://polkadot.js.org/extension/)
2. Navigate to [Peaq Explorer](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/accounts) and press `Add account` button
3. Save `mnemonic` and create wallet
4. This will generate wallet address that you will have to use later. Example of wallet address: `5HTBxt66esFrqyFDraQvxWuiHfPbS5t6FLLTPEN37sZu6T5A`

## Create an Ethereum wallet on Agung (peaq Testnet)
1. Download and install [Metamask Browser Extension](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en)
2. After adding the MetaMask plugin, connectivity needs to established with Agung network by adding:
- Network Name: PEAQ
- RPC endpoint: ​https://erpc.agung.peaq.network/
- Chain ID: 9999
- Currency Symbol: AGNG

![3](https://user-images.githubusercontent.com/50621007/176243099-129b9b0f-e037-4c15-b490-dea491b8a379.png)

3. Once connected with Agung network, the details of the wallet address are seen.

![3](https://user-images.githubusercontent.com/50621007/176243535-fe5f2557-d3dc-4651-8220-a507f56cc323.png)

4. You send your AGNG tokens now.

![image](https://user-images.githubusercontent.com/50621007/176243606-2ee867ee-f2b0-4c9b-a63d-7b64d4fd3a74.png)

## Fund your polkadot wallet
To top up your wallet join [peaq discord server](https://discord.gg/6tTJH7QT) and navigate to:
- **#agung-faucet** for AGNG tokens

To request a faucet grant:
```
!send <YOUR_WALLET_ADDRESS>
```

## Deposit tokens from a Substrate Wallet to an ETH wallet on Agung (peaq Testnet)
### Generate your deposit address
1. Copy your ETH address (Public Key)
2. Use [this website](https://hoonsubin.github.io/evm-substrate-address-converter/index.html) to calculate your deposit address for Substrate.
3. Change the address scheme to "H160".
4. Leave the "Change address prefix" at "5".
5. Enter your ETH address (Public Key) into the "Input address" field.
6. Copy the lower address which represents your deposit address.  

![image](https://user-images.githubusercontent.com/50621007/176244218-81e688ad-05d2-471f-ab3d-962fafa28059.png)

![image](https://user-images.githubusercontent.com/50621007/176244307-6169cc47-b41e-4599-83e6-a70e1dcf936f.png)

### Transfer Tokens 
1. Go to [polkadot.js](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/accounts)
2. Select the account you want to transfer funds from and click "send":

![image](https://user-images.githubusercontent.com/50621007/176244892-d1c5e1cc-27fd-4cab-a8df-f138a3f63cbe.png)

3. Enter your generated deposit address in the "send to address" field:

![image](https://user-images.githubusercontent.com/50621007/176245009-7fbded77-8365-41f0-8001-8909705dd704.png)

4. Enter the amount you want to transfer. 
5. Click the "Make transfer" button.
6. Click the "Sign and Submit" button.
7. Check the balance on your Ethereum (Metamask) Wallet.

![image](https://user-images.githubusercontent.com/50621007/176245132-a72f7bb6-4c83-488e-9de9-94a81e0dd19f.png)

You have successfully transferred Tokens from your Substarte Wallet to your Ethereum Wallet. 

## Withdraw tokens from an ETH Wallet to a Substrate wallet on Agung (peaq Testnet)
### Generate your deposit address
1. Copy your Substrate address (Public Key)

![image](https://user-images.githubusercontent.com/50621007/176245757-c808713d-0c06-4191-9053-718da5bfd824.png)

2. Use [this website](https://www.shawntabrizi.com/substrate-js-utilities/) to calculate your withdrawal address for Substrate. \
Paste your (1) Substrate address under the AccountId to Hex text input. \
Copy the first 42 characters from the converted result, or 40 characters with exception of the "0x"

![image](https://user-images.githubusercontent.com/50621007/176245925-a139e0b3-882d-4046-bc2c-145f05c6017c.png)

3. Send AGNG from your ETH wallet to this recent copied ETH address

<img src="https://user-images.githubusercontent.com/50621007/176246164-d6283c56-525d-4c17-84c3-27b5b5293337.png" alt="drawing" width="300"/>

4. Approve and sign the transaction. Pay the calculated gas for this transaction.

<img src="https://user-images.githubusercontent.com/50621007/176246252-9d5d21f0-c526-4a6d-aabb-c40ddbdc9ac5.png" alt="drawing" width="300"/>

Your transaction is on its way. After a few seconds you should have it completed.

<img src="https://user-images.githubusercontent.com/50621007/176246300-44404b3f-f518-4699-bbc3-edf91b5a3adc.png" alt="drawing" width="300"/>

5. Go to the [Polkadot js Extrinsicts page](https://polkadot.js.org/apps/?rpc=wss%3A%2F%2Fwss.agung.peaq.network#/extrinsics)

![image](https://user-images.githubusercontent.com/50621007/176246463-69c64242-cdbe-46ef-86c2-824043df2a11.png)

6. Complete the form to call an Extrinsics, like the following example:
- Using the selected account: Who is paying fees for the transaction? in this case could be your own Substrate address (if you have balance), or any of the development test accounts, like ALICE or FERDI.
- submit the following extrinsic: select evm
- source: H160: the ETH address which we recently send AGNG (0xd6fbaf5f0eafd5b1fe6911930c925f1ce4ae7363)
- value (BalanceOF): how many AGNG will I retrieve from the Extrinsic. In this case .2 AGNG = 2 + 17 zeros or 1 AGNG = 1000000000000000000 (+ 18 zeros)

![image](https://user-images.githubusercontent.com/50621007/176246599-ac5dcf87-ef1f-44ff-bb28-7950f90426b8.png)

7. Sing the transaction. Wait a few seconds for a confirmation. Your AGNG should arrive to your account.

![image](https://user-images.githubusercontent.com/50621007/176246653-f01ff9fa-3dfb-48ee-b332-b9e3f7e3f581.png)

You have successfully transferred Tokens from your ETH Wallet to your Substrate Wallet. 