cmake_minimum_required (VERSION 2.8)

PROJECT (MySQL)
SET(LIBSRC_LIST MySQLLexer.c MySQLParser.c)
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)

# All known publicly available versions of Antlr3C are buggy
if (SKIP_BUNDLED_ANTLR)
  find_package(Antlr3C)
endif ()
if (ANTLR3C_FOUND)
  set(ANTLR3C_REQUIRED_VERSION "3.4")
  if (${ANTLR3C_VERSION} VERSION_LESS ${ANTLR3C_REQUIRED_VERSION})
    message("Required antlr3c version ${ANTLR3C_REQUIRED_VERSION} but ${ANTLR3C_VERSION} found, using bundled version")
    unset(ANTLR3C_FOUND)
  endif ()
endif ()

include(ExternalProject)

if (NOT ANTLR3C_FOUND)
  message("Using bundled Antlr C runtime")
  #  Use for Antlr3 the one we have in /ext:
  set(ANTLR3C_INCLUDE_DIRS ${PROJECT_SOURCE_DIR}/ext/antlr-runtime ${PROJECT_SOURCE_DIR}/ext/antlr-runtime/include)
  set(ANTLR3C_LIBRARIES "-L${PROJECT_BINARY_DIR}/antlr-wb -lantlr3c_wb")

  ExternalProject_Add(antlr-wb
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/ext/antlr-runtime
    CONFIGURE_COMMAND autoreconf -i -s && ${PROJECT_SOURCE_DIR}/ext/antlr-runtime/configure
        --prefix=${PROJECT_BINARY_DIR}/antlr-wb
        --libdir=${PROJECT_BINARY_DIR}/antlr-wb
    --disable-abiflags
    BUILD_COMMAND make
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make install
  )

  link_directories(${PROJECT_BINARY_DIR}/antlr-wb)
endif ()

INCLUDE_DIRECTORIES(.)
INCLUDE_DIRECTORIES(./ext/antlr-runtime/include)
INCLUDE_DIRECTORIES(./ext/antlr-runtime/) # for antlr3config.h
ADD_LIBRARY(mysqlparser STATIC ${LIBSRC_LIST})

ADD_EXECUTABLE(main main.c)
TARGET_LINK_LIBRARIES(main mysqlparser antlr3c_wb)
