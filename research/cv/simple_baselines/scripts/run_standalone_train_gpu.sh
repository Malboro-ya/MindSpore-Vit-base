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

if [ $# -ne 1 ]; then
    echo "Please run the script as: "
    echo "bash scripts/run_standalone_train_gpu.sh [DEVICE_ID]"
    echo "For example: bash scripts/run_standalone_train_gpu.sh 0"
    echo "It is better to use the absolute path."
    echo "========================================================================"
    exit 1
fi

export RANK_SIZE=1
export DEVICE_ID=$1

rm -rf train$1
mkdir ./train$1
cp ./*.py ./train$1
cp -r ./src ./train$1
cd ./train$1 || exit

echo "start training on GPU device $DEVICE_ID"
env > env.log

python train.py \
    --device_target="GPU" \
    --device_id=$DEVICE_ID \
    --is_model_arts=False \
    --run_distribute=False > train.log 2>&1 &

cd ..
