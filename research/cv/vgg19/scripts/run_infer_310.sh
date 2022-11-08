#!/bin/bash
# Copyright 2021 Huawei Technologies Co., Ltd
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

if [[ $# -lt 4 || $# -gt 5 ]]; then
    echo "Usage: bash run_infer_310.sh [MINDIR_PATH] [DATASET_NAME] [DATASET_PATH] [NEED_PREPROCESS] [DEVICE_ID]
    DATASET_NAME can choose from ['cifar10', 'imagenet2012'].
    NEED_PREPROCESS means weather need preprocess or not, it's value is 'y' or 'n'.
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
model=$(get_real_path $1)
if [ $2 == 'cifar10' ] || [ $2 == 'imagenet2012' ]; then
  dataset_name=$2
else
  echo "DATASET_NAME can choose from ['cifar10', 'imagenet2012']"
  exit 1
fi
config_path=$(get_real_path "../${dataset_name}_config.yaml")
echo "config path is : ${config_path}"

dataset_path=$(get_real_path $3)

if [ "$4" == "y" ] || [ "$4" == "n" ];then
    need_preprocess=$4
else
  echo "weather need preprocess or not, it's value must be in [y, n]"
  exit 1
fi

device_id=0
if [ $# == 5 ]; then
    device_id=$5
fi

echo "mindir name: "$model
echo "dataset name: "$dataset_name
echo "dataset path: "$dataset_path
echo "need preprocess: "$need_preprocess
echo "device id: "$device_id

function preprocess_data()
{
    if [ -d preprocess_Result ]; then
        rm -rf ./preprocess_Result
    fi
    mkdir preprocess_Result
    python ../preprocess.py --config_path=$config_path --dataset=$dataset_name --data_dir=$dataset_path --result_path=./preprocess_Result/
}

function compile_app()
{
    cd ../ascend310_infer/ || exit
    bash build.sh &> build.log
}

function infer()
{
    cd - || exit
    if [ -d result_Files ]; then
        rm -rf ./result_Files
    fi
    if [ -d time_Result ]; then
        rm -rf ./time_Result
    fi
    mkdir result_Files
    mkdir time_Result

    if [ "$dataset_name" == "cifar10" ]; then
        ../ascend310_infer/out/main --mindir_path=$model --dataset_name=$dataset_name --input0_path=./preprocess_Result/00_data --device_id=$device_id  &> infer.log
    else
        ../ascend310_infer/out/main --mindir_path=$model --dataset_name=$dataset_name --input0_path=$dataset_path --device_id=$device_id  &> infer.log
    fi
}

function cal_acc()
{
    if [ "$dataset_name" == "cifar10" ]; then
        python ../postprocess.py --config_path=$config_path --result_dir=./result_Files --label_dir=./preprocess_Result/cifar10_label_ids.npy --dataset_name=$dataset_name  &> acc.log
    else
        python ../postprocess.py --config_path=$config_path --result_dir=./result_Files --label_dir=./preprocess_Result/imagenet_label.json --dataset_name=$dataset_name  &> acc.log
    fi
}

if [ $need_preprocess == "y" ]; then
    preprocess_data
    if [ $? -ne 0 ]; then
        echo "preprocess dataset failed"
        exit 1
    fi
fi
compile_app
if [ $? -ne 0 ]; then
    echo "compile app code failed"
    exit 1
fi
infer
if [ $? -ne 0 ]; then
    echo " execute inference failed"
    exit 1
fi
cal_acc
if [ $? -ne 0 ]; then
    echo "calculate accuracy failed"
    exit 1
fi