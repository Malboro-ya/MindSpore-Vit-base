#!/bin/bash
# Copyright 2020-2021 Huawei Technologies Co., Ltd
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

if [ $# != 2 ] && [ $# != 3 ]
then
    echo "Usage: bash run_distribute_train.sh [TRAIN_LABEL_FILE] [RANK_TABLE] [PRETRAINED_BACKBONE]"
    echo "   or: bash run_distribute_train.sh [TRAIN_LABEL_FILE] [RANK_TABLE]"
    exit 1
fi

get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

current_exec_path=$(pwd)
echo ${current_exec_path}

dirname_path=$(dirname "$(pwd)")
echo ${dirname_path}

export PYTHONPATH=${dirname_path}:$PYTHONPATH

SCRIPT_NAME='train.py'

rm -rf ${current_exec_path}/device*

ulimit -c unlimited

TRAIN_LABEL_FILE=$(get_real_path $1)
RANK_TABLE=$(get_real_path $2)
PRETRAINED_BACKBONE=''

if [ ! -f $TRAIN_LABEL_FILE ]
then
    echo "error: TRAIN_LABEL_FILE=$TRAIN_LABEL_FILE is not a file"
exit 1
fi

if [ $# == 3 ]
then
    PRETRAINED_BACKBONE=$(get_real_path $3)
    if [ ! -f $PRETRAINED_BACKBONE ]
    then
        echo "error: PRETRAINED_PATH=$PRETRAINED_BACKBONE is not a file"
    exit 1
    fi
fi

echo $TRAIN_LABEL_FILE
echo $RANK_TABLE
echo $PRETRAINED_BACKBONE

export RANK_TABLE_FILE=$RANK_TABLE
export RANK_SIZE=8

echo 'start training'
for((i=0;i<=$RANK_SIZE-1;i++));
do
    echo 'start rank '$i
    mkdir ${current_exec_path}/device$i
    cd ${current_exec_path}/device$i || exit
    export RANK_ID=$i
    dev=`expr $i + 0`
    export DEVICE_ID=$dev
    python ${dirname_path}/${SCRIPT_NAME} \
        --per_batch_size=32 \
        --is_distributed=1 \
        --train_label_file=$TRAIN_LABEL_FILE \
        --pretrained=$PRETRAINED_BACKBONE > train.log  2>&1 &
done

echo 'running'
