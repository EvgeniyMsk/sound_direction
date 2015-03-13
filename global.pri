
COMPILER_IS_ARM = $$find(COMPILER, arm-oe.*)

count(COMPILER_IS_ARM, 1) {
    BUILD = trik
} else {
    BUILD = desktop
}

CONFIG(debug, debug | release) {
    CONFIGURATION = $$BUILD-debug
    CONFIGURATION_SUFFIX = -$$BUILD-d
} else {
    CONFIGURATION = $$BUILD-release
    equals(BUILD, "trik") {
        CONFIGURATION_SUFFIX =
    } else {
        CONFIGURATION_SUFFIX = -$$BUILD
    }
}

DESTDIR = $$PWD/bin/$$CONFIGURATION

PROJECT_BASENAME = $$basename(_PRO_FILE_)
PROJECT_NAME = $$section(PROJECT_BASENAME, ".", 0, 0)

TARGET = $$PROJECT_NAME$$CONFIGURATION_SUFFIX

OBJECTS_DIR = .build/$$CONFIGURATION/.obj
MOC_DIR = .build/$$CONFIGURATION/.moc
RCC_DIR = .build/$$CONFIGURATION/.rcc
UI_DIR = .build/$$CONFIGURATION/.ui

INCLUDEPATH += $$_PRO_FILE_PWD_ \
               $$_PRO_FILE_PWD_/include/$$PROJECT_NAME \
                $$_PRO_FILE_PWD_/include/internal \

LIBS += -L$$DESTDIR

QMAKE_CXXFLAGS += -std=c++11 -g -Wall -Wextra

GLOBAL_PWD = $$PWD

# Useful function to copy additional files to destination,
# from http://stackoverflow.com/questions/3984104/qmake-how-to-copy-a-file-to-the-output
defineTest(copyToDestdir) {
    FILES = $$1
    SUBDIR   = $$2

    for(FILE, FILES) {
        # This ugly code is needed because xcopy requires to add source directory name to target directory name when copying directories
        win32:AFTER_SLASH = $$section(FILE, "/", -1, -1)
        win32:BASE_NAME = $$section(FILE, "/", -2, -2)
        win32:equals(AFTER_SLASH, ""):DESTDIR_SUFFIX = /$$BASE_NAME

        win32:FILE ~= s,/$,,g
        win32:FILE ~= s,/,\,g

        DDIR = $$DESTDIR/$$SUBDIR/
        win32:DDIR ~= s,/,\,g

        QMAKE_POST_LINK += $(MKDIR) $$quote($$DDIR) $$escape_expand(\\n\\t)
        QMAKE_POST_LINK += $(COPY_DIR) $$quote($$FILE) $$quote($$DDIR) $$escape_expand(\\n\\t)

    }

    export(QMAKE_POST_LINK)
}

defineTest(uses) {
    LIBS += -L$$DESTDIR
    PROJECTS = $$1
    for(PROJECT, PROJECTS) {
        LIBS += -l$$PROJECT$$CONFIGURATION_SUFFIX
        INCLUDEPATH += $$GLOBAL_PWD/$$PROJECT/include $$GLOBAL_PWD/$$PROJECT/include/internal
    }
    export(LIBS)
    export(INCLUDEPATH)
}
