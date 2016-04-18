# Improving Data Association in Vision-based SLAM

## Overview
This repository contains the source code that replicates the paper on "Improving Data Association in Vision-based SLAM." The paper presents an approach to vision-based simultaneous localization and mapping (SLAM). The approach uses the scale invariant feature transform (SIFT) as features and applies a rejection technique to concentrate on a reduced set of distinguishable, stable features.

## Contributors
* Rounak Mehta
* Sudhanva Sreesha
* Frederick Wirth

## Folder Structure
root/                                 <br />
    kitti/                            <br />
        data/                         <br />
            2011_09_26_001/           <br />
                calibration/          <br />
                image00/              <br />
                image01/              <br />
                image02/              <br />
                image03/              <br />
                oxts/                 <br />
                    data/             <br />
                velodyne_points/      <br />
                    data/             <br />
            2011_09_26_002/           <br />
                calibration/          <br />
                image00/              <br />
                image01/              <br />
                image02/              <br />
                image03/              <br />
                oxts/                 <br />
                    data/             <br />
                velodyne_points/      <br />
                    data/             <br />
            ...                       <br />
            matlab/                   <br />
    simulation/                       <br />
        ekf/                          <br />
        fast1/                        <br />
        utils/                        <br />
    tools/                            <br />
    README.md                         <br />
    run.m                             <br />


## Running
RUN Vision-Based SLAM                                                   <br />
  RUN(ARG, DATATYPE, SLAM, DA, UPDATEMETHOD, PAUSELENGTH, MAKEVIDEO)    <br />
     ARG - is either the number of time steps, (e.g. 100 is             <br />
           a complete circuit), a data structure from a                 <br />
           previous run, or the base directory of the data              <br />
           in the case of running the KITTI dataset.                    <br />
     DATATYPE - is either 'sim' or 'kitti' for simulator                <br />
                or Victoria Park data set, respectively.                <br />
     SLAM - The slam algorithm to use, choices are:                     <br />
            'ekf' - Extended Kalman Filter based SLAM.                  <br />
            'fast1' - the FastSLAM 1.0 algorithm.                       <br />
     DA - data assocation, is one of either:                            <br />
          'known' - only available in simulator                         <br />
          'nn'    - incremental maximum                                 <br />
                    likelihood nearest neighbor                         <br />
          'nndg'  - nn double gate on landmark creation                 <br />
                    (throws away ambiguous observations)                <br />
          'jcbb'  - joint compatability branch and bound                <br />
     UPDATEMETHOD - The tpye of update that should happen               <br />
                    during the correction. Choices are:                 <br />
          'batch'  - Batch Updates                                      <br />
          'seq'    - Sequential Updates                                 <br />
     PAUSELENGTH - set to `inf`, to manually pause, o/w # of            <br />
                   seconds to wait (e.g., 0.3 is the default).          <br />
                                                                        <br />
                                                                        <br />
  [DATA, RESULTS] = RUN(ARG, CHOICE, PAUSELENGTH, DA)                   <br />
     DATA - an optional output and contains the data array              <br />
            generated and/or used during the simulation.                <br />
     RESULTS - an optional output that contains the results             <br />
               of the SLAM agorithm after the final time step.          <br />

## Examples
* Run Fast SLAM 1.0 over 200 steps and known data assocation, in the simulation environment.
** [data, results] = run(200, 'sim', 'fast1', 'known');
* Run Fast SLAM 1.0 using the data from "2011_09_26_001" with nearest neighbor data association.
** [results] = run('./kitti/data/2011_26_26_001', 'kitti', 'fast1', 'nn');
