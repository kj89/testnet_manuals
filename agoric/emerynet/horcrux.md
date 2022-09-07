# Horcrux setup instructions for agoric-emerynet-5 

1. Register validator

2. Save `priv_validator_key.json` localy

3. Set environment variables
```
# Sentry nodes
sentry1_ip=10.0.0.1
sentry2_ip=10.0.0.2
sentry3_ip=10.0.0.3
# Horcrux
horcrux1_ip=10.0.1.1
horcrux2_ip=10.0.1.2
horcrux3_ip=10.0.1.3
# Chain id
chain_id=agoric-emerynet-5
```

4. Update system
```bash
sudo apt update -y && sudo apt upgrade -y
```

5. Install Horcrux binaries
```bash
wget https://github.com/strangelove-ventures/horcrux/releases/download/v2.0.0/horcrux_2.0.0_linux_amd64.tar.gz
tar -xzf horcrux_2.0.0_linux_amd64.tar.gz
sudo mv horcrux /usr/bin/horcrux && rm horcrux_2.0.0_linux_amd64.tar.gz README.md LICENSE.md
```

6. Install service
```bash
sudo wget -O /etc/systemd/system/horcrux.service https://raw.githubusercontent.com/strangelove-ventures/horcrux/v2.0.0/docs/horcrux.service
sudo systemctl daemon-reload
```

7. Link horcrux with sentry nodes
```bash
# link horcrux1 to sentry1
horcrux config init ${chain_id} "tcp://${sentry1_ip}:1234" -c -p "tcp://${horcrux2_ip}:2222|2,tcp://${horcrux3_ip}:2222|3" -l "tcp://${horcrux1_ip}:2222" -t 2 --timeout 1500ms
# link horcrux2 to sentry2
horcrux config init ${chain_id} "tcp://${sentry2_ip}:1234" -c -p "tcp://${horcrux1_ip}:2222|1,tcp://${horcrux3_ip}:2222|3" -l "tcp://${horcrux2_ip}:2222" -t 2 --timeout 1500ms
# link horcrux3 to sentry3
horcrux config init ${chain_id} "tcp://${sentry3_ip}:1234" -c -p "tcp://${horcrux1_ip}:2222|1,tcp://${horcrux2_ip}:2222|2" -l "tcp://${horcrux3_ip}:2222" -t 2 --timeout 1500ms
```

8. Copy `priv_validator_key.json` to horcrux node

8. Split private key
```bash
horcrux create-shares priv_validator_key.json 2 3
```

9. Copy private shares to horcrux nodes

10. Halt your validator node
> **Warning** Dont skip this step!!!
```bash
sudo systemctl stop agoricd
```

11. Supply signer state data horcrux nodes
```bash
cat $HOME/.agoric/data/priv_validator_state.json | jq '. | { height, round: .round | tostring, step }'
```
insert result into:
```
cat <<EOF | tee $HOME/.horcrux/state/${chain_id}_priv_validator_state.json | tee $HOME/.horcrux/state/${chain_id}_share_sign_state.json
{
  "height": "355132",
  "round": "0",
  "step": 3
}
EOF
```

12. Enable and start horcrux service
```bash
sudo systemctl enable horcrux.service
sudo systemctl start horcrux.service
```

13. Reconfigure sentry nodes
```bash
sed -i 's#priv_validator_laddr = ""#priv_validator_laddr = "tcp://0.0.0.0:1234"#g' $HOME/.agoric/config/config.toml
sudo systemctl restart agoricd.service
```
