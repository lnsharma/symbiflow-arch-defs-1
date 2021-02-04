function(DEFINE_QL_TOOLCHAIN_TARGET)
  set(options)
  set(oneValueArgs FAMILY ARCH CONV_SCRIPT SYNTH_SCRIPT ROUTE_CHAN_WIDTH CELLS_SIM)
  set(multiValueArgs VPR_ARCH_ARGS)

  cmake_parse_arguments(
    DEFINE_QL_TOOLCHAIN_TARGET
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    "${ARGN}"
  )

  set(FAMILY ${DEFINE_QL_TOOLCHAIN_TARGET_FAMILY})
  set(ARCH ${DEFINE_QL_TOOLCHAIN_TARGET_ARCH})
  set(VPR_ARCH_ARGS ${DEFINE_QL_TOOLCHAIN_TARGET_VPR_ARCH_ARGS})
  set(ROUTE_CHAN_WIDTH ${DEFINE_QL_TOOLCHAIN_TARGET_ROUTE_CHAN_WIDTH})

  set(WRAPPERS env symbiflow_generate_constraints symbiflow_pack symbiflow_place symbiflow_route symbiflow_synth symbiflow_write_bitstream symbiflow_write_fasm symbiflow_write_binary symbiflow_write_jlink symbiflow_write_openocd symbiflow_write_bitheader symbiflow_write_fasm2bels symbiflow_generate_fasm2bels ql_symbiflow symbiflow_analysis)

  # Export VPR arguments
  list(JOIN VPR_BASE_ARGS " " VPR_BASE_ARGS)
  string(JOIN " " VPR_ARGS ${VPR_BASE_ARGS} "--route_chan_width ${ROUTE_CHAN_WIDTH}" ${VPR_ARCH_ARGS})

  set(VPR_CONFIG_TEMPLATE "${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/toolchain_wrappers/vpr_config.sh")
  set(VPR_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/vpr_config.sh")
  configure_file(${VPR_CONFIG_TEMPLATE} "${VPR_CONFIG}" @ONLY)

  set(VPR_COMMON "${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/toolchain_wrappers/vpr_common")
  
  # Add cells.sim to all deps, so it is installed with make install
  get_file_target(CELLS_SIM_TARGET ${DEFINE_QL_TOOLCHAIN_TARGET_CELLS_SIM})
  add_custom_target(
    "DEVICE_INSTALL_${CELLS_SIM_TARGET}"
    ALL
    DEPENDS ${DEFINE_QL_TOOLCHAIN_TARGET_CELLS_SIM}
    )

  set(TOOLCHAIN_WRAPPERS)
  foreach(WRAPPER ${WRAPPERS})
    set(WRAPPER_PATH "${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/toolchain_wrappers/${WRAPPER}")
    list(APPEND TOOLCHAIN_WRAPPERS ${WRAPPER_PATH})
  endforeach()

  install(FILES ${TOOLCHAIN_WRAPPERS} ${VPR_COMMON}
          DESTINATION bin
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  install(FILES ${VPR_CONFIG}
          DESTINATION share/quicklogic/${FAMILY}/vpr)

  # install python scripts
  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/utils/split_inouts.py
          DESTINATION bin/python
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/create_ioplace.py
          DESTINATION bin/python
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/create_place_constraints.py
          DESTINATION bin/python
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/fasm2bels.py
          DESTINATION bin/python
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/quicklogic-fasm/quicklogic_fasm/bitstream_to_jlink.py
          DESTINATION bin/python
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/quicklogic-fasm/quicklogic_fasm/bitstream_to_header.py
          DESTINATION bin/python
          PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

  # install python script dependencies
  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/connections.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/data_structs.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/timing.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/tile_import.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/utils.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/verilogmodule.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/utils/vpr_io_place.py
      DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/utils/vpr_place_constraints.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/utils/eblif.py
          DESTINATION bin/python
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/utils/lib/parse_pcf.py
          DESTINATION bin/python/lib
          PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  # install techmap
  install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/techmap
      DESTINATION share/techmaps/quicklogic/${FAMILY})

  install(FILES ${DEFINE_QL_TOOLCHAIN_TARGET_CELLS_SIM}
          DESTINATION share/techmaps/quicklogic/${FAMILY}/techmap)

  # install Yosys scripts
  install(FILES  ${DEFINE_QL_TOOLCHAIN_TARGET_CONV_SCRIPT} ${DEFINE_QL_TOOLCHAIN_TARGET_SYNTH_SCRIPT}
    DESTINATION share/quicklogic/${FAMILY}/yosys)

  # Install PP3 specific files
  if("${FAMILY}" STREQUAL "pp3")

    # Database
    install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/build/quicklogic/${FAMILY}/devices/ql-eos-s3-virt/db_phy.pickle
      DESTINATION share/arch/ql-eos-s3_wlcsp
      PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ )

    # Python scripts
    install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/common/utils/eos_s3_iomux_config.py
      DESTINATION bin/python
      PERMISSIONS WORLD_EXECUTE WORLD_READ OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE)

    # Yosys scripts
    install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/yosys/pack.tcl
      DESTINATION share/quicklogic/${FAMILY}/yosys
      PERMISSIONS WORLD_READ OWNER_WRITE OWNER_READ GROUP_READ)

  # Install AP3 specific files
  elseif("${FAMILY}" STREQUAL "ap3")

    # Anything?

  # Unsupported family
  else()
    message(FATA_ERROR "Family '${FAMILY}' is not suitable for installed toolchain")
  endif()


