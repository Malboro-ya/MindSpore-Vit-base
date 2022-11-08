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
"""export net together with checkpoint into air/mindir/onnx models"""
import os
import argparse
import numpy as np
from mindspore import Tensor, context, load_checkpoint, load_param_into_net, export
import src.model as wdsr

parser = argparse.ArgumentParser(description='wdsr export')
parser.add_argument("--batch_size", type=int, default=1, help="batch size")
parser.add_argument("--ckpt_path", type=str, required=True, help="path of checkpoint file")
parser.add_argument("--file_name", type=str, default="wdsr", help="output file name.")
parser.add_argument("--file_format", type=str, default="MINDIR", choices=['MINDIR', 'AIR', 'ONNX'], help="file format")
parser.add_argument('--n_resblocks', type=int, default=16, help='number of residual blocks')
parser.add_argument('--scale', type=int, default=2, help='super resolution scale')
parser.add_argument('--n_feats', type=int, default=64, help='number of feature maps')
args = parser.parse_args()

def run_export(args1):
    """run_export"""
    device_id = int(os.getenv("DEVICE_ID", '0'))
    context.set_context(mode=context.GRAPH_MODE, device_target="Ascend", device_id=device_id)
    net = wdsr.WDSR(scale=args.scale, n_resblocks=args.n_resblocks, n_feats=args.n_feats)
    param_dict = load_checkpoint(args1.ckpt_path)
    load_param_into_net(net, param_dict)
    net.set_train(False)
    print('load mindspore net and checkpoint successfully.')
    inputs = Tensor(np.zeros([args1.batch_size, 3, 1020, 1020], np.float32))
    export(net, inputs, file_name=args.file_name, file_format=args.file_format)
    print('export successfully!')

if __name__ == "__main__":
    run_export(args)
