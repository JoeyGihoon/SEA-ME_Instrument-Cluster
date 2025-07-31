# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appInstrument_Cluster_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appInstrument_Cluster_autogen.dir/ParseCache.txt"
  "appInstrument_Cluster_autogen"
  )
endif()