endfunction()

function(DEFINE_QL_DEVICE_CELLS_INSTALL_TARGET)
  set(options)
  set(oneValueArgs DEVICE_TYPE DEVICE PACKAGE)
  set(multiValueArgs)

  cmake_parse_arguments(
    DEFINE_QL_DEVICE_CELLS_INSTALL_TARGET
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    "${ARGN}"
  )

  set(DEVICE_TYPE ${DEFINE_QL_DEVICE_CELLS_INSTALL_TARGET_DEVICE_TYPE})
  set(DEVICE ${DEFINE_QL_DEVICE_CELLS_INSTALL_TARGET_DEVICE})
  set(PACKAGE ${DEFINE_QL_DEVICE_CELLS_INSTALL_TARGET_PACKAGE})

  # Install the final architecture file. This is actually already done in
  # DEFINE_DEVICE but in case when the file name differs across devices we
  # want it to be unified for the installed toolchain.
  get_target_property_required(DEVICE_MERGED_FILE ${DEVICE_TYPE} DEVICE_MERGED_FILE)
  get_file_target(DEVICE_MERGED_FILE_TARGET ${DEVICE_MERGED_FILE})
  get_file_location(DEVICE_MERGED_FILE ${DEVICE_MERGED_FILE})

  install(FILES ${DEVICE_MERGED_FILE}
          DESTINATION "share/arch/${DEVICE}_${PACKAGE}"
          RENAME "arch_${DEVICE}_${PACKAGE}.xml")

  # Install device-specific cells sim and cells map files
  get_target_property(CELLS_SIM ${DEVICE_TYPE} CELLS_SIM)
  get_target_property(CELLS_MAP ${DEVICE_TYPE} CELLS_MAP)

  if (NOT "${CELLS_SIM}" MATCHES ".*NOTFOUND")
    get_file_target(CELLS_SIM_TARGET ${CELLS_SIM})
    get_file_location(CELLS_SIM ${CELLS_SIM})
    add_custom_target(
      "CELLS_INSTALL_${DEVICE}_CELLS_SIM"
      ALL
      DEPENDS ${CELLS_SIM_TARGET} ${CELLS_SIM}
      )
    install(FILES ${CELLS_SIM}
      DESTINATION "share/arch/${DEVICE}_${PACKAGE}/cells")
  endif()

  if (NOT "${CELLS_MAP}" MATCHES ".*NOTFOUND")
    get_file_target(CELLS_MAP_TARGET ${CELLS_MAP})
    get_file_location(CELLS_MAP ${CELLS_MAP})
    add_custom_target(
      "CELLS_INSTALL_${DEVICE}_CELLS_MAP"
      ALL
      DEPENDS ${CELLS_MAP_TARGET} ${CELLS_MAP}
      )
    install(FILES ${CELLS_MAP}
      DESTINATION "share/arch/${DEVICE}_${PACKAGE}/cells")
  endif()

  # install PP3 RAMFIFO simulation model files
  if("${FAMILY}" STREQUAL "pp3")
    install(FILES ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/primitives/assp/assp_bfm.sim.v
            DESTINATION "share/arch/${DEVICE}_${PACKAGE}/cells")

    install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/primitives/ramfifo/
            DESTINATION "share/arch/${DEVICE}_${PACKAGE}/cells"
            FILES_MATCHING PATTERN "*.v")

    # install RAMFIFO tutotrial examples
    install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/tests/FIFO_Examples
            DESTINATION "tests")
    install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/tests/RAM_Examples
            DESTINATION "tests")
    install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/tests/quicklogic_testsuite/counter_16bit
            DESTINATION "tests")
    install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/tests/quicklogic_testsuite/fifo_test
            DESTINATION "tests")
    install(DIRECTORY ${symbiflow-arch-defs_SOURCE_DIR}/quicklogic/${FAMILY}/tests/quicklogic_testsuite/ram_test
            DESTINATION "tests")
  endif()
      
