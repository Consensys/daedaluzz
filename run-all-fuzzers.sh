#!/bin/sh
rm -rf echidna-tmp
mkdir echidna-tmp
rm -rf foundry-tmp
mkdir foundry-tmp
rm -rf hybrid-echidna-tmp
mkdir hybrid-echidna-tmp
docker pull ghcr.io/crytic/echidna/echidna:v2.1.0
docker pull ghcr.io/foundry-rs/foundry@sha256:26452355c76ae359af672261fdc3b83c77792c40df5b68adbde1a87c144351ea
docker pull ghcr.io/crytic/echidna/echidna:v2.0.4
docker build --rm -t "hybrid-echidna:v0.0.2" -f Dockerfile.optik .
# rm -rf optic-tmp
# git clone https://github.com/crytic/optik.git optic-tmp
# cd optic-tmp
# git checkout v0.0.2
# git apply ../optik-dockerfile.patch
# docker build --rm -t "hybrid-echidna:v0.0.2" -f Dockerfile .
# cd ..
python3 run-campaigns.py --fuzzer-name harvey
python3 run-campaigns.py --fuzzer-name echidna
python3 run-campaigns.py --fuzzer-name foundry
python3 run-campaigns.py --fuzzer-name hybrid-echidna
