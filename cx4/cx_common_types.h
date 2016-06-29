#ifndef __CX_COMMON_TYPES_H
#define __CX_COMMON_TYPES_H


#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */


#include "misc_types.h"


typedef unsigned long         CxPixel;
typedef struct _CxWidgetType *CxWidget;

typedef int                   CxDataRef_t;
enum {NULL_CxDataRef = 0};

typedef struct
{
    char   *ident;
    char   *label;
    int     readonly;
    int     modified;
    double  value;
    double  minalwd;
    double  maxalwd;
    double  rsrvd_d;
} CxKnobParam_t;

typedef union
{
  float64        f64;
  float32        f32;
  int64          i64;
  uint64         u64;
  uint32         u32;
  int32          i32;
  int16          i16;
  uint16         u16;
  int8           i8;
  uint8          u8;
  char8          c8;
  char32         c32;
} CxAnyVal_t;


#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* __CX_COMMON_TYPES_H */
