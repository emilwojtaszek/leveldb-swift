/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

#import <Foundation/Foundation.h>

//! Project version number for LevelDB.
FOUNDATION_EXPORT double LevelDBVersionNumber;

//! Project version string for LevelDB.
FOUNDATION_EXPORT const unsigned char LevelDBVersionString[];

// import leveldb C header as the bridging header is not available in frameworks
#import "c.h"
#import "comparator.h"