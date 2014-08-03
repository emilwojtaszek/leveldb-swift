/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

#ifndef __LevelDB__comparator__
#define __LevelDB__comparator__

#include <stdio.h>
#include "c.h"

typedef int(^comparator)(const char* a, size_t alen, const char* b, size_t blen);

/// @brief A function that creates a wrapper for custom comparator logic.
/// @description Because Swift can't (yet) create C function pointers, this function creates
/// wrapper code that exposes the block-based paramater to LevelDB as function pointers.
/// This function should not be called directly by client code; it's invoked automatically
/// if a class implementing the Comparator protocol is passed through in the DB Options.
/// @param name The custom Comparator name, as a C String
/// @param compare A block that performs the comparison
/// @return An opaque pointer to the LevelDB Comparator
leveldb_comparator_t* leveldb_comparator_create_wrapper(const char*name, comparator compare);

#endif /* defined(__LevelDB__comparator__) */
