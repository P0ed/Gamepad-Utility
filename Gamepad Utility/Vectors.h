//
//  Vectors.h
//  Interstellar Overdrive
//
//  Created by Konstantin Sukharev on 23/12/14.
//  Copyright (c) 2014 Interstellar Overdrive. All rights reserved.
//

CG_INLINE CGVector CGVectorRotate(CGVector v, CGFloat radians) {
	return CGVectorMake(cosf(radians) * v.dx - sinf(radians) * v.dy, sinf(radians) * v.dx + cosf(radians) * v.dy);
}

CG_INLINE CGVector CGVectorMakeWithLength(CGFloat length, CGFloat radians) {
	return CGVectorMake(length * sinf(radians), length * cosf(radians));
}

CG_INLINE CGFloat CGVectorAtan2(CGVector v) {
	return atan2f(v.dx, v.dy);
}

CG_INLINE CGFloat CGVectorLength(CGVector v) {
	return sqrtf(v.dx * v.dx + v.dy * v.dy);
}

CG_INLINE CGVector CGVectorAdd(CGVector v1, CGVector v2) {
	return CGVectorMake(v1.dx + v2.dx, v1.dy + v2.dy);
}

CG_INLINE CGVector CGVectorSubtract(CGVector v1, CGVector v2) {
	return CGVectorMake(v2.dx - v1.dx, v2.dy - v1.dy);
}

CG_INLINE CGFloat CGVectorAngle(CGVector v1, CGVector v2) {
	return CGVectorAtan2(v2) - CGVectorAtan2(v1);
}

CG_INLINE CGVector CGVectorMultiply(CGVector v, float m) {
	return CGVectorMake(v.dx * m, v.dy * m);
}
