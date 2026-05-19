% Main script for MATLAB Next Word Prediction Project
% Part 1: Data Preparation

clear; clc; close all;

% Add path to include part1 folder
addpath('part1');

fprintf('MATLAB Next Word Prediction Project\n');
fprintf('=====================================\n\n');

% Run Part 1
corpusPath = 'corpus.txt';
analyze_and_visualize(corpusPath);