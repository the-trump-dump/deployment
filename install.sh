#!/usr/bin/env bash 
NS=ttd
source $HOME/Desktop/${NS}-deployment/${NS}-env.sh
echo "Installing The Trump Dump system"
OD=$TMPDIR/helm 
mkdir -p $OD 
rm -rf $OD 
git clone https://github.com/this-week-in/helm-chart.git $OD
cd $OD 
./install.sh
rm -rf $OD 

# ttd-feed-mappings.json
# ttd-twitter-mappings.json