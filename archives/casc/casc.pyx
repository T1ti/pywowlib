from libcpp cimport bool
from libc.stdlib cimport free

cdef extern from "native/LocalCascHandler.h":
    cdef cppclass LocalCascHandler:
        LocalCascHandler() except +
        void initialize(const char* dataPath) except +
        void initializeWithBuildKey(const char* dataPath, const char* buildKey) except +
        void initializeWithBuildInfo(const char* dataPath, const char* buildInfo) except +
        void initializeWithBuildInfoPath(const char* dataPath, const char* buildInfoPath) except +
        bool fileExists(const char* fileName)
        bool fileDataIdExists(int fileDataId)
        void* openFile(const char* fileName, int& fileSize) except +
        void* openFileByFileId(int fileDataId, int& fileSize) except +

cdef class CascHandlerLocal:
    cdef LocalCascHandler c_casc;
    def __cinit__(self):
        self.c_casc = LocalCascHandler()

    def initialize(self, path):
        self.c_casc.initialize(path.encode('utf-8'))

    def initialize_with_build_key(self, path, build_key):
        self.c_casc.initializeWithBuildKey(path.encode('utf-8'), build_key.encode('utf-8'))

    def initialize_with_build_info(self, path, build_info):
        self.c_casc.initializeWithBuildInfo(path.encode('utf-8'), build_info.encode('utf-8'))

    def initialize_with_build_info_path(self, path, build_info_path):
        self.c_casc.initializeWithBuildInfoPath(path.encode('utf-8'), build_info_path.encode('utf-8'))

    def exists(self, file):
        if isinstance(file, str):
            return self.c_casc.fileExists(file)
        elif isinstance(file, int):
            return self.c_casc.fileDataIdExists(file)
        else:
            raise ValueError('file must be either string or int')

    def open_file(self, file):
        cdef int fileSize
        cdef void* dataPtr
        fileSize = 0
        if isinstance(file, str):
            dataPtr = self.c_casc.openFile(file, fileSize)
        elif isinstance(file, int):
            dataPtr = self.c_casc.openFileByFileId(file, fileSize)
        else:
            raise ValueError("File must be either string or int")

        cdef unsigned char[::1] mview = <unsigned char[:fileSize]>(dataPtr)
        ret = memoryview(mview).tobytes()
        free(dataPtr)
        return ret