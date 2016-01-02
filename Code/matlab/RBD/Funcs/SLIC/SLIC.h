#pragma once

#include "image/ImageSimple.h"

int Run_SLIC_GivenPatchNum(ImageSimpleFloat &LImg, ImageSimpleFloat &AImg, ImageSimpleFloat &BImg, unsigned int iPatchNum, float compactness, ImageSimpleUInt &idxImg);

int Run_SLIC_GivenPatchSize(ImageSimpleFloat &LImg, ImageSimpleFloat &AImg, ImageSimpleFloat &BImg, unsigned int iPatchSize, float compactness, ImageSimpleUInt &idxImg);