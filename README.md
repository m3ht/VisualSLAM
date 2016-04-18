# Improving Data Association in Vision-based SLAM

## Overview
This repository contains the source code that replicates the paper on "Improving Data Association in Vision-based SLAM." The paper presents an approach to vision-based simultaneous localization and mapping (SLAM). The approach uses the scale invariant feature transform (SIFT) as features and applies a rejection technique to concentrate on a reduced set of distinguishable, stable features.

## Contributors
* Rounak Mehta
* Sudhanva Sreesha
* Frederick Wirth

## Folder Structure
root/
    kitti/
        data/
            2011_09_26_001/
                calibration/
                image00/
                image01/
                image02/
                image03/
                oxts/
                    data/
                velodyne_points/
                    data/
            2011_09_26_002/
                calibration/
                image00/
                image01/
                image02/
                image03/
                oxts/
                    data/
                velodyne_points/
                    data/
            ...
            matlab/
    simulation/
        ekf/
        fast1/
        utils/
    tools/
    README.md
    run.m


## Running
RUN Vision-Based SLAM
  RUN(ARG, DATATYPE, SLAM, DA, UPDATEMETHOD, PAUSELENGTH, MAKEVIDEO)
     ARG - is either the number of time steps, (e.g. 100 is
           a complete circuit), a data structure from a
           previous run, or the base directory of the data
           in the case of running the KITTI dataset.
     DATATYPE - is either 'sim' or 'kitti' for simulator
                or Victoria Park data set, respectively.
     SLAM - The slam algorithm to use, choices are:
            'ekf' - Extended Kalman Filter based SLAM.
            'fast1' - the FastSLAM 1.0 algorithm.
     DA - data assocation, is one of either:
          'known' - only available in simulator
          'nn'    - incremental maximum
                    likelihood nearest neighbor
          'nndg'  - nn double gate on landmark creation
                    (throws away ambiguous observations)
          'jcbb'  - joint compatability branch and bound
     UPDATEMETHOD - The tpye of update that should happen
                    during the correction. Choices are:
          'batch'  - Batch Updates
          'seq'    - Sequential Updates
     PAUSELENGTH - set to `inf`, to manually pause, o/w # of
                   seconds to wait (e.g., 0.3 is the default).

  [DATA, RESULTS] = RUN(ARG, CHOICE, PAUSELENGTH, DA)
     DATA - an optional output and contains the data array
            generated and/or used during the simulation.
     RESULTS - an optional output that contains the results
               of the SLAM agorithm after the final time step.

## Examples
* Run Fast SLAM 1.0 over 200 steps and known data assocation, in the simulation environment.
** [data, results] = run(200, 'sim', 'fast1', 'known');
* Run Fast SLAM 1.0 using the data from "2011_09_26_001" with nearest neighbor data association.
** [results] = run('./kitti/data/2011_26_26_001', 'kitti', 'fast1', 'nn');
