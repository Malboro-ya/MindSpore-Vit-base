#!/bin/bash
# Copyright 2022 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

get_real_path() {
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

if [ $# != 3 ]
then
    echo "=============================================================================================================="
    echo "Usage: bash scripts/run_distribute_ascend_train.sh [RANK_TABLE_FILE] [DATASET] [CONFIG_PATH]"
    echo "Please run the script as: "
    echo "bash scripts/run_distribute_ascend_train.sh [RANK_TABLE_FILE] [DATASET] [CONFIG_PATH]"
    echo "for example: bash run_distribute_ascend_train.sh /absolute/path/to/RANK_TABLE_FILE /absolute/path/to/data /absolute/path/to/config"
    echo "=============================================================================================================="
    exit 1
fi
PROJECT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
export HCCL_CONNECT_TIMEOUT=600
export RANK_SIZE=8
DATASET=$(get_real_path $2)
CONFIG_PATH=$(get_real_path $3)
RANK_TABLE=$(get_real_path $1)
export RANK_TABLE_FILE=$RANK_TABLE
for((i=0;i<RANK_SIZE;i++))
do
    rm -rf LOG$i
    mkdir ./LOG$i
    cp ./*.py ./LOG$i
    cp -r ./src ./LOG$i
    cd ./LOG$i || exit
    export RANK_SIZE=8
    export RANK_ID=$i
    export DEVICE_ID=$i
    echo "start training for rank $i, device $DEVICE_ID"
    env > env.log
    mkdir "./output"
    python ${PROJECT_DIR}/../train.py \
    --data_path=$DATASET \
    --config_path=$CONFIG_PATH \
    --output_path './output' \
    --run_distribute=True > log.txt 2>&1 &

    cd ../
done
