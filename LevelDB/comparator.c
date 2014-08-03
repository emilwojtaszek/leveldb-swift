/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

#include "comparator.h"
#include <stdlib.h>
#include <string.h>
#include <Block.h>

struct comparator_struct {
    char *name;
    comparator compare;
};

int comparator_wrapper(void *state, const char *a, size_t alen, const char *b, size_t blen) {
    struct comparator_struct *cmp = state;
    return cmp->compare(a, alen, b, blen);
}

const char* name_wrapper(void *state) {
    struct comparator_struct *cmp = state;
    return cmp->name;
}

void destructor(void *state) {
    struct comparator_struct *cmp = state;
    free(cmp->name);
    Block_release(cmp->compare);
    free(cmp);
}

leveldb_comparator_t* leveldb_comparator_create_wrapper(const char *name, comparator compare)
{
    struct comparator_struct *cmp = malloc(sizeof(struct comparator_struct));
    char *nameCpy = malloc(strlen(name));
    cmp->name = strcpy(nameCpy, name);
    cmp->compare = Block_copy(compare);
    return leveldb_comparator_create(cmp, &destructor, &comparator_wrapper, &name_wrapper);
}