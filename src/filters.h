// Copyright (c) 2017, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_FILTERS
#define NIX_MX_FILTERS

#include <nix.hpp>
#include "mex.h"
#include "datatypes.h"

// filter function templates
template<typename T, typename FN>
std::vector<T> filterFullEntity(const extractor &input, FN ff) {
    std::vector<T> res;

    switch (input.num<uint8_t>(2)) {
    case switchFilter::AcceptAll:
        res = ff(nix::util::AcceptAll<T>());
        break;
    case switchFilter::Id:
        res = ff(nix::util::IdFilter<T>(input.str(3)));
        break;
    case switchFilter::Ids:
        // this will crash matlab, if its not a vector of strings...
        res = ff(nix::util::IdsFilter<T>(input.vec<std::string>(3)));
        break;
    case switchFilter::Type:
        res = ff(nix::util::TypeFilter<T>(input.str(3)));
        break;
    case switchFilter::Name:
        res = ff(nix::util::NameFilter<T>(input.str(3)));
        break;
    case switchFilter::Metadata:
        res = ff(nix::util::MetadataFilter<T>(input.str(3)));
        break;
    case switchFilter::Source:
        res = ff(nix::util::SourceFilter<T>(input.str(3)));
        break;
    default: throw std::invalid_argument("unknown or unsupported filter");
    }

    return res;
}

template<typename T, typename FN>
std::vector<T> filterNameTypeEntity(const extractor &input, FN ff) {
    std::vector<T> res;

    switch (input.num<uint8_t>(2)) {
    case switchFilter::AcceptAll:
        res = ff(nix::util::AcceptAll<T>());
        break;
    case switchFilter::Id:
        res = ff(nix::util::IdFilter<T>(input.str(3)));
        break;
    case switchFilter::Ids:
        // this will crash matlab, if its not a vector of strings...
        res = ff(nix::util::IdsFilter<T>(input.vec<std::string>(3)));
        break;
    case switchFilter::Type:
        res = ff(nix::util::TypeFilter<T>(input.str(3)));
        break;
    case switchFilter::Name:
        res = ff(nix::util::NameFilter<T>(input.str(3)));
        break;
    default: throw std::invalid_argument("unknown or unsupported filter");
    }

    return res;
}

template<typename T, typename FN>
std::vector<T> filterNamedEntity(const extractor &input, FN ff) {
    std::vector<T> res;

    switch (input.num<uint8_t>(2)) {
    case switchFilter::AcceptAll:
        res = ff(nix::util::AcceptAll<T>());
        break;
    case switchFilter::Id:
        res = ff(nix::util::IdFilter<T>(input.str(3)));
        break;
    case switchFilter::Ids:
        // this will crash matlab, if its not a vector of strings...
        res = ff(nix::util::IdsFilter<T>(input.vec<std::string>(3)));
        break;
    case switchFilter::Name:
        res = ff(nix::util::NameFilter<T>(input.str(3)));
        break;
    default: throw std::invalid_argument("unknown or unsupported filter");
    }

    return res;
}

template<typename T, typename FN>
std::vector<T> filterEntity(const extractor &input, FN ff) {
    std::vector<T> res;

    switch (input.num<uint8_t>(2)) {
    case switchFilter::AcceptAll:
        res = ff(nix::util::AcceptAll<T>());
        break;
    case switchFilter::Id:
        res = ff(nix::util::IdFilter<T>(input.str(3)));
        break;
    case switchFilter::Ids:
        // this will crash matlab, if its not a vector of strings...
        res = ff(nix::util::IdsFilter<T>(input.vec<std::string>(3)));
        break;
    default: throw std::invalid_argument("unknown or unsupported filter");
    }

    return res;
}

// find filter function templates
template<typename T, typename FN>
std::vector<T> filterFullEntity(const extractor &input, 
                    uint8_t filter_id, size_t val_pos, size_t max_depth, FN ff) {
    std::vector<T> res;

    switch (filter_id) {
    case switchFilter::AcceptAll:
        res = ff(nix::util::AcceptAll<T>(), max_depth);
        break;
    case switchFilter::Id:
        res = ff(nix::util::IdFilter<T>(input.str(val_pos)), max_depth);
        break;
    case switchFilter::Ids:
        // this will crash matlab, if its not a vector of strings...
        res = ff(nix::util::IdsFilter<T>(input.vec<std::string>(val_pos)), max_depth);
        break;
    case switchFilter::Type:
        res = ff(nix::util::TypeFilter<T>(input.str(val_pos)), max_depth);
        break;
    case switchFilter::Name:
        res = ff(nix::util::NameFilter<T>(input.str(val_pos)), max_depth);
        break;
    case switchFilter::Metadata:
        res = ff(nix::util::MetadataFilter<T>(input.str(val_pos)), max_depth);
        break;
    case switchFilter::Source:
        res = ff(nix::util::SourceFilter<T>(input.str(val_pos)), max_depth);
        break;
    default: throw std::invalid_argument("unknown or unsupported filter");
    }

    return res;
}

template<typename T, typename FN>
std::vector<T> filterNameTypeEntity(const extractor &input,
                        uint8_t filter_id, size_t val_pos, size_t max_depth, FN ff) {
    std::vector<T> res;

    switch (filter_id) {
    case switchFilter::AcceptAll:
        res = ff(nix::util::AcceptAll<T>(), max_depth);
        break;
    case switchFilter::Id:
        res = ff(nix::util::IdFilter<T>(input.str(val_pos)), max_depth);
        break;
    case switchFilter::Ids:
        // this will crash matlab, if its not a vector of strings...
        res = ff(nix::util::IdsFilter<T>(input.vec<std::string>(val_pos)), max_depth);
        break;
    case switchFilter::Type:
        res = ff(nix::util::TypeFilter<T>(input.str(val_pos)), max_depth);
        break;
    case switchFilter::Name:
        res = ff(nix::util::NameFilter<T>(input.str(val_pos)), max_depth);
        break;
    default: throw std::invalid_argument("unknown or unsupported filter");
    }

    return res;
}

#endif
