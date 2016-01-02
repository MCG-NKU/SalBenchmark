#pragma once

/////////////////////////////////////////////////////////////////////////////////
// ImageAccessConcept is a general concept for reading image
// 1. it does not necessarily own memory
// 2. memory could be non-continuous for alignment at each row, i.e., each image row y is pointed by RowPtr(y) at Stride() bytes
template<class P>
class ImageAccessConcept
{
public:
	typedef P PixelType;

	unsigned int Width() const { return 0; }
	unsigned int Height() const { return 0; }
	unsigned int Stride() const { return 0; }
	const PixelType* RowPtr(int y) const { return 0; }
	const PixelType& Pixel(int x, int y) const { return RowPtr(y)[x]; }

	// writing support
	PixelType* RowPtr(int y) { return 0; }
	PixelType& Pixel(int x, int y) { return RowPtr(y)[x]; }
};

template<class ImageAccessConcept>
void ImageAccessConceptCheck(ImageAccessConcept& img)
{
	ImageAccessConcept::PixelType p;

	unsigned int w = img.Width();
	unsigned int h = img.Height();
	unsigned int s = img.Stride();

	const ImageAccessConcept::PixelType* ptr = img.RowPtr(0);
	p = img.Pixel(0, 0);

	img.RowPtr(0)[0] = p;
	img.Pixel(0, 0) = p;

	// test basic functions
	if (IsImageEmpty(img));
	if (IsPointInsideImage(img, 0, 0));
	unsigned int left, top, right, bottom;
	if (ComputeImageBBox(img, left, top, right, bottom));
	p = FindMaxPointInImage(img, left, top);
}

//////////////////////////////////////////////////////////////////////
// very basic helper functions that take an ImageAccessConcept as input
#include <type_traits>

template<class IntType>
bool RectIntersect(IntType l0, IntType t0, IntType r0, IntType b0
	,IntType l1, IntType t1, IntType r1, IntType b1
	,IntType& l_out, IntType& t_out, IntType& r_out, IntType& b_out)
{
	static_assert(std::is_integral<IntType>::value, "RectIntersect must use integral type");

	l_out = std::max(l0, l1);
	t_out = std::max(t0, t1);
	r_out = std::min(r0, r1);
	b_out = std::min(b0, b1);

	return ((r_out > l_out) && (b_out > t_out));
}

template<class ImageAccessType>
bool IsImageEmpty(const ImageAccessType& img)
{
	return (img.Width() == 0) || (img.Height() == 0);
}

template<class ImageAccessType, class IntType>
bool IsPointInsideImage(const ImageAccessType& img, IntType x, IntType y)
{
	static_assert(std::is_integral<IntType>::value, "IsPointInsideImage must use integral type");

	return ((x >= 0) && (x < static_cast<IntType>(img.Width())) && (y >= 0) && (y < static_cast<IntType>(img.Height())));
}

// compute the bounding box of non-zero area, [(left, top), (right, bottom))
// return true if the bbox is valid, otherwise false (all pixels are zero and empty bbox)
// TODO: generalize 'be zero' to a predicate
template<class ImageAccessType, class IntType>
bool ComputeImageBBox(const ImageAccessType& img, IntType& left, IntType& top, IntType& right, IntType& bottom)
{
	static_assert(std::is_integral<IntType>::value, "ComputeImageBBox must use integral type");

	if (IsImageEmpty(img)) return false;

	// make sure width(height) > 0
	left = img.Width()-1;
	top = img.Height()-1;
	right = 0;
	bottom = 0;

	for(unsigned int y = 0; y < img.Height(); y++)
	{
		const ImageAccessType::PixelType* pRow = img.RowPtr(y);
		for(unsigned int x = 0; x < img.Width(); x++, pRow++)
		{
			if (0 == *pRow) continue; // TODO: could be replaced by a predicate

			if (x < left) left = x;
			if (x > right) right = x;
			if (y < top) top = y;
			if (y > bottom) bottom = y;
		}
	}

	right++;	bottom++;	// make the boundary open

	return ((left < right) && (top < bottom));
}

// TODO: generalize 'max' to a predicate
template<class ImageAccessType, class IntType>
typename ImageAccessType::PixelType FindMaxPointInImage(const ImageAccessType& img, IntType& best_x, IntType& best_y)
{
	static_assert(std::is_integral<IntType>::value, "FindMaxPointInImage must use integral type");

	best_x = 0;
	best_y = 0;
	typename ImageAccessType::PixelType best_value = img.RowPtr(0)[0];

	const int h = img.Height();
	const int w = img.Width();
	for (unsigned int y = 0; y < img.Height(); y++)
	{
		const ImageAccessType::PixelType* pRow = img.RowPtr(y);
		for (unsigned int x = 0; x < img.Width(); x++, pRow++)
		{
			if (*pRow > best_value) // TODO: could be replaced by a predicate
			{
				best_value = *pRow;
				best_x = x;
				best_y = y;
			}
		}
	}

	return best_value;
}