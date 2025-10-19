file(REMOVE_RECURSE
  "generated/newton_ispc.h"
  "generated/newton_ispc.obj"
  "newton_ispc_lib.lib"
  "newton_ispc_lib.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/newton_ispc_lib.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
