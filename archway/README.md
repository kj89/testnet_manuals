# Generate gentx for torii-1 incentivized testnet
```
wget -O torii_gentx.sh https://raw.githubusercontent.com/kj89/testnet_manuals/main/archway/torii_gentx.sh && chmod +x torii_gentx.sh && ./torii_gentx.sh
```

Things you have to backup:
- wallet `24 word mnemonic` generated in output
- contents of `$HOME/.archway/config/`"

# Submit your Run a Genesis Validator task into Incentivized Testnet form
First of all you will need to build `testnet-signer` utility. This utility generates a signed JSON-formatted ID to prove ownership of a key used to submit tx on the blockchain.
```
git clone https://github.com/archway-network/testnet-signer.git
cd testnet-signer
make install
```

## Generate a signed JSON-formatted ID

### Description
1. Generates the required signed id message to submit in the testnet challenge form. Be sure to provide accurate details.
```
testnet-signer sign_id $WALLET
```

2. Fill out your KYC information, here is an example
```shell
% testnet-signer sign_id $WALLET
Enter information as accurately as possible. Information entered here must match your KYC.
Your full legal name:FirstName MiddleName LastName
Your GitHub handle:mygithub
Your email address:myemail@domain.com
Your incentivized testnet address is:  archway1lf26gv87sxvkj59e3f9q2fh6q8phqwgje6g3xg
Amino encoded Public key is: 61rphyEDtd8YCbk465UwocPsEcaSNn3IHx7zUa7tUdoAOuy/iyw=
Submit JSON below the line in the form.
-----------------------------
{
  "id": {
    "full_legal_name": "FirstName MiddleName LastName",
    "github_handle": "mygithub",
    "email_address": "myemail@domain.com",
    "account_address": "archway1lf26gv87sxvkj59e3f9q2fh6q8phqwgje6g3xg",
    "pub_key": "61rphyEDtd8YCbk465UwocPsEcaSNn3IHx7zUa7tUdoAOuy/iyw="
  },
  "signature": "Fnsuzh71v9FJtaz6hdRWsKstGeE1mexEClq67OPuzaZdBKmurXo8P6Himu69mmEsCcz+YGtQV/204XSX0lmnMQ=="
}
```

## Submit your `Run a Genesis Validator` task into Torii Testnet Challenges form
1. Navigate to [Torii Testnet Challenges Form](https://docs.google.com/forms/d/e/1FAIpQLScAWscjXibUoBoyua7GLSUFIfhhWGRoRAgLHsSfQHejPyMSgQ/viewform)
2. Fill out your KYC information you provided in step 2.
3. Select challenge `Run a Genesis Validator`
4. Paste output from `testnet-signer` into `Paste ID JSON here` field and submit the form
