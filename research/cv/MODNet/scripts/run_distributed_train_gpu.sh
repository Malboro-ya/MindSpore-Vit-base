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

if [ $# != 3 ]
then
    echo "=============================================================================================================="
    echo "Usage: bash scripts/run_distributed_train_gpu.sh [CONFIG_PATH] [DEVICE_NUM] [CUDA_VISIBLE_DEVICES]"
    echo "Please run the script as: "
    echo "bash scripts/run_distributed_train_gpu.sh [CONFIG_PATH] [DEVICE_NUM] [CUDA_VISIBLE_DEVICES]"
    echo "for example: bash scripts/run_distributed_train_gpu.sh /path/to/config.yml 8 0,1,2,3,4,5,6,7"
    echo "=============================================================================================================="
    exit 1
fi

get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

PATH1=$(get_real_path $1)


if [ ! -f $PATH1 ]
then
    echo "error: PROJECT_PATH=$PATH1 is not a directory"
exit 1
fi

export RANK_SIZE=$2
export DEVICE_NUM=$2
export CUDA_VISIBLE_DEVICES=$3

if [ -d "train_dis" ]; then
    rm -rf ./train_dis
fi
mkdir ./train_dis
cp ./*.py ./train_dis
cp -r ./src ./train_dis
cp -r ./pretrained ./train_dis
cd ./train_dis || exit

env > env.log

echo "start training in $DEVICE_NUM device."

nohup mpirun -n $DEVICE_NUM --output-filename log_output --merge-stderr-to-stdout --allow-run-as-root \
python train.py --config=$PATH1 --distribute=True --device_target='GPU' --output_path='./output_dis' > train.dis_log 2>&1 &

cd ..
