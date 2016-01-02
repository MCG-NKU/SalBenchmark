#pragma once

#include <iostream>
using namespace std;

#include "ImageConcept.h"

// this file defines very basic image data types and operations, which are supposed to be
// 1. easy for algorithm implementation and debug
// 2. easy to be replaced by more advanced (faster, memory efficient...) counterparts

/////////////////////////////////////////////////////////////////////////////////
// ImageData and ImageAccess are naive implementation of ImageAccessConcept
// ImageData stores the minimal data and is compatible with windows bitmap
// they should be used when an ImageAccessConcept is not memory owner
struct ImageData
{
	ImageData(unsigned int _width, unsigned int _height, unsigned int _stride, unsigned char* _data)
		: width(_width), height(_height), stride(_stride), data(_data) {}
	ImageData(){}
	unsigned int width, height; // image size
	unsigned int stride; // size of a row in bytes
	unsigned char* data; // TODO: not support write yet
};

template<class P> class ImageAccess;
typedef ImageAccess<float> ImageAccessFloat;

template<class P>
class ImageAccess : private ImageData
{
public:
	typedef P PixelType;
	ImageAccess(unsigned int _width, unsigned int _height, unsigned int _stride, const P* _data)
		: ImageData(_width, _height, _stride, (unsigned char*)_data) {}
	ImageAccess(){}
	unsigned int Width() const { return width; }
	unsigned int Height() const { return height; }
	unsigned int Stride() const { return stride; }
	const PixelType* RowPtr(int y) const { return (const PixelType*)(data + y*stride); }
	const PixelType& Pixel(int x, int y) const { return RowPtr(y)[x]; }

	// writing support
	PixelType* RowPtr(int y) { return (PixelType*)(data + y*stride); }
	PixelType& Pixel(int x, int y) { return RowPtr(y)[x]; }
};

///////////////////////////////////////////////////////////////////////
#include <assert.h>
#include <vector>
using namespace std;

// ImageSimple is an ImageAccessConcept that owns memory, which is continuous for convenience
// e.g., stride is always width*sizeof(pixel_type) and vector-like operations are supported
template<class P> class ImageSimple;

typedef ImageSimple<float> ImageSimpleFloat;
typedef ImageSimple<double> ImageSimpleDouble;
typedef ImageSimple<unsigned char> ImageSimpleUChar;
typedef ImageSimple<char> ImageSimpleChar;
typedef ImageSimple<unsigned short> ImageSimpleUShort;
typedef ImageSimple<short> ImageSimpleShort;
typedef ImageSimple<unsigned int> ImageSimpleUInt;
typedef ImageSimple<int> ImageSimpleInt;

// TODO: separate memory management in another class, e.g., that supports both dynamic and static image size
// TODO: derive it from vector<P>? reuse move constructor/assignment in vector?
template<class P>
class ImageSimple
{
private:
	vector<P> data;
	vector<P*> row_ptrs;
	unsigned int width;

	void assign_row_ptrs(int h)
	{
		row_ptrs.resize(h);

		for(int i = 0; i < h; i++)
			row_ptrs[i] = &data[i*width];
	}

public:
	typedef P PixelType;
	
	ImageSimple() : width(0) {}
	ImageSimple(unsigned int w, unsigned int h) { Create(w, h); }
	ImageSimple(unsigned int w, unsigned int h, const PixelType* img_data) { Create(w, h, img_data); }

	// move constructor/assignment
	ImageSimple(ImageSimple&& img) : width(0)
	{
		*this = std::move(img);
	}

	ImageSimple& operator = (ImageSimple&& img)
	{
		if (this != &img)
		{
			data.swap(img.data);
			row_ptrs.swap(img.row_ptrs);
			width = img.width;
			img.width = 0;
		}

		return *this;
	}

	// copy constructor/assignment
	ImageSimple(const ImageSimple& img) : data(img.data), width(img.width)
	{
		assign_row_ptrs(img.Height());
	}

	ImageSimple& operator = (const ImageSimple& img)
	{
		if (this != &img)
		{
			data = img.data;
			width = img.width;
			assign_row_ptrs(img.Height());
		}

		return *this;
	}

	// copy from ImageAccess constructor/assignment
	explicit ImageSimple(const ImageAccess<PixelType>& img)
	{
		*this = img;
	}

	ImageSimple& operator = (const ImageAccess<PixelType>& img)
	{
		Create(img.Width(), img.Height());
		for(unsigned y = 0; y < img.Height(); y++)
		{
			const PixelType* pSrcRow = img.RowPtr(y);
			PixelType* pDstRow = RowPtr(y);
			for(unsigned x = 0; x < img.Width(); x++, pSrcRow++, pDstRow++)
				*pDstRow = *pSrcRow;
		}

		return *this;
	}

