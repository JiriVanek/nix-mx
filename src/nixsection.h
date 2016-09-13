// Copyright (c) 2016, German Neuroinformatics Node (G-Node)
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the BSD License. See
// LICENSE file in the root of the Project.

#ifndef NIX_MX_SECTION
#define NIX_MX_SECTION

#include "arguments.h"

namespace nixsection {

    mxArray *describe(const nix::Section &section);

    void properties(const extractor &input, infusor &output);

    void create_property(const extractor &input, infusor &output);

    void create_property_with_value(const extractor &input, infusor &output);

} // namespace nixsection

#endif