endfunction()

function(DEFINE_QL_PINMAP_CSV_INSTALL_TARGET)
  set(options)
  set(oneValueArgs PART DEVICE_TYPE BOARD DEVICE PACKAGE FABRIC_PACKAGE)
  set(multiValueArgs)

  cmake_parse_arguments(
    DEFINE_QL_PINMAP_CSV_INSTALL_TARGET
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    "${ARGN}"
  )

  set(PART ${DEFINE_QL_PINMAP_CSV_INSTALL_TARGET_PART})
  set(BOARD ${DEFINE_QL_PINMAP_CSV_INSTALL_TARGET_BOARD})
  set(DEVICE ${DEFINE_QL_PINMAP_CSV_INSTALL_TARGET_DEVICE})
  set(DEVICE_TYPE ${DEFINE_QL_PINMAP_CSV_INSTALL_TARGET_DEVICE_TYPE})
  set(PACKAGE ${DEFINE_QL_PINMAP_CSV_INSTALL_TARGET_PACKAGE})

  get_target_property_required(PINMAP ${BOARD} PINMAP)
  get_file_location(PINMAP_FILE ${PINMAP})
  get_filename_component(PINMAP_FILE_NAME ${PINMAP_FILE} NAME)
  append_file_dependency(DEPS ${PINMAP})
  add_custom_target(
    "PINMAP_INSTALL_${BOARD}_${DEVICE}_${PACKAGE}_${PINMAP_FILE_NAME}"
    ALL
    DEPENDS ${DEPS}
    )
  install(FILES ${PINMAP_FILE}
    DESTINATION "share/arch/${DEVICE}_${PACKAGE}/${PART}"
    RENAME "pinmap_${ADD_QUICKLOGIC_BOARD_FABRIC_PACKAGE}.csv")

  get_target_property_required(CLKMAP ${BOARD} CLKMAP)
  get_file_location(CLKMAP_FILE ${CLKMAP})
  get_filename_component(CLKMAP_FILE_NAME ${CLKMAP_FILE} NAME)
  append_file_dependency(DEPS ${CLKMAP})
  add_custom_target(
    "CLKMAP_INSTALL_${BOARD}_${DEVICE}_${PACKAGE}_${CLKMAP_FILE_NAME}"
    ALL
    DEPENDS ${DEPS}
    )
  install(FILES ${CLKMAP_FILE}
    DESTINATION "share/arch/${DEVICE}_${PACKAGE}/${PART}"
    RENAME "clkmap_${ADD_QUICKLOGIC_BOARD_FABRIC_PACKAGE}.csv")
endfunction()