	void Create(unsigned int w, unsigned int h)
	{
		width = w;
		data.resize(h*w, 0);
		assign_row_ptrs(h);
	}

	void Create(unsigned int w, unsigned int h, const PixelType* img_data)
	{
		Create(w, h);
		copy(img_data, img_data+w*h, data.begin());
	}

	// the pixel conversion is mainly for convenience and does not guarantee correctness when pixel types are different
	template<class ValueType>
	void Copy(const ImageSimple<ValueType>& img)
	{
		Create(img.Width(), img.Height());
		Copy(img.RowPtr(0));
	}

	// the pixel conversion is mainly for convenience and does not guarantee correctness when pixel types are different
	template<class ValueType>
	void Copy(const ValueType* img_data)
	{
		for(unsigned int n = 0; n < static_cast<unsigned int>(data.size()); n++)
			data[n] = img_data[n];
	}

	// TODO: could be faster something like memcpy?
	void FillPixels(const PixelType& v)
	{
		for(unsigned int i = 0; i < data.size(); i++)
			data[i] = v;
	}

	unsigned int Height() const { return static_cast<unsigned int>(row_ptrs.size()); }
	unsigned int Width() const { return width; }
	unsigned int Stride() const { return sizeof(PixelType) * width; }

	const PixelType* RowPtr(int y) const
	{
		assert(y >= 0);
		assert(y < Height());
		return row_ptrs[y]; 
	}

	PixelType* RowPtr(int y) 
	{
		assert(y >= 0);
		assert(y < Height());
		return row_ptrs[y]; 
	}

	const PixelType& Pixel(int x, int y) const 
	{
		assert(y >= 0);
		assert(y < Height());
		assert(x >= 0);
		assert(x < Width());
		return row_ptrs[y][x];
	}

	PixelType& Pixel(int x, int y) 
	{
		assert(y >= 0);
		assert(y < Height());
		assert(x >= 0);
		assert(x < Width());
		return row_ptrs[y][x];
	}

	unsigned int MemoryInByte() const
	{
		return static_cast<unsigned int>(data.size() * sizeof(PixelType) + row_ptrs.size() * sizeof(PixelType*) + sizeof(unsigned int));
	}

	float MemoryInKB() const { return MemoryInByte() / 1024.0f; }

	// TODO: inherit it from vector can easily support vector operations
	// vector like support
	unsigned int size() const { return Height() * Width(); }
	PixelType& operator[](int n) { return data[n]; }
	const PixelType& operator[](int n) const { return data[n]; }

	// return the subimage at (x,y) with dimension (h,w)
	// it is of the same memory of this but appears as an independent image
	// its memory is not longer continuous
	ImageAccess<PixelType> GetSubImage(unsigned int x, unsigned int y, unsigned int w, unsigned int h)
	{
		assert(x+w <= Width());
		assert(y+h <= Height());
		return ImageAccess<PixelType>(w, h, Stride(), RowPtr(y)+x);
	}

	const ImageAccess<PixelType> GetSubImage(unsigned int x, unsigned int y, unsigned int w, unsigned int h) const
	{
		assert(x+w <= Width());
		assert(y+h <= Height());
		return ImageAccess<PixelType>(w, h, Stride(), RowPtr(y)+x);
	}

	ImageAccess<PixelType> GetImageAccess() { return GetSubImage(0, 0, Width(), Height()); }

	const ImageAccess<PixelType> GetImageAccess() const { return GetSubImage(0, 0, Width(), Height()); }
};

template<class ImageAccessType, class IntType>
ImageSimple<typename ImageAccessType::PixelType> CopySubImage(const ImageAccessType& img, IntType left, IntType top, IntType right, IntType bottom)
{
	static_assert(std::is_integral<IntType>::value, "CopySubImage() must use integral type");

	assert(right > left);
	assert(bottom > top);

	ImageSimple<typename ImageAccessType::PixelType> sub_img(right - left, bottom - top);
	
	for(IntType y = top; y < bottom; y++)
	{
		const ImageAccessType::PixelType* pSrcRow = img.RowPtr(y) + left;
		ImageAccessType::PixelType* pDstRow = sub_img.RowPtr(y-top);
		for(IntType x = left; x < right; x++, pSrcRow++, pDstRow++)
			*pDstRow = *pSrcRow;
	}

	return sub_img;
}

void test_image_simple();