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

"""Evaluation for Tracktor"""

import mindspore as ms
from mindspore import context
from mindspore.common import dtype as mstype
import numpy as np
from tqdm import tqdm

from src.FasterRcnn.faster_rcnn import FeatureExtractorFasterRcnn
from src.FasterRcnn.faster_rcnn import HeadInferenceFasterRcnn
from src.reid import ResNet50_FC512
from src.dataset import MOTSequence
from src.dataset import image_preprocess_fn
from src.model_utils.config import config
from src.tracker_plus_plus import TrackerPlusPlus
from src.tracking_utils import SingleModelFasterRCNN
from src.tracking_utils import evaluate_mot_accums
from src.tracking_utils import get_mot_accum


def main():
    """Run eval"""
    context.set_context(mode=context.GRAPH_MODE, device_target=config.device_target)

    faster_rcnn_head_inference = HeadInferenceFasterRcnn(
        net_config=config,
    )
    if config.device_target == "Ascend":
        faster_rcnn_head_inference.to_float(mstype.float16)
    faster_rcnn_head_inference.set_train(False)

    param_dict = ms.load_checkpoint(config.checkpoint_path)
    ms.load_param_into_net(
        faster_rcnn_head_inference,
        param_dict,
    )
    faster_rcnn_feature_extractor = FeatureExtractorFasterRcnn(
        net_config=config,
    )
    if config.device_target == "Ascend":
        faster_rcnn_feature_extractor.to_float(mstype.float16)
    faster_rcnn_feature_extractor.set_train(False)

    ms.load_param_into_net(
        faster_rcnn_feature_extractor,
        param_dict,
    )
    wrapped_object_detector = SingleModelFasterRCNN(
        feature_extractor=faster_rcnn_feature_extractor,
        inference_head=faster_rcnn_head_inference,
        preprocessing_function=lambda image_data: image_preprocess_fn(image_data, config=config),
    )
    if config.device_target == "Ascend":
        wrapped_object_detector.to_float(mstype.float16)

    reid = ResNet50_FC512(layers=[3, 4, 6, 3], num_classes=751)
    param_dict_reid = ms.load_checkpoint(config.reid_weight)
    ms.load_param_into_net(reid, param_dict_reid)
    reid.set_train(False)

    tracker = TrackerPlusPlus(
        obj_detect=wrapped_object_detector,
        reid_network=reid,
        tracker_cfg=config,
    )

    mot_accums = []
    sequences = config.validation_sequences

    for val_seq in sequences:
        tracker.reset()
        seq_dataset = MOTSequence(
            seq_name=val_seq,
            data_dir=config.mot_dataset_path,
        )

        for blob in tqdm(seq_dataset):
            blob['dets'] = np.expand_dims(blob['dets'], axis=0)
            tracker.step(blob)

        results = tracker.get_results()

        mot_accums.append(get_mot_accum(results, seq_dataset))

    evaluate_mot_accums(mot_accums, sequences, generate_overall=True)


if __name__ == '__main__':
    main()
