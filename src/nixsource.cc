#include "nixsource.h"
#include "nixgen.h"

#include "mex.h"

#include <nix.hpp>

#include "handle.h"
#include "arguments.h"
#include "struct.h"

namespace nixsource {

    void describe(const extractor &input, infusor &output)
    {
        nix::Source currSource = input.entity<nix::Source>(1);
        struct_builder sb({ 1 }, { "id", "type", "name", "definition", "sourceCount" });
        sb.set(currSource.id());
        sb.set(currSource.type());
        sb.set(currSource.name());
        sb.set(currSource.definition());
        sb.set(currSource.sourceCount());
        output.set(0, sb.array());
    }

    void list_sources(const extractor &input, infusor &output)
    {
        nix::Source currSource = input.entity<nix::Source>(1);
        output.set(0, nixgen::list_sources(currSource.sources()));
    }

    void open_source(const extractor &input, infusor &output)
    {
        nix::Source currSource = input.entity<nix::Source>(1);
        output.set(0, nixgen::open_source(currSource.getSource(input.str(2))));
    }

    void open_metadata_section(const extractor &input, infusor &output)
    {
        nix::Source currTag = input.entity<nix::Source>(1);
        output.set(0, nixgen::open_metadata_section(currTag.metadata()));
    }

    void sources(const extractor &input, infusor &output)
    {
        nix::Source tag = input.entity<nix::Source>(1);
        std::vector<nix::Source> arr = tag.sources();

        const mwSize size = static_cast<mwSize>(arr.size());
        mxArray *lst = mxCreateCellArray(1, &size);

        for (int i = 0; i < arr.size(); i++) {
            mxSetCell(lst, i, make_mx_array(handle(arr[i])));
        }

        output.set(0, lst);
    }

} // namespace nixsource