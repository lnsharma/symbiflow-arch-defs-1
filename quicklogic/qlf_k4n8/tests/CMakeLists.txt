add_custom_target(all_qlf_k4n8_tests_no_adder)
add_custom_target(all_qlf_k4n8_tests_adder)

add_subdirectory(counter)
add_subdirectory(counter_16bit)
add_subdirectory(adder_8)

add_dependencies(all_quicklogic_tests all_qlf_k4n8_tests_no_adder)
add_dependencies(all_quicklogic_tests all_qlf_k4n8_tests_adder)
