# CMAKE generated file: DO NOT EDIT!
# Generated by "MinGW Makefiles" Generator, CMake Version 3.17

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

SHELL = cmd.exe

# The CMake executable.
CMAKE_COMMAND = "D:\CLion 2020.3.3\bin\cmake\win\bin\cmake.exe"

# The command to remove a file.
RM = "D:\CLion 2020.3.3\bin\cmake\win\bin\cmake.exe" -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = D:\Curva

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = D:\Curva\cmake-build-debug

# Include any dependencies generated for this target.
include CMakeFiles/Curva.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/Curva.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/Curva.dir/flags.make

CMakeFiles/Curva.dir/main.cpp.obj: CMakeFiles/Curva.dir/flags.make
CMakeFiles/Curva.dir/main.cpp.obj: ../main.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=D:\Curva\cmake-build-debug\CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/Curva.dir/main.cpp.obj"
	C:\PROGRA~2\MINGW-~1\I686-8~1.0-P\mingw32\bin\G__~1.EXE  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles\Curva.dir\main.cpp.obj -c D:\Curva\main.cpp

CMakeFiles/Curva.dir/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Curva.dir/main.cpp.i"
	C:\PROGRA~2\MINGW-~1\I686-8~1.0-P\mingw32\bin\G__~1.EXE $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E D:\Curva\main.cpp > CMakeFiles\Curva.dir\main.cpp.i

CMakeFiles/Curva.dir/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Curva.dir/main.cpp.s"
	C:\PROGRA~2\MINGW-~1\I686-8~1.0-P\mingw32\bin\G__~1.EXE $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S D:\Curva\main.cpp -o CMakeFiles\Curva.dir\main.cpp.s

# Object files for target Curva
Curva_OBJECTS = \
"CMakeFiles/Curva.dir/main.cpp.obj"

# External object files for target Curva
Curva_EXTERNAL_OBJECTS =

Curva.exe: CMakeFiles/Curva.dir/main.cpp.obj
Curva.exe: CMakeFiles/Curva.dir/build.make
Curva.exe: CMakeFiles/Curva.dir/linklibs.rsp
Curva.exe: CMakeFiles/Curva.dir/objects1.rsp
Curva.exe: CMakeFiles/Curva.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=D:\Curva\cmake-build-debug\CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable Curva.exe"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles\Curva.dir\link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/Curva.dir/build: Curva.exe

.PHONY : CMakeFiles/Curva.dir/build

CMakeFiles/Curva.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles\Curva.dir\cmake_clean.cmake
.PHONY : CMakeFiles/Curva.dir/clean

CMakeFiles/Curva.dir/depend:
	$(CMAKE_COMMAND) -E cmake_depends "MinGW Makefiles" D:\Curva D:\Curva D:\Curva\cmake-build-debug D:\Curva\cmake-build-debug D:\Curva\cmake-build-debug\CMakeFiles\Curva.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/Curva.dir/depend

