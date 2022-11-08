<TOC>

# DDAG: Dynamic Dual-Attentive Aggregation Learning for Visible-Infrared Person Re-Identification

Mindspore implementation for ***\*****Dynamic Dual-Attentive Aggregation Learning for Visible-Infrared Person Re-Identification*****\*** in ECCV 2020. Please read the [original paper](https://arxiv.org/pdf/2007.09314.pdf)  or original [pytorch implementation](https://github.com/mangye16/DDAG) for a more detailed description of the training procedure.

## Model Architecture

![DDAG Structure](https://s2.loli.net/2021/12/10/JXHkRZluAbWpSiI.png)

## Dataset

### Preparation

(1) SYSU-MM01 Dataset [1]: The SYSU-MM01 dataset can be downloaded from this [website](https://github.com/wuancong/SYSU-MM01).

**run `python pre_process_sysu.py`(in `DDAG_mindspore/third_party/pre_process_sysu.py`) in to prepare the dataset, the training data will be stored in ".npy" format.**

(2) RegDB Dataset [2]: The RegDB dataset can be downloaded from this [website](http://dm.dongguk.edu/link.html) by submitting a copyright form.

(Named: "Dongguk Body-based Person Recognition Database (DBPerson-Recog-DB1)" on their website).

If you have problems for acquiring data, please contact: zhangzw12319@163.com.

### Recommended Dataset Organization(Example)

```
dataset
├──sysu                                     # SYSU-MM01 dataset
│  ├── cam1
│  ├── cam2
│  ├── cam3
│  ├── cam4
│  ├── cam5
│  ├── cam6
│  ├── exp
│  │   ├── available_id.mat
│  │   ├── available_id.txt
│  │   ├── test_id.mat
│  │   ├── test_id.txt
│  │   ├── train_id.mat
│  │   ├── train_id.txt
│  │   ├── val_id.mat
│  │   └── val_id.txt
│  ├── train_ir_resized_img.npy             # The following .npy files are generated by pre_process_sysu.py
│  ├── train_ir_resized_label.npy
│  ├── train_rgb_resized_img.npy
│  └── train_rgb_resized_label.npy
└── regdb                                   # RegDB Dataset
   ├── idx
   ├── Thermal
   └── Visible

```

Then you can set `--data-path Your own path/dataset/sysu` or `--data-path Your own path/dataset/regdb` according to above dataset structure. It's OK if you want to customize your data path.  But please note that the important thing is to set path to the folder which directly contains `cam X` etc. directories and ensures `.npy` files also inside(for SYSU-MM01), or to the folder which directly contains `idx` etc. directories(for RegDB).

## Environment Requirements

* Hardware
   * Support Ascend and GPU environment.
   * For Ascend: Ascend 910.
   * For GPU: cuda==10.1.
* Framework
   * Mindspore=1.5.0(See [Installation](https://www.mindspore.cn/install/))
- Third Package
   * Python==3.7.5
   * Cuda==10.1
   * psutil==5.8.0
   * tqdm==4.56.0

*Note: these third party package are not stricted a specific version. For more details, please see `requriements.txt`.

## Quick Start
For GPU:

```shell
cd DDAG_mindspore/scripts/ # please enter this path before bash XXX.sh, otherwise path errors :)
bash run_standalone_train_sysu_all_gpu.sh
```

or

For Ascend:

```shell
cd DDAG_mindspore/scripts/ # please enter this path before bash XXX.sh, otherwise path errors :)
bash run_standalone_train_sysu_all_ascend.sh
```

## Pretrain Checkpoint File

`--pretrain` parameter allows you to specify resnet50 checkpoint for pretrain backbone, while `--resume` parameter allows you to specify to previously saved whole network checkpoints to resume training.

We use `/model_zoo/r1.1/resnet50_ascend_v111_imagenet2012_official_cv_bs32_acc76` pretrain file, and the file [link](https://download.mindspore.cn/model_zoo/r1.1/resnet50_ascend_v111_imagenet2012_official_cv_bs32_acc76/).

For convenience, you can rename it as `resnet50.ckpt` and save it directly under `MVD/`, then you can leave `--pretrain resnet50.ckpt` unchanged.

## Script Description

### Scripts and Sample Code

```
DDAG_mindspore
├── eval.py
├── README.md
├── requirements.txt
├── scripts
│   ├── run_eval_regdb_i2v_ascend.sh                     # Inference: RegDB dataset infrared to visible on Ascend
│   ├── run_eval_regdb_i2v_gpu.sh                        # Inference: RegDB dataset infrared to visible on GPU
│   ├── run_eval_regdb_v2i_ascend.sh                     # Inference: RegDB dataset visible to infrared on Ascend
│   ├── run_eval_regdb_v2i_gpu.sh                        # Inference: RegDB dataset visible to infrared on GPU
│   ├── run_eval_sysu_all_ascend.sh                      # Inference: SYSU-MM01 dataset all search on Ascend
│   ├── run_eval_sysu_all_gpu.sh                         # Inference: SYSU-MM01 dataset all search on GPU
│   ├── run_eval_sysu_indoor_ascend.sh                   # Inference: SYSU-MM01 dataset indoor search on Ascend
│   ├── run_eval_sysu_indoor_gpu.sh                      # Inference: SYSU-MM01 dataset indoor search on GPU
│   ├── run_standalone_train_regdb_i2v_ascend.sh         # Training: RegDB dataset infrared to visible on Ascend
│   ├── run_standalone_train_regdb_i2v_gpu.sh            # Training: RegDB dataset infrared to visible on GPU
│   ├── run_standalone_train_regdb_v2i_ascend.sh         # Training: RegDB dataset visible to infrared on Ascend
│   ├── run_standalone_train_regdb_v2i_gpu.sh            # Training: RegDB dataset visible to infrared on GPU
│   ├── run_standalone_train_sysu_all_ascend.sh          # Training: SYSU-MM01 dataset all search on Ascend
│   ├── run_standalone_train_sysu_all_gpu.sh             # Training: SYSU-MM01 dataset all search on GPU
│   ├── run_standalone_train_sysu_indoor_ascend.sh       # Training: SYSU-MM01 dataset indoor search on Ascend
│   └── run_standalone_train_sysu_indoor_gpu.sh          # Training: SYSU-MM01 dataset indoor search on GPU
├── src
│   ├── dataset.py                                       # class and functions for Mindspore dataset
│   ├── evalfunc.py                                      # for evaluation functions
│   ├── loss.py                                          # loss functions
│   ├── models                                           # network architecture
│   │   ├── attention.py                                 # Part weight attention and Graph attention
│   │   ├── ddag.py                                      # main model
│   │   ├── resnet.py
│   │   └── trainingcell.py                              # combine loss function, optimizer with network architecture
│   └── utils.py
├── third_party
│   └── pre_process_sysu.py                              # preprocess SYSU-MM01 dataset to generate .npy format files
└── train.py
```

### Script Parameters(Example)

```shell
# train_sysu_all_part_graph.sh as an example
myfile="train_sysu_all_part_graph.sh"

if [ ! -f "$myfile" ]; then
    echo "Please first enter DDAG_mindspore/scripts/run_standalone_train and run. Exit..."
    exit 0
fi

cd ../..

python train.py \
--MSmode "GRAPH_MODE" \
--dataset SYSU \
--optim adam \
--lr 0.0035 \
--device-id 1 \ # for GPU, --gpu 1
--device-target Ascend \ # for GPU, --device-target GPU
--pretrain "resnet50.ckpt" \
--tag "sysu_all_part_graph" \
--data-path "Your own path/sysu" \
--loss-func "id+tri" \
--branch main \
--sysu-mode "all" \
--part 3 \
--graph \
--epoch 40
```

The following table describes the most commonly used arguments. You can change freely as you want.

| Config Arguments  |                         Explanation                          |
| :---------------: | :----------------------------------------------------------: |
|    `--MSmode`     | Mindspore running mode, either 'GRAPH_MODE' or 'PYNATIVE_MODE'. |
| `--device-target` |              choose "GPU", "Ascend" or "Cloud"               |
|    `--dataset`    |              which dataset, "SYSU" or "RegDB".               |
|      `--gpu`      | which gpu to run(default: 0), only effective when `--device-target GPU` |
|   `--device-id`   | which Ascend AI core to run(default:0), only effective when `--device-target Ascend ` |
|   `--data-path`   | manually define the data path(for `SYSU`, path folder must contain `.npy` files, see [`pre_process_sysu.py`](#anchor1) ). |
|   `--pretrain`    | specify resnet-50 pretrain file path(default "" for no ckpt file)* |
|    `--resume`     | specify checkpoint file path for whole model(default "" for no ckpt file, `--resume` loads weights after `--pretrain`, and thus will overwrite `--pretrain` weights)* |
|   `--sysu-mode`   | choose from `["all", "indoor"]`, only effective when `args.dataset=SYSU ` |
|  `--regdb-mode`   | choose from `["i2v", "v2i"]`, only effective when `args.dataset=RegDB` |
|  `--save-period`  | specify  every XXX epochs to save network weights into checkpoint files |
|     `--part`      | if set`--part X` , then use local part attention module with part number X; if you don't want to use this module, you can set `--part 0` |

***Note: Please note that mindspore compulsorily requires checkpoint files have `.cpkt` as file suffix, otherwise may trigger errors during loading.**

We recommend that these following hyper-parameters in `.sh` files should be kept by default. If you want ablation study or fine-tuning, feel free to change :)

| Config Arguments |                         Explanation                          |
| :--------------: | :----------------------------------------------------------: |
|    `--optim`     |             choose "adam" or "sgd"(default adam)             |
|      `--lr`      |     initial learning rate( 0.0035 for adam, 0.1 for sgd)     |
|     `--tags`     | (optional, but strongly recommended): You can name(tag) your experiments to organize you logs file, e.g. specifying `--tag Exp_1` will put your log files into "logs/Exp_1/XXX/".Default value is "toy", which means toy experiments(e.g. debugging logs). Fore more information, see [log organization](#log) |
|    `--epoch`     | the total number of training epochs, by default 30 Epochs(may be different from original paper). |
| `--warmup-steps` |                warm-up strategy, by default 5                |
| `--start-decay`  |         the start epoch of lr decay, by default 15.          |
|  `--end-decay`   |        the ending epoch of lr decay , by default 27.         |
|  `--loss-func`   | for ablation study, by default "id+tri" which is cross-entropy loss plus triplet loss. You can choose from `["id", "id+tri"]`. |
|    `--graph`     | if set `--graph True` then use graph attention module; `--graph False` for not using* |

***Note: graph attention only used in training, not in inference/testing.**

For more detailed and comprehensive arguments description, please refer to `train.py`.

## Training

### Training Process

For GPU:

```shell
cd DDAG_mindspore/scripts/run_standalone_gpu # please enter this path before bash XXX.sh, otherwise path errors :)
bash train_sysu_all_part_graph.sh
```

For Ascend：

```shell
cd DDAG_mindspore/scripts/run_standalone_ascend # please enter this path before bash XXX.sh, otherwise path errors :)
bash train_sysu_all_part_graph.sh
```

You can replace `train_sysu_all_part_graph.sh` with other training scripts.

### Training Result

Training checkpoint will be stored in `logs/args.tag/training`, in which args.tag is specified before. The log <a id="log"> organization</a> is like following.  It will be generated when you run `.sh` script and start training.

```
logs
└── sysu_all_part_graph
    ├── testing
    │   ├── SYSU_P_3_performance_2021-12-10_15-47-03.txt
    │   └── SYSU_P_3_performance_2021-12-10_15-52-08.txt
    └── training
        ├── epoch_05_rank1_35.96_mAP_35.61_SYSU_batch-size_2*8*4=64_adam_lr_0.0035_loss-func_id+tri_P_3_Graph__main.ckpt
        ├── epoch_10_rank1_45.99_mAP_43.64_SYSU_batch-size_2*8*4=64_adam_lr_0.0035_loss-func_id+tri_P_3_Graph__main.ckpt
        ├── SYSU_batch-size_2*8*4=64_adam_lr_0.0035_loss-func_id+tri_P_3_Graph__main_performance_2021-12-10_02-59-41.txt
        └── SYSU_batch-size_2*8*4=64_adam_lr_0.0035_loss-func_id+tri_P_3_Graph__main_performance_2021-12-10_03-04-05.txt
```

In `training` subdirectory,  `.txt` files are log files and `.ckpt` files are checkpoint files.

At the end of every epoch training, `train.py` will use a random testing set (different from training set) to evaluate the model performance. So you will see rank-1 and mAP performance. And this programming pattern of evaluation is analogy to `test.py`.

Note: DDAG Graph module is not used in testing/inference mode.  If using part attention feature during inference, we named it FC_att, otherwise FC.

## Evaluation

### Evaluation Process

For GPU：

```shell
cd DDAG_mindspore/scripts/run_eval_gpu # please enter this path before bash XXX.sh, otherwise path errors :)
bash test_sysu_all_part_graph.sh
```

For Ascend:

```shell
cd DDAG_mindspore/scripts/run_eval_ascend # please enter this path before bash XXX.sh, otherwise path errors :)
bash test_sysu_all_part_graph.sh
```

### Evaluation Result

Before you start testing, please set `--resume` in `test_XXX.sh` . You can find your saved checkpoints in corresponding `/logs/args.tag/training/` path.  After running `test_XXX.sh`, you will get result from testing log file like the following:

```
Resume checkpoint:/.../DDAG_mindspore/logs/sysu_all_part_graph/training/epoch_25_rank1_57.04_mAP_55.76_SYSU_batch-size_2*8*4=64_adam_lr_0.0035_loss-func_id+tri_P_3_Graph__main.ckpt
Start epoch: 25
For SYSU-MM01 all search, the testing result is:
FC:   Rank-1: 56.96% | Rank-5: 82.83% | Rank-10: 91.04%| Rank-20: 96.04%| mAP: 55.28%
FC_att:   Rank-1: 57.42% | Rank-5: 82.59% | Rank-10: 90.91%| Rank-20: 96.17%| mAP: 55.33%
******************************************************************************
```

## Performance

### Training Performance

| Parameters                 | Ascend 910                                                   | GPU(RTX Titan) |
| -------------------------- | ------------------------------------------------------------ | ----------------------------------------------|
| Model Version              | DDAG + baseline(modified resnet50*) + Part Attention + Graph Attention | DDAG + baseline (modified resnet50) + Part Attention + Graph Attention |
| Resource                   | Ascend 910; CPU 2.60GHz, 192cores; Memory 755G; OS Euler2.8  |  NVIDIA RTX Titan-24G        |
| uploaded Date              | 12/10/2021 (month/day/year)                      | 12/10/2021 (month/day/year)           |
| MindSpore Version          | 1.3.0, 1.5.0                                             | 1.3.0, 1.5.0                                  |
| Dataset                    | SYSU-MM01, RegDB                              | SYSU-MM01, RegDB           |
| Training Parameters（SYSU-MM01） | Epochs=40, steps per epoch=695, batch_size = 64 | epoch=40, steps per epoch=64 batch_size = 64 |
| Training Parameters（RegDB） | Epochs=80, steps per epoch=695, batch_size = 64 | epoch=80, steps per epoch=64 batch_size = 64 |
| Optimizer                  | Adam                                                 | Adam                                  |
| Loss Function              | Softmax Cross Entropy + Triplet Loss                         | Softmax Cross Entropy + Triplet Loss          |
| outputs                    | feature vector + probability                              | feature vector + probability               |
| Loss                       | 0.2121                                           |  0.2208              |
| Speed                      | 660 ms/step（1pcs, Graph Mode）                           | 250ms/step（1pcs, Graph Mode）       |
| Total time                 | About 5h                                              | About                          |
| Parameters (M)             | 122.7                                           | 122.7                                 |
| Checkpoint for Fine tuning | 197M (.ckpt file)                                          | 196 (.ckpt file)                          |
| Scripts                    | [link](https://gitee.com/mindspore/models/tree/master/research/cv/DDAG) ||

*Note: Modified resnet-50 incorporates a modal-specific first layer. For more details, please read the [original paper](https://arxiv.org/pdf/2007.09314.pdf)  or original [pytorch implementation](https://github.com/mangye16/DDAG).

### Inference Performance

| Parameters        | Ascend                                  | GPU(RTX Titan)                          |
| ----------------- | --------------------------------------- | --------------------------------------- |
| Model Version     | DDAG + Part Attention + Graph Attention | DDAG + Part Attention + Graph Attention |
| Resource          | Ascend 910; OS Euler2.8                 | NVIDIA RTX Titan-24G                    |
| Uploaded Date     | 12/10/2021 (month/day/year)             | 12/10/2021 (month/day/year)             |
| MindSpore Version | 1.5.0, 1.3.0                            | 1.5.0, 1.3.0                            |
| Dataset           | SYSU-MM01, RegDB                        | SYSU-MM01, RegDB                        |
| batch_size        | 64                                      |                                         |
| outputs           | feature                                 |                                         |
| Accuracy          | See following 4 tables ↓                |                                         |

### SYSU-MM01 (all-search mode)

| Metric | Value(Pytorch) | Value(Mindspore, GPU) |
| :----: | :------------: | :-------------------: |
| Rank-1 |     54.75%     |        54.93%         |
|  mAP   |     53.02%     |        53.54%         |

### SYSU-MM01 (indoor-search mode)

| Metric | Value(Pytorch) | Value(Mindspore, GPU) |
| :----: | :------------: | :-------------------: |
| Rank-1 |     61.02%     |        59.60%         |
|  mAP   |     65.89%     |        66.39%         |

### RegDB(visible-infrared)

| Metric | Value(Pytorch) | Value(Mindspore, GPU, --trial 1) |
| :----: | :------------: | :------------------------------: |
| Rank-1 |     69.34%     |              68.93%              |
|  mAP   |     63.32%     |              62.67%              |

### RegDB(infrared-visible)

| Metric | Value(Pytorch) | Value(Mindspore, GPU, --trial 1) |
| :----: | :------------: | :------------------------------: |
| Rank-1 |     68.06%     |              68.45%              |
|  mAP   |     62.67%     |              63.23%              |

***Note**: The aforementioned pytorch results can be seen in original [pytorch repo](https://github.com/mangye16/DDAG).

## Description of Random Situation

- In `utils.py`, `IdentitySampler` used to sample different identities and images in both visible and infrared(thermal) modal, and we set random seed in `IndentitySampler`. This randomness will affect both inference part in `train.py` and in `eval.py`. Therefore small different rank-1 and mAP fluctuations(about 1%) between inference in `train.py` and `eval.py  ` may be seen even on the same training results.

- When testing on RegDB dataset, there is a `--trial` argument specifying which id to be selected; different  `--trial`  choosing may cause slight rank-1 mAP fluctuation.

## Reference

Please kindly cite the original paper references in your publications if it helps your research:

```
@inproceedings{eccv20ddag,
title={Dynamic Dual-Attentive Aggregation Learning for Visible-Infrared Person Re-Identification},
author={Ye, Mang and Shen, Jianbing and Crandall, David J. and Shao, Ling and Luo, Jiebo},
booktitle={European Conference on Computer Vision (ECCV)},
year={2020},
}
```

DDAG_mindspore version 2021.12
Developer List:
[@zhangzw12319](https://github.com/zhangzw12319)
[@sunhz0117](https://github.com/sunhz0117)

Please kindly reference the url of mindspore repository in your code if it helps your research and code.