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


if [[ $# -lt 3 || $# -gt 4 ]]; then
    echo "Usage: sh run_infer_310.sh [ENCODER_PATH] [DECODER_PATH] [DATA_PATH] [DEVICE_ID]
    DEVICE_ID is optional, it can be set by environment variable device_id, otherwise the value is zero"
exit 1
fi

get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

encoder=$(get_real_path $1)
decoder=$(get_real_path $2)
data_path=$(get_real_path $3)

if [ $# == 4 ]; then
    device_id=$4
elif [ $# == 3 ]; then
    if [ -z $device_id ]; then
        device_id=0
    else
        device_id=$device_id
    fi
fi

if [ ! -f $encoder ]
then 
    echo "error: ENCODER_PATH=$encoder is not a file"
exit 1
fi

if [ ! -f $decoder ]
then 
    echo "error: DECODER_PATH=$decoder is not a file"
exit 1
fi

if [ ! -d $data_path ]
then 
    echo "error: DATA_PATH=$data_path is not a directory"
exit 1
fi

function compile_app()
{
    cd ../ascend310_infer || exit
    if [ -f "Makefile" ]; then
        make clean
    fi
    sh build.sh &> build.log

    if [ $? -ne 0 ]; then
        echo "error: compile app code failed"
        exit 1
    fi
    cd - || exit
}

function infer()
{
    if [ -d result_Files ]; then
        rm -rf ./result_Files
    fi
     if [ -d time_Result ]; then
        rm -rf ./time_Result
    fi
    mkdir result_Files
    mkdir time_Result
    ../ascend310_infer/out/main --encoder_path=$encoder --decoder_path=$decoder --dataset_path=$data_path --device_id=$device_id &> infer.log

    if [ $? -ne 0 ]; then
        echo "error: execute inference failed"
        exit 1
    fi
}

compile_app
infer
python ../cal_metrics.py $data_path result_Files >> infer.log  2>&1