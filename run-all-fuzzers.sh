#!/bin/sh
rm -rf echidna-tmp
mkdir echidna-tmp
rm -rf foundry-tmp
mkdir foundry-tmp
rm -rf hybrid-echidna-tmp
mkdir hybrid-echidna-tmp
docker pull ghcr.io/crytic/echidna/echidna:v2.1.1
docker pull ghcr.io/foundry-rs/foundry@sha256:e3ba202249cccdffafc0d0e90c43baca8f03e4b0d7e273c0d33b8a5e3cea1eb7
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
